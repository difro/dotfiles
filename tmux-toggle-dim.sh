#!/usr/bin/env bash
# Toggle focus dim for current tmux window. Restores focus to active pane.
# Usage: tmux-toggle-dim.sh <active-pane-id>

set -u

active="$1"

if [ "$(tmux show -wv @dim-disabled 2>/dev/null || true)" = "1" ]; then
    tmux set -wu @dim-disabled
    while IFS= read -r pane; do
        [ "$pane" = "$active" ] && continue
        tmux select-pane -t "$pane" -P fg=colour245
    done < <(tmux list-panes -F '#{pane_id}')
else
    tmux set -w @dim-disabled 1
    while IFS= read -r pane; do
        tmux select-pane -t "$pane" -P fg=default
    done < <(tmux list-panes -F '#{pane_id}')
fi

tmux select-pane -t "$active"
