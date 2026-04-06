#!/bin/zsh

set -eu

title="Codex"
message="Codex stopped and is waiting."
log_file="/Users/uta_a/.codex/log/codex-notify.log"

if [[ $# -ge 1 ]]; then
  payload="$1"
  if [[ "$payload" == *'"type":"agent-turn-complete"'* ]]; then
    message="Codex stopped and is waiting for you."
  fi
fi

mkdir -p /Users/uta_a/.codex/log
{
  print -r -- "[$(/bin/date '+%Y-%m-%d %H:%M:%S')] notify invoked"
  if [[ $# -ge 1 ]]; then
    print -r -- "payload=$1"
  else
    print -r -- "payload=<none>"
  fi
} >> "$log_file"

/usr/bin/osascript -e 'display notification "'"${message//\"/\\\"}"'" with title "'"${title//\"/\\\"}"'" sound name "Glass"' >/dev/null 2>&1 &!
/usr/bin/afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &!
