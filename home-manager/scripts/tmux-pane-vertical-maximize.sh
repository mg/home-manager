#!/usr/bin/env bash
set -euo pipefail

# Toggle a vertical-only pane maximize for the target pane.
# tmux enforces minimum heights for the panes above/below, so asking for
# 100% height leaves them as small as tmux allows while preserving width splits.

target="${1:-${TMUX_PANE:-}}"

if [ -z "$target" ]; then
  target="$(tmux display-message -p '#{pane_id}')"
fi

pane_id="$(tmux display-message -p -t "$target" '#{pane_id}')"
window_id="$(tmux display-message -p -t "$pane_id" '#{window_id}')"
saved_pane="$(tmux show-option -wqv -t "$window_id" @vertical_maximize_pane)"
saved_layout="$(tmux show-option -wqv -t "$window_id" @vertical_maximize_layout)"

unset_saved_layout() {
  tmux set-option -wq -u -t "$window_id" @vertical_maximize_pane
  tmux set-option -wq -u -t "$window_id" @vertical_maximize_layout
}

restore_saved_layout() {
  if [ -z "$saved_layout" ]; then
    return 1
  fi

  if tmux select-layout -t "$window_id" "$saved_layout" 2>/dev/null; then
    unset_saved_layout
    return 0
  fi

  unset_saved_layout
  return 1
}

if [ -n "$saved_layout" ] && [ "$saved_pane" = "$pane_id" ]; then
  restore_saved_layout || true
  tmux select-pane -t "$pane_id" 2>/dev/null || true
  exit 0
fi

# If another pane in this window is currently vertically maximized, restore the
# original layout first. This makes pressing the binding on a different visible
# pane move the vertical maximize to that pane instead of leaving stale state.
if [ -n "$saved_layout" ]; then
  restore_saved_layout || true
  tmux select-pane -t "$pane_id" 2>/dev/null || pane_id="$(tmux display-message -p '#{pane_id}')"
fi

current_layout="$(tmux display-message -p -t "$window_id" '#{window_layout}')"
tmux set-option -wq -t "$window_id" @vertical_maximize_pane "$pane_id"
tmux set-option -wq -t "$window_id" @vertical_maximize_layout "$current_layout"
tmux resize-pane -t "$pane_id" -y 100%
