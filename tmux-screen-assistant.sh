#!/usr/bin/env bash
set -euo pipefail

source_pane="${1:-}"
source_path="${2:-$HOME}"

if [[ -z "$source_pane" ]]; then
  tmux display-message "screen assistant: source pane id is missing"
  exit 1
fi

if ! tmux display-message -p -t "$source_pane" >/dev/null 2>&1; then
  tmux display-message "screen assistant: source pane is not available"
  exit 1
fi

assistant_cmd=""
if command -v claudecode >/dev/null 2>&1; then
  assistant_cmd="$(command -v claudecode)"
elif command -v claude >/dev/null 2>&1; then
  assistant_cmd="$(command -v claude)"
fi

if [[ -z "$assistant_cmd" ]]; then
  tmux display-message "screen assistant: claudecode/claude command not found"
  exit 1
fi

tmp_root="${TMPDIR:?TMPDIR is not set}"
capture_file="$(mktemp "${tmp_root%/}/tmux-screen-capture.XXXXXX.txt")"
input_file="$(mktemp "${tmp_root%/}/tmux-screen-input.XXXXXX.txt")"
cleanup_file="${tmp_root%/}/tmux-screen-cleanup-${RANDOM}-$$.sh"
lines="${TMUX_SCREEN_ASSISTANT_LINES:-250}"

tmux capture-pane -p -S "-${lines}" -t "$source_pane" >"$capture_file"

cat >"$input_file" <<'PROMPT'
You are an ad-hoc shell troubleshooting assistant.
Given the captured tmux pane output:
1) Explain what the user is trying to do.
2) Point out errors or risky parts.
3) Provide concrete, minimal next commands to fix or verify.
4) If no errors, suggest better usage and quick improvements.
Respond in Korean and keep command names/flags exactly as-is.
PROMPT

printf "\n--- Captured tmux pane output ---\n" >>"$input_file"
cat "$capture_file" >>"$input_file"

cat >"$cleanup_file" <<EOF
#!/usr/bin/env bash
rm -f $(printf "%q" "$capture_file") $(printf "%q" "$input_file") $(printf "%q" "$cleanup_file")
EOF
chmod +x "$cleanup_file"

pane_cmd=$(
  cat <<EOF
set +o history 2>/dev/null || true
HISTFILE=/dev/null $(printf "%q" "$assistant_cmd") "\$(cat $(printf "%q" "$input_file"))"
$(printf "%q" "$cleanup_file")
tmux kill-pane -t "\${TMUX_PANE:-}" >/dev/null 2>&1 || tmux kill-pane >/dev/null 2>&1 || true
EOF
)

tmux split-window -h -c "$source_path" "$pane_cmd"
tmux display-message "screen assistant: captured last ${lines} lines"
