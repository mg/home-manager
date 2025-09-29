#!/usr/bin/env python3
"""
release-log.py

Generate a release Jira issue summary from the last two git tags.

Workflow (default online mode):
 1. Determine the two most recent tags (by creation date) that look like version tags.
 2. Collect all commits in the olderTag..newerTag range.
 3. Derive PR numbers for commits (parse commit subject '(#1234)' first, else query GitHub).
 4. For each PR, fetch PR data (branch name + body) using gh.
 5. Extract Jira issue keys (pattern WEB-<digits>) from:
      - PR branch name (headRefName)
      - Lines under a "Resolves" header section in the PR body
 6. (De‑duplicated) set of issue keys is then looked up in Jira via REST API to get summary.
 7. Output lines: "<Jira summary>: <Jira link>" sorted by issue key.

Offline / fallback modes:
  - If --offline is passed, gh / Jira HTTP calls are skipped; issue keys are only
    extracted from commit subjects. Output will have unknown summaries.
  - If Jira auth (JIRA_USER + JIRA_TOKEN or JIRA_USER + JIRA_PASSWORD) is missing
    summaries become "<ISSUE> (no auth)".

Auth & tooling requirements:
  - Git installed (obvious inside a git repo).
  - gh CLI configured for the repository host (auto-detected from origin).
   - Jira auth provided via .env (PAT=...) or env vars PAT/JIRA_PAT + optional JIRA_USER

Examples:
  python release-log.py
  python release-log.py --tags v30.6.5 v30.7.0-9
  python release-log.py --skip-jira
  python release-log.py --offline

Exit codes:
  0 success (even if partial data)
  1 fatal error (e.g., not enough tags, git failure)

MG: Keep it simple & concise when running.
"""
from __future__ import annotations
import argparse
import os
import base64
import json
import re
import subprocess
import sys
import threading
import queue
import urllib.request
import urllib.error
from dataclasses import dataclass
from typing import Iterable, List, Set, Dict, Optional, Tuple

ISSUE_REGEX = re.compile(r"\bWEB-\d+\b", re.IGNORECASE)
RESOLVES_HEADER_REGEX = re.compile(r"^#+\s*Resolves\b", re.IGNORECASE)
VERSION_TAG_REGEX = re.compile(r"^v?\d+\.\d+\.\d+(?:[\.-][A-Za-z0-9]+)*$")
JIRA_BASE_BROWSE = "https://jira.lais.net/browse/"
JIRA_API_ISSUE = "https://jira.lais.net/rest/api/2/issue/{issue}?fields=summary"
# Jira auth normally supplied via .env PAT or environment variable PAT/JIRA_PAT.
# WARNING: Do not commit real secrets; this script reads them at runtime.
JIRA_DEFAULT_USER = "LAFMOG"

@dataclass
class PRInfo:
    number: int
    branch: str
    body: str


def run(cmd: List[str], *, capture=True, text=True, check=True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=capture, text=text, check=check)


def git(*args: str) -> str:
    try:
        cp = run(["git", *args])
        return cp.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"git {' '.join(args)} failed: {e.stderr}", file=sys.stderr)
        raise


def detect_repo() -> Tuple[str, str, str]:
    """Return (host, owner, repo)."""
    origin = git("remote", "get-url", "origin")
    # Normalize
    host = owner = repo = ''
    if origin.startswith("http://") or origin.startswith("https://"):
        parts = origin.split("//", 1)[1].rstrip(".git")
        segs = parts.split('/')
        if len(segs) >= 3:
            host, owner, repo = segs[0], segs[1], segs[2]
    elif origin.startswith("git@"):
        # git@host:owner/repo.git
        host_part, path_part = origin.split(':', 1)
        host = host_part.split('@', 1)[1]
        path_part = path_part.rstrip('.git')
        segs = path_part.split('/')
        if len(segs) >= 2:
            owner, repo = segs[0], segs[1]
    else:
        raise SystemExit(f"Unsupported remote URL format: {origin}")
    if not all([host, owner, repo]):
        raise SystemExit(f"Could not parse origin remote: {origin}")
    return host, owner, repo


