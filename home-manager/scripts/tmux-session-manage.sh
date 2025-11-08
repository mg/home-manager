#!/usr/bin/env bash
# ABOUTME: Presents active and declared tmux project sessions for selection
# ABOUTME: Creates new sessions from project manifests or switches to existing

set -euo pipefail

# Configurable project manifest files (order matters: active future project order)
PROJECT_FILES=("$HOME/Projects/projects.yml" "$HOME/Work/projects.yml")
PROJECT_PREFIXES=("" "work/")

# Collect active tmux sessions (may be empty if tmux not running)
# We assume this script is run inside an existing tmux client popup/keybinding
mapfile -t ACTIVE_SESSIONS < <(tmux list-sessions -F '#S' 2>/dev/null || true)

# Build an associative set for fast membership tests
declare -A ACTIVE_SET
for s in "${ACTIVE_SESSIONS[@]}"; do
  ACTIVE_SET["$s"]=1
done

# Parse project manifests into name->path map (only those not already active)
declare -A PROJECT_PATHS
ORDERED_PROJECT_NAMES=()

parse_projects_file() {
  local file="$1" prefix="$2" line within=0
  [[ -f $file ]] || return 0
  # We implement a minimal YAML subset parser: after a line exactly 'projects:'
  # collect indented lines shaped like: <indent><name>: <path>
  while IFS='' read -r line || [[ -n $line ]]; do
    if [[ $line =~ ^[[:space:]]*projects:[[:space:]]*$ ]]; then
      within=1
      continue
    fi
    if (( within )); then
      # Stop if we hit a non-indented new top-level key (starts at column 0 and not blank)
      if [[ $line =~ ^[^[:space:]] && ! $line =~ ^[[:space:]]*$ ]]; then
        within=0
        continue
      fi
      # Match indented key: value pairs
      if [[ $line =~ ^[[:space:]]*([A-Za-z0-9_.\/-]+):[[:space:]]*(.+[^[:space:]])[[:space:]]*$ ]]; then
        local name path
        name="${BASH_REMATCH[1]}"
        path="${BASH_REMATCH[2]}"
        # Expand leading ~ manually (do not eval arbitrary content)
        if [[ $path == ~* ]]; then
          path="$HOME${path:1}"
        fi
        local full_name="${prefix}${name}"
        # Skip if already an active session or already recorded
        if [[ -z ${ACTIVE_SET[$full_name]:-} && -z ${PROJECT_PATHS[$full_name]:-} ]]; then
          PROJECT_PATHS[$full_name]="$path"
          ORDERED_PROJECT_NAMES+=("$full_name")
        fi
      fi
    fi
  done < "$file"
}

for i in "${!PROJECT_FILES[@]}"; do
  parse_projects_file "${PROJECT_FILES[$i]}" "${PROJECT_PREFIXES[$i]}"
done

# Build selection list: active sessions first (prefixed with *), then future projects
SELECTION_LIST=$( {
  for s in "${ACTIVE_SESSIONS[@]}"; do
    printf '*%s\n' "$s"
  done
  for name in "${ORDERED_PROJECT_NAMES[@]}"; do
    printf '%s\n' "$name"
  done
} )

# If nothing to select (unlikely), just exit
if [[ -z $SELECTION_LIST ]]; then
  exit 0
fi

# Present via fzf
CHOICE=$(printf '%s\n' "$SELECTION_LIST" | fzf --reverse || true)
[[ -z ${CHOICE} ]] && exit 0

if [[ $CHOICE == \** ]]; then
  # Active session selected; strip leading *
  target="${CHOICE#\*}"
  tmux switch-client -t "=$target"
  exit 0
fi

# New project session
name="$CHOICE"
path="${PROJECT_PATHS[$name]:-}"
if [[ -z $path ]]; then
  # Should not happen; fail gracefully
  tmux display-message "Unknown project: $name"
  exit 1
fi

if [[ ! -d $path ]]; then
  tmux display-message "Directory missing: $path"
  exit 1
fi

# Create detached session and switch
if tmux has-session -t "=$name" 2>/dev/null; then
  # Race: became active after list (rare)
  tmux switch-client -t "=$name"
else
  tmux new-session -d -s "$name" -c "$path"
  tmux switch-client -t "=$name"
fi
