#!/bin/bash
# Monitor sensitive directories and send notifications + log
# NOTIFY_SEND_PATH must be set by caller

LOG_FILE="$HOME/.local/var/log/sensitive-access.log"
COOLDOWN=5  # seconds between notifications per directory

mkdir -p "$(dirname "$LOG_FILE")"

declare -A last_notify
declare -A event_count

while IFS= read -r line; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $line" >> "$LOG_FILE"

  # Extract directory (second field)
  dir=$(echo "$line" | awk '{print $2}')
  now=$(date +%s)

  # Increment event count for this directory
  event_count[$dir]=$(( ${event_count[$dir]:-0} + 1 ))

  # Check cooldown
  last=${last_notify[$dir]:-0}
  if (( now - last >= COOLDOWN )); then
    count=${event_count[$dir]}
    last_notify[$dir]=$now
    event_count[$dir]=0
    "$NOTIFY_SEND_PATH" -t 6000 -u critical \
      "Sensitive File Access" \
      "$dir ($count events)"
  fi
done < <(inotifywait -m -r -q \
  --format '%T %w %e' \
  --timefmt '%s' \
  -e access,modify,open \
  "$HOME/.ssh" \
  "$HOME/.aws" \
  "$HOME/.gnupg" 2>/dev/null)
