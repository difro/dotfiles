#!/usr/bin/env bash
# tmux-open-plan.sh — Open Claude Code plan file in a right split
#
# Usage:
#   tmux-open-plan.sh <pane_id> [pane_path] [shell_cmd]
#
#   pane_id    — source pane to capture text from
#   pane_path  — pane's current path (for -c flag, default: $HOME)
#   shell_cmd  — custom shell command for split pane (e.g. "CND901_HOSTMODE=0 bash")
#                when set, uses send-keys to run editor inside the spawned shell
set -euo pipefail

source_pane="${1:-}"
source_path="${2:-$HOME}"
shell_cmd="${3:-}"

if [[ -z "$source_pane" ]]; then
  tmux display-message "open-plan: no source pane"
  exit 1
fi

# Capture last 50 lines, strip ANSI escape sequences
captured="$(tmux capture-pane -p -S -50 -t "$source_pane" | sed $'s/\x1b\\[[0-9;?]*[a-zA-Z]//g; s/\x1b\\][^\x07]*\x07//g; s/\x1b[()][B0-2]//g')"

# Extract file path after · (middle dot) — Claude Code status hint
# Pattern: "ctrl-g to edit in Nvim · ~/.claude/plans/something.md"
plan_file="$(printf '%s\n' "$captured" | sed -n 's/.*·[[:space:]]*\([~\/][^[:space:]]*\.md\).*/\1/p' | tail -1)"

if [[ -z "$plan_file" ]]; then
  tmux display-message "open-plan: no plan file found in pane"
  exit 1
fi

# Expand tilde
plan_file="${plan_file/#\~/$HOME}"

if [[ ! -f "$plan_file" ]]; then
  tmux display-message "open-plan: not found: ${plan_file}"
  exit 1
fi

editor="${EDITOR:-nvim}"
escaped_file="$(printf '%q' "$plan_file")"

if [[ -n "$shell_cmd" ]]; then
  # Custom shell: spawn shell, then send editor command via send-keys
  # Strip nix-chroot prefix from path (no-op if not present)
  host_path="$(echo "$source_path" | sed 's|.*nix-chroot[^/]*||')"
  new_pane="$(tmux split-window -h -c "$host_path" -P -F '#{pane_id}' "$shell_cmd")"
  tmux send-keys -t "$new_pane" "$editor $escaped_file" Enter
else
  # Direct: open editor in split
  tmux split-window -h -c "$source_path" "$editor $escaped_file"
fi
