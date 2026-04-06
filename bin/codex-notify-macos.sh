#!/bin/zsh

set -eu

title="Codex"
message="Codex stopped and is waiting."
log_file="/Users/uta_a/.codex/log/codex-notify.log"
notifier_bin=""

if [[ $# -ge 1 ]]; then
  payload="$1"
  if [[ "$payload" == *'"type":"agent-turn-complete"'* ]]; then
    message="Codex stopped and is waiting for you."
  fi
fi

if [[ -x /opt/homebrew/bin/terminal-notifier ]]; then
  notifier_bin="/opt/homebrew/bin/terminal-notifier"
elif command -v terminal-notifier >/dev/null 2>&1; then
  notifier_bin="$(command -v terminal-notifier)"
fi

mkdir -p /Users/uta_a/.codex/log
{
  print -r -- "[$(/bin/date '+%Y-%m-%d %H:%M:%S')] notify invoked"
  if [[ $# -ge 1 ]]; then
    print -r -- "payload=$1"
  else
    print -r -- "payload=<none>"
  fi
  if [[ -n "$notifier_bin" ]]; then
    print -r -- "notifier=$notifier_bin"
  else
    print -r -- "notifier=<missing>"
  fi
} >> "$log_file"

if [[ -z "$notifier_bin" ]]; then
  exit 1
fi

"$notifier_bin" \
  -title "$title" \
  -message "$message" \
  -sender com.apple.Terminal \
  >/dev/null 2>&1 &!

/usr/bin/afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &!