def get_last_two_version_tags(limit: int = 30) -> Tuple[str, str]:
    """Return (latest_tag, previous_tag).

    Preference: if latest tag matches pattern <base>-<n>, choose previous
    tag with same <base> and largest numeric <m> where m < n. Fallback to
    second most recently created tag if none found.
    """
    tags_raw = git("tag", "--sort=-creatordate")
    tags = [t for t in tags_raw.splitlines() if VERSION_TAG_REGEX.match(t)]
    if not tags:
        raise SystemExit("No version tags found")
    latest = tags[0]
    series_re = re.compile(r'^(v?\d+\.\d+\.\d+)-(\d+)$')
    m = series_re.match(latest)
    if m:
        base = m.group(1)
        cur_num = int(m.group(2))
        best: Optional[Tuple[int, str]] = None
        for t in tags[1:]:
            m2 = series_re.match(t)
            if not m2:
                continue
            if m2.group(1) != base:
                continue
            num = int(m2.group(2))
            if num < cur_num:
                if not best or num > best[0]:
                    best = (num, t)
        if best:
            return latest, best[1]
    # fallback
    if len(tags) < 2:
        raise SystemExit("Need at least two version tags")
    return latest, tags[1]


def get_commits_between(old_tag: str, new_tag: str) -> List[str]:
    if old_tag == new_tag:
        return []
    rev_range = f"{old_tag}..{new_tag}"
    out = git("rev-list", rev_range)
    commits = [c for c in out.splitlines() if c]
    return commits


def parse_pr_number_from_subject(subject: str) -> Optional[int]:
    m = re.search(r"\(#(\d+)\)", subject)
    if m:
        return int(m.group(1))
    return None


def get_commit_subjects(commits: Iterable[str]) -> Dict[str, str]:
    if not commits:
        return {}
    cp = run(["git", "show", "--no-patch", "--pretty=%H:::%s", *commits])
    lines = cp.stdout.strip().splitlines()
    out = {}
    for line in lines:
        if ':::' in line:
            sha, subj = line.split(':::', 1)
            out[sha] = subj.strip()
    return out


def gh_api(host: str, path: str, jq: Optional[str] = None) -> str:
    cmd = ["gh", "api", f"repos/{path}"]
    # Rely on GH_HOST env externally for enterprise instances; do not inject --hostname.
    if jq:
        cmd += ["--jq", jq]
    try:
        cp = run(cmd)
        return cp.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"gh api failed for {path}: {e.stderr}")


def gh_pr_view(host: str, number: int) -> PRInfo:
    cmd = ["gh", "pr", "view", str(number), "--json", "body,headRefName"]
    # Rely on GH_HOST env for host selection.
    cp = run(cmd)
    data = json.loads(cp.stdout)
    return PRInfo(number=number, branch=data.get("headRefName") or "", body=data.get("body") or "")


def get_pr_numbers_for_commit(host: str, owner: str, repo: str, sha: str) -> List[int]:
    # Use the commit->PRs API (may return multiple, usually 1) -- preview not required now.
    path = f"{owner}/{repo}/commits/{sha}/pulls"
    try:
        json_text = gh_api(host, path)
        if not json_text:
            return []
        arr = json.loads(json_text)
        numbers_raw = [pr.get("number") for pr in arr if isinstance(pr, dict)]
        numbers: List[int] = []
        for n in numbers_raw:
            if isinstance(n, int):
                numbers.append(n)
            elif isinstance(n, str) and n.isdigit():
                numbers.append(int(n))
        return numbers
    except Exception:
        return []


def extract_issue_keys_from_text(text: str) -> Set[str]:
    return {m.group(0).upper() for m in ISSUE_REGEX.finditer(text or "")}


def extract_issue_keys_from_resolves(body: str) -> Set[str]:
    if not body:
        return set()
    lines = body.splitlines()
    keys = set()
    for i, line in enumerate(lines):
        if RESOLVES_HEADER_REGEX.match(line.strip()):
            j = i + 1
            while j < len(lines):
                l = lines[j]
                stripped = l.strip()
                if stripped.startswith('#'):
                    break  # next markdown header
                if stripped == "":
                    j += 1
                    continue
                keys |= extract_issue_keys_from_text(l)
                j += 1
    return keys


