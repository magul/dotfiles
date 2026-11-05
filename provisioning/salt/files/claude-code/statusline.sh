#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
CTX=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# rate_limits is present only for Claude.ai subscribers, after the first API response
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'

color_for() {
  awk -v p="$1" 'BEGIN { print (p >= 90) ? "\033[31m" : (p >= 70) ? "\033[33m" : "\033[32m" }'
}

# "3h20m" until the window resets
until_reset() {
  local mins=$(( ($1 - $(date +%s)) / 60 ))
  [ "$mins" -lt 0 ] && mins=0
  if [ "$mins" -ge 1440 ]; then
    echo "$((mins / 1440))d$(((mins % 1440) / 60))h"
  elif [ "$mins" -ge 60 ]; then
    echo "$((mins / 60))h$((mins % 60))m"
  else
    echo "${mins}m"
  fi
}

BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=" ${DIM}|${RESET} $(git branch --show-current 2>/dev/null)"
fi

LINE1="${CYAN}[${MODEL}]${RESET} ${DIR##*/}${BRANCH}"
[ -n "$CTX" ] && LINE1="${LINE1} ${DIM}|${RESET} ctx $(color_for "$CTX")$(printf '%.0f' "$CTX")%%${RESET}"

LINE2=""
if [ -n "$FIVE_H" ]; then
  LINE2="5h $(color_for "$FIVE_H")$(printf '%.0f' "$FIVE_H")%%${RESET}"
  [ -n "$FIVE_H_RESET" ] && LINE2="${LINE2} ${DIM}(resets in $(until_reset "$FIVE_H_RESET"))${RESET}"
fi
if [ -n "$WEEK" ]; then
  [ -n "$LINE2" ] && LINE2="${LINE2}  ${DIM}|${RESET}  "
  LINE2="${LINE2}week $(color_for "$WEEK")$(printf '%.0f' "$WEEK")%%${RESET}"
  [ -n "$WEEK_RESET" ] && LINE2="${LINE2} ${DIM}(resets in $(until_reset "$WEEK_RESET"))${RESET}"
fi

printf "${LINE1}\n"
[ -n "$LINE2" ] && printf "${LINE2}\n"
exit 0
