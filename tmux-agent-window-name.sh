#!/usr/bin/env bash
# Claude Code / Codex 훅에서 호출한다. 세션 이름이 새로 정해지거나 바뀐 순간에만
# tmux window 이름을 그에 맞춰 바꾼다. 그 밖의 훅 호출에서는 아무것도 하지 않는다.
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
  # 이 pane 이름을 우리가 바꿨을 때만 되돌린다
  if [[ -n "$(tmux show-options -p -t "$TMUX_PANE" -qv @tawn_src 2>/dev/null)" ]]; then
    tmux set-option -p -u -t "$TMUX_PANE" @tawn_src 2>/dev/null
    tmux set-window-option -t "$TMUX_PANE" automatic-rename on 2>/dev/null
  fi
  exit 0
fi

# verbatim=1 이면 사용자가 직접 정한 이름이므로 요약하지 않고 그대로 쓴다
verbatim=0
case "$agent" in
  claude)
    transcript="$(jq -r '.transcript_path // ""' <<<"$payload" 2>/dev/null)"
    [[ -f "$transcript" ]] || exit 0
    title="$(tac "$transcript" | grep -m1 '"type":"custom-title"' | jq -r '.customTitle // ""' 2>/dev/null)"
    if [[ -n "$title" && "$title" != "null" ]]; then
      verbatim=1
    else
      title="$(tac "$transcript" | grep -m1 '"type":"ai-title"' | jq -r '.aiTitle // ""' 2>/dev/null)"
    fi
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

# 이름이 그대로면 window 를 건드리지 않는다. 사용자가 손으로 바꿔둔 window 이름도 이 조건에서 살아남는다
[[ "$(tmux show-options -p -t "$TMUX_PANE" -qv @tawn_src 2>/dev/null)" == "$title" ]] && exit 0

clean() {
  # tmux 이름에 쓸 수 없는 문자를 털어낸다 (#은 tmux format 지시자)
  local s="$1"
  s="${s//[\`\"\'#]/}"
  s="$(tr -s '[:space:]' ' ' <<<"$s")"
  s="${s#"${s%%[![:space:]]*}"}"
  printf '%s' "${s%"${s##*[![:space:]]}"}"
}

# 한글은 두 칸을 차지하므로 글자 수가 아니라 표시 폭으로 재고 자른다
fit() {
  python3 -c '
import sys, unicodedata
s, limit = sys.argv[1], int(sys.argv[2])
cell = lambda c: 2 if unicodedata.east_asian_width(c) in "WF" else 1
if sum(cell(c) for c in s) <= limit:
    sys.stdout.write(s)
else:
    out, used = "", 0
    for c in s:
        if used + cell(c) > limit:
            break
        out += c
        used += cell(c)
    sys.stdout.write(out)
' "$1" "$2"
}

name="$(clean "$title")"
if [[ "$verbatim" != 1 && "$(fit "$name" "$MAXLEN")" != "$name" ]]; then
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
    short="$(clean "$(TMUX_AGENT_NAME_LOCK=1 claude -p --model "$MODEL" "$prompt" 2>/dev/null | head -1)")"
    # 요약이 실패하면 앞 두 어절을 쓴다
    [[ -n "$short" ]] || short="$(clean "$(awk '{print $1, $2}' <<<"$title")")"
    name="$(fit "$short" "$MAXLEN")"
    [[ -n "$name" ]] && printf '%s' "$name" >"$cache"
  fi
fi
[[ -n "$name" ]] || exit 0

tmux rename-window -t "$TMUX_PANE" "$name" 2>/dev/null &&
  tmux set-option -p -t "$TMUX_PANE" @tawn_src "$title" 2>/dev/null