def jira_fetch_summary(issue: str, auth: Optional[Tuple[str, str]]) -> Optional[str]:
    url = JIRA_API_ISSUE.format(issue=issue)

    def parse(resp) -> Optional[str]:
        data = json.loads(resp.read().decode())
        fields = data.get("fields") or {}
        summary = fields.get("summary")
        if isinstance(summary, str):
            return summary.strip()
        return None

    def open_with(auth_header: Optional[str]):
        req = urllib.request.Request(url)
        req.add_header("Accept", "application/json")
        if auth_header:
            req.add_header("Authorization", auth_header)
        return urllib.request.urlopen(req, timeout=20)

    # No auth provided
    if not auth:
        try:
            with open_with(None) as resp:
                return parse(resp)
        except urllib.error.HTTPError as e:
            return f"{issue} (HTTP {e.code})"
        except Exception:
            return None

    basic_header = "Basic " + base64.b64encode(f"{auth[0]}:{auth[1]}".encode()).decode()
    try:
        with open_with(basic_header) as resp:
            return parse(resp)
    except urllib.error.HTTPError as e:
        if e.code == 401:
            # Fallback to Bearer token strategy
            bearer_header = f"Bearer {auth[1]}"
            try:
                with open_with(bearer_header) as resp2:
                    return parse(resp2)
            except urllib.error.HTTPError as e2:
                return f"{issue} (HTTP {e2.code})"
            except Exception:
                return None
        return f"{issue} (HTTP {e.code})"
    except Exception:
        return None
    return None


def collect_jira_summaries(issues: List[str], auth: Optional[Tuple[str, str]], parallel: int = 6) -> Dict[str, str]:
    if not issues:
        return {}
    out: Dict[str, str] = {}
    q: queue.Queue[str] = queue.Queue()
    for issue in issues:
        q.put(issue)

    def worker():
        while True:
            try:
                iss = q.get_nowait()
            except queue.Empty:
                return
            summary = jira_fetch_summary(iss, auth)
            if not summary:
                summary = f"{iss} (no summary)"
            out[iss] = summary
            q.task_done()

    threads = []
    for _ in range(min(parallel, len(issues))):
        t = threading.Thread(target=worker, daemon=True)
        t.start()
        threads.append(t)
    for t in threads:
        t.join()
    return out


