#!/usr/bin/env bash
set -euo pipefail

# Select the next pane below the target pane within the same vertical column,
# wrapping to the top pane in that column, then maximize it vertically.

target="${1:-${TMUX_PANE:-}}"

if [ -z "$target" ]; then
  target="$(tmux display-message -p '#{pane_id}')"
fi

pane_id="$(tmux display-message -p -t "$target" '#{pane_id}')"
window_id="$(tmux display-message -p -t "$pane_id" '#{window_id}')"
saved_layout="$(tmux show-option -wqv -t "$window_id" @vertical_maximize_layout)"

# If a vertical maximize is active, restore the saved layout before calculating
# pane positions. Otherwise the maximized pane's dimensions distort the order.
if [ -n "$saved_layout" ]; then
  tmux select-layout -t "$window_id" "$saved_layout" 2>/dev/null || true
  tmux set-option -wq -u -t "$window_id" @vertical_maximize_pane
  tmux set-option -wq -u -t "$window_id" @vertical_maximize_layout
  tmux select-pane -t "$pane_id" 2>/dev/null || pane_id="$(tmux display-message -p -t "$window_id" '#{pane_id}')"
fi

read -r current_left current_right current_top < <(
  tmux display-message -p -t "$pane_id" '#{pane_left} #{pane_right} #{pane_top}'
)
current_center=$(((current_left + current_right) / 2))

first_pane=""
next_pane=""
next_top=""

while read -r id left right top; do
  if [ "$left" -le "$current_center" ] && [ "$current_center" -le "$right" ]; then
    if [ -z "$first_pane" ]; then
      first_pane="$id"
    fi

    if [ "$top" -gt "$current_top" ] && { [ -z "$next_top" ] || [ "$top" -lt "$next_top" ]; }; then
      next_pane="$id"
      next_top="$top"
    fi
  fi
done < <(tmux list-panes -t "$window_id" -F '#{pane_id} #{pane_left} #{pane_right} #{pane_top}' | sort -n -k4)

target_pane="${next_pane:-$first_pane}"

if [ -z "$target_pane" ]; then
  target_pane="$pane_id"
fi

tmux select-pane -t "$target_pane"
tmux-pane-vertical-maximize "$target_pane"
