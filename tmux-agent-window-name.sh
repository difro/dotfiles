#!/usr/bin/env bash
# Claude Code / Codex 훅에서 호출한다. 세션 제목을 한두 단어로 줄여 tmux window 이름으로 쓴다.
# usage: tmux-agent-window-name.sh <claude|codex>   (훅 payload는 stdin JSON)
set -uo pipefail

agent="${1:-}"
[[ -n "${TMUX_PANE:-}" ]] || exit 0
# 요약용 claude -p 가 이 훅을 다시 부르는 것을 막는다
[[ -z "${TMUX_AGENT_NAME_LOCK:-}" ]] || exit 0

MODEL="claude-haiku-4-5-20251001"
MAXLEN=16
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-agent-window-name"

# 훅이 요약 호출을 기다리지 않도록 백그라운드로 넘긴다
if [[ "${TAWN_BG:-}" != 1 ]]; then
  payload="$(cat)"
  TAWN_BG=1 setsid "$0" "$@" <<<"$payload" >/dev/null 2>&1 &
  exit 0
fi

payload="$(cat)"
event="$(jq -r '.hook_event_name // ""' <<<"$payload" 2>/dev/null)"

if [[ "$event" == "SessionEnd" ]]; then
  tmux set-window-option -t "$TMUX_PANE" automatic-rename on 2>/dev/null
  exit 0
fi

case "$agent" in
  claude)
    transcript="$(jq -r '.transcript_path // ""' <<<"$payload" 2>/dev/null)"
    [[ -f "$transcript" ]] || exit 0
    title="$(tac "$transcript" | grep -m1 '"type":"ai-title"' | jq -r '.aiTitle // ""' 2>/dev/null)"
    ;;
  codex)
    sid="$(jq -r '.session_id // ""' <<<"$payload" 2>/dev/null)"
    index="$HOME/.codex/session_index.jsonl"
    [[ -n "$sid" && -f "$index" ]] || exit 0
    title="$(tac "$index" | grep -m1 -F "\"id\":\"$sid\"" | jq -r '.thread_name // ""' 2>/dev/null)"
    ;;
  *)
    exit 0
    ;;
esac
[[ -n "${title:-}" && "$title" != "null" ]] || exit 0

clean() {
  # tmux 이름에 쓸 수 없는 문자를 털어내고 길이를 자른다 (#은 tmux format 지시자)
  local s="$1"
  s="${s//[\`\"\'#]/}"
  s="$(tr -s '[:space:]' ' ' <<<"$s")"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "${s:0:$MAXLEN}"
}

mkdir -p "$CACHE_DIR"
key="$(printf '%s' "$agent:$title" | md5sum | cut -d' ' -f1)"
cache="$CACHE_DIR/$key"

exec 9>"$cache.lock"
flock 9

if [[ -s "$cache" ]]; then
  name="$(cat "$cache")"
else
  prompt="Shorten this coding-session title into a tmux window label of one or two words.
Keep the most identifying nouns (project, tool, file names) and drop generic verbs.
Answer in the same language as the title. No quotes, no punctuation, at most ${MAXLEN} characters.
Reply with the label only.

Title: ${title}"
  name="$(clean "$(TMUX_AGENT_NAME_LOCK=1 claude -p --model "$MODEL" "$prompt" 2>/dev/null | head -1)")"
  # 요약이 실패하면 앞 두 어절을 쓴다
  [[ -n "$name" ]] || name="$(clean "$(awk '{print $1, $2}' <<<"$title")")"
  [[ -n "$name" ]] || exit 0
  printf '%s' "$name" >"$cache"
fi

current="$(tmux display-message -p -t "$TMUX_PANE" '#{window_name}' 2>/dev/null)"
[[ "$current" == "$name" ]] && exit 0
tmux rename-window -t "$TMUX_PANE" "$name" 2>/dev/null