def main():
    ap = argparse.ArgumentParser(description="Generate Jira issue list from last two tags' PRs")
    ap.add_argument('--tags', nargs=2, metavar=('OLD_TAG', 'NEW_TAG'), help='Explicit tag range (older newer)')
    ap.add_argument('--offline', action='store_true', help='Skip all gh + Jira calls; rely only on commit subjects')
    ap.add_argument('--skip-jira', action='store_true', help='Do not query Jira; output issue key as summary')
    ap.add_argument('--limit', type=int, help='Limit number of commits processed (debug)')
    ap.add_argument('--verbose', action='store_true')
    args = ap.parse_args()

    try:
        host, owner, repo = detect_repo()
    except SystemExit as e:
        print(str(e), file=sys.stderr)
        return 1

    if args.tags:
        old_tag, new_tag = args.tags[0], args.tags[1]
    else:
        new_tag, old_tag = get_last_two_version_tags()

    if args.verbose:
        print(f"Using tags: older={old_tag} newer={new_tag}", file=sys.stderr)

    commits = get_commits_between(old_tag, new_tag)
    if args.limit:
        commits = commits[:args.limit]
    if not commits:
        print("No commits in range", file=sys.stderr)
        return 0

    # Map commit->subject
    subjects = get_commit_subjects(commits)

    # Track mapping commit->PRs and issue keys
    commit_to_prs: Dict[str, Set[int]] = {}
    commit_issue_keys_map: Dict[str, Set[str]] = {}
    issue_keys: Set[str] = set()
    pr_numbers: Set[int] = set()

    # Always record keys from commit subjects (even online)
    for sha, subj in subjects.items():
        subj_keys = extract_issue_keys_from_text(subj)
        commit_issue_keys_map[sha] = set(subj_keys)
        issue_keys |= subj_keys

    if args.offline:
        pass  # already collected from subjects
    else:
        # Determine PRs per commit
        for sha in commits:
            subj = subjects.get(sha, '')
            pr_num = parse_pr_number_from_subject(subj)
            prs = commit_to_prs.setdefault(sha, set())
            if pr_num:
                prs.add(pr_num)
                pr_numbers.add(pr_num)
            else:
                try:
                    nums = get_pr_numbers_for_commit(host, owner, repo, sha)
                    for n in nums:
                        prs.add(n)
                        pr_numbers.add(n)
                except Exception as e:
                    if args.verbose:
                        print(f"PR lookup failed for {sha[:7]}: {e}", file=sys.stderr)

        if args.verbose:
            print(f"Found {len(pr_numbers)} PRs", file=sys.stderr)

        # Fetch PR details and collect issue keys per PR
        pr_issue_keys_map: Dict[int, Set[str]] = {}
        for n in sorted(pr_numbers):
            try:
                info = gh_pr_view(host, n)
            except Exception as e:
                if args.verbose:
                    print(f"Failed to fetch PR {n}: {e}", file=sys.stderr)
                continue
            pr_issue_keys = extract_issue_keys_from_text(info.branch) | extract_issue_keys_from_resolves(info.body)
            if not pr_issue_keys:
                pr_issue_keys = extract_issue_keys_from_text(info.body)
            pr_issue_keys_map[n] = pr_issue_keys
        # Merge PR issue keys into commits
        for sha, prs in commit_to_prs.items():
            for pr in prs:
                commit_issue_keys_map[sha].update(pr_issue_keys_map.get(pr, set()))
        # Rebuild global issue key set
        issue_keys = set()
        for keyset in commit_issue_keys_map.values():
            issue_keys.update(keyset)

    # Sort issue keys
    issue_list = sorted(issue_keys, key=lambda k: (k.split('-')[0], int(k.split('-')[1]) if k.split('-')[1].isdigit() else 0))

    # Jira summaries
    summaries: Dict[str, str] = {}
    jira_auth: Optional[Tuple[str, str]] = None
    if not (args.skip_jira or args.offline):
        # Load from .env in current directory if present; expect line PAT=...
        env_pat = None
        env_user = None
        try:
            if os.path.exists('.env'):
                with open('.env') as f:
                    for line in f:
                        line = line.strip()
                        if not line or line.startswith('#'):
                            continue
                        if '=' not in line:
                            continue
                        k, v = line.split('=', 1)
                        k = k.strip()
                        v = v.strip()
                        if k == 'PAT' and v:
                            env_pat = v
                        elif k in ('JIRA_USER', 'USER') and v:
                            env_user = v
            # Fallback to environment variables if not in file
            if not env_pat:
                env_pat = os.environ.get('PAT') or os.environ.get('JIRA_PAT')
            if not env_user:
                env_user = os.environ.get('JIRA_USER') or JIRA_DEFAULT_USER
        except Exception as e:
            if args.verbose:
                print(f"Failed reading .env: {e}", file=sys.stderr)
        if env_pat:
            jira_auth = (env_user or JIRA_DEFAULT_USER, env_pat)
        else:
            if args.verbose:
                print("No PAT found in .env or environment; Jira summaries will be unauthenticated", file=sys.stderr)
    if jira_auth and not (args.skip_jira or args.offline):
        summaries = collect_jira_summaries(issue_list, jira_auth)
    else:
        for iss in issue_list:
            summaries[iss] = f"{iss} (no auth)" if not args.offline else iss

    # Output
    for iss in issue_list:
        summary = summaries.get(iss, iss)
        print(f"{summary}: {JIRA_BASE_BROWSE}{iss}")

    # Unmapped commits (exclude tag annotation commits that have subject == newer tag)
    unmapped = []
    tag_like = {new_tag, old_tag}
    for sha in commits:
        if subjects.get(sha) in tag_like:
            continue
        if not commit_issue_keys_map.get(sha):
            unmapped.append((sha, subjects.get(sha, '')))
    if unmapped:
        print("\nUnmapped commits (no WEB- issue detected):")
        for sha, subj in unmapped:
            print(f"{sha[:10]} {subj}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
