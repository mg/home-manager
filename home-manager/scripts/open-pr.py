#!/usr/bin/env uv run python
import subprocess
import sys
import re
from mg_telemetry import log_execution


def get_commit_message(commit_hash):
    """Get the commit message for the given commit hash."""
    try:
        result = subprocess.run(
            ["git", "log", "--format=%s", "-n", "1", commit_hash],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def extract_pr_number(commit_msg):
    """Extract PR number from commit message (format: #123)."""
    match = re.search(r"#(\d+)", commit_msg)
    return match.group(1) if match else None


def get_remote_url():
    """Get the origin remote URL."""
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def convert_to_web_url(remote_url):
    """Convert git remote URL to web URL."""
    # Remove .git suffix
    url = re.sub(r"\.git$", "", remote_url)

    # Convert SSH to HTTPS
    url = re.sub(r"^git@([^:]+):", r"https://\1/", url)

    return url


def build_pr_url(base_url, pr_num):
    """Build PR URL based on the git hosting service."""
    if "github.com" in base_url:
        return f"{base_url}/pull/{pr_num}"
    elif "gitlab" in base_url:
        return f"{base_url}/-/merge_requests/{pr_num}"
    elif "bitbucket" in base_url:
        return f"{base_url}/pull-requests/{pr_num}"
    elif "git.lais.net" in base_url:  # Add your specific domain
        return f"{base_url}/pull/{pr_num}"

    else:
        # Default to GitHub-style
        return f"{base_url}/pull/{pr_num}"


def main():
    log_execution(__file__)

    if len(sys.argv) != 2:
        print("Usage: open-pr <commit_hash>")
        sys.exit(1)

    commit_hash = sys.argv[1]

    # Get commit message
    commit_msg = get_commit_message(commit_hash)
    if not commit_msg:
        print("Error: Could not get commit message")
        sys.exit(1)

    # Extract PR number
    pr_num = extract_pr_number(commit_msg)
    if not pr_num:
        print(f"No PR number found in commit: {commit_msg}")
        sys.exit(1)

    # Get remote URL
    remote_url = get_remote_url()
    if not remote_url:
        print("Error: Could not get remote URL")
        sys.exit(1)

    # Convert to web URL and build PR URL
    base_url = convert_to_web_url(remote_url)
    pr_url = build_pr_url(base_url, pr_num)

    # Open in browser
    # do not steel focus from tig
    applescript = f"""
    tell application "System Events"
        set frontApp to name of first application process whose frontmost is true
    end tell

    do shell script "open '{pr_url}'"

    delay 0.1

    tell application "System Events"
        set frontmost of first application process whose name is frontApp to true
    end tell
    """
    subprocess.run(["osascript", "-e", applescript], check=False)


if __name__ == "__main__":
    main()
