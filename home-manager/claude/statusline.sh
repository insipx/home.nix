#!/bin/bash

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; BLUE='\033[34m'; MAGENTA='\033[35m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
SEP=" ${DIM}|${RESET} "

function two_digit_pad() {
  local value="$1"
  [[ "$value" -lt 10 ]] && echo "0${value}" || echo "${value}"
}

function seconds_to_time() {
  local duration="$1"
  hours=$((duration / 3600))
  duration=$((duration - (hours * 3600)))
  minutes=$((duration / 60))
  seconds=$((duration - (minutes * 60)))
  echo -e "$(two_digit_pad "${hours}"):$(two_digit_pad "${minutes}"):$(two_digit_pad "${seconds}")"
}

function color() {
  local value="$1"
  local extra="$2"
  local c="$GREEN"
  if [ "$value" -ge 90 ]; then c="$RED"
  elif [ "$value" -ge 70 ]; then c="$YELLOW"
  fi
  echo -e "${c}${value}${extra}${RESET}"
}

function pace_color() {
  local value="$1"
  local threshold="$2"
  local extra="$3"
  local c="$RED"
  [ "$value" -le "$threshold" ] && c="$GREEN"
  echo -e "${c}${value}${extra}${RESET}"
}

function good_color() {
  local value="$1"
  local extra="$2"
  local c="$RED"
  if [ "$value" -ge 90 ]; then c="$GREEN"
  elif [ "$value" -ge 70 ]; then c="$YELLOW"
  fi
  echo -e "${c}${value}${extra}${RESET}"
}

input=$(cat)
NOW=$(date +%s)

echo "${input}" > ~/.claude/statusline.input

IFS=$'\t' read -r MODEL DIR COST PCT DURATION_MS API_DURATION_MS LINES_ADDED LINES_REMOVED CACHE_READ CACHE_CREATE NEW_INPUT FIVE_HOUR_USED_PCT FIVE_HOUR_RESET_TIME SEVEN_DAY_USED_PCT SEVEN_DAY_RESET_TIME < <(echo "$input" | jq -r '[
  .model.display_name,
  .workspace.current_dir,
  (.cost.total_cost_usd // 0),
  ((.context_window.used_percentage // 0) | floor),
  (.cost.total_duration_ms // 0),
  (.cost.total_api_duration_ms // 0),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  (.context_window.current_usage.cache_read_input_tokens // 0),
  (.context_window.current_usage.cache_creation_input_tokens // 0),
  (.context_window.current_usage.input_tokens // 0),
  ((.rate_limits.five_hour.used_percentage // 0) | floor),
  (.rate_limits.five_hour.resets_at // 0),
  ((.rate_limits.seven_day.used_percentage // 0) | floor),
  (.rate_limits.seven_day.resets_at // 0)
] | @tsv')

TOTAL_DURATION_FMT=$(seconds_to_time "$((DURATION_MS / 1000))")
API_DURATION_FMT=$(seconds_to_time "$((API_DURATION_MS / 1000))")

CACHE_TOTAL=$((CACHE_READ + CACHE_CREATE + NEW_INPUT))
CACHE_HIT_PCT=0
[ "$CACHE_TOTAL" -gt 0 ] && CACHE_HIT_PCT=$((CACHE_READ * 100 / CACHE_TOTAL))

API_PCT=0
[ "$DURATION_MS" -gt 0 ] && API_PCT=$((API_DURATION_MS * 100 / DURATION_MS))

BURN_RATE=$(awk -v c="$COST" -v d="$DURATION_MS" 'BEGIN { if (d > 0) printf "%.2f", c * 3600000 / d; else printf "0.00" }')
API_BURN_RATE=$(awk -v c="$COST" -v d="$API_DURATION_MS" 'BEGIN { if (d > 0) printf "%.2f", c * 3600000 / d; else printf "0.00" }')

DIFF_FMT="${GREEN}+${LINES_ADDED}${RESET}/${RED}-${LINES_REMOVED}${RESET}"



# Pick bar color based on context usage
if [ "$PCT" -ge 60 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 40 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

HALVES=$((PCT / 5))
FULL_CELLS=$((HALVES / 2))
HAS_HALF=$((HALVES % 2))
EMPTY_CELLS=$((10 - FULL_CELLS - HAS_HALF))
printf -v FILL "%${FULL_CELLS}s"; printf -v PAD "%${EMPTY_CELLS}s"
HALF_CHAR=""
[ "$HAS_HALF" -eq 1 ] && HALF_CHAR="▌"
BAR="${FILL// /█}${HALF_CHAR}${PAD// /░}"

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH="${SEP}🌿 ${GREEN}$(git branch --show-current 2>/dev/null)${RESET}"

COST_FMT=$(printf '$%.2f' "$COST")

FIVE_HOUR_LEFT="$((FIVE_HOUR_RESET_TIME - NOW))"
[ "$FIVE_HOUR_LEFT" -lt 0 ] && FIVE_HOUR_LEFT=0
FIVE_HOUR_RESET_TIME_FMT=$(seconds_to_time "$FIVE_HOUR_LEFT")
FIVE_HOUR_ELAPSED_PCT=$((100 - (FIVE_HOUR_LEFT * 100 / 18000)))
FIVE_HOUR="⏳ $(pace_color "$FIVE_HOUR_USED_PCT" "$FIVE_HOUR_ELAPSED_PCT" "%") (${MAGENTA}${FIVE_HOUR_RESET_TIME_FMT}${RESET} ${BLUE}${FIVE_HOUR_ELAPSED_PCT}%${RESET})"

SEVEN_DAY_LEFT="$((SEVEN_DAY_RESET_TIME - NOW))"
[ "$SEVEN_DAY_LEFT" -lt 0 ] && SEVEN_DAY_LEFT=0
SEVEN_DAY_RESET_TIME_FMT=$(seconds_to_time "$SEVEN_DAY_LEFT")
SEVEN_DAY_ELAPSED_PCT=$((100 - (SEVEN_DAY_LEFT * 100 / 604800)))
SEVEN_DAY="📅 $(pace_color "$SEVEN_DAY_USED_PCT" "$SEVEN_DAY_ELAPSED_PCT" "%") (${MAGENTA}${SEVEN_DAY_RESET_TIME_FMT}${RESET} ${BLUE}${SEVEN_DAY_ELAPSED_PCT}%${RESET})"

COLS=${COLUMNS:-240}

MODEL_FMT="${CYAN}[$MODEL]${RESET}"
[ "$COLS" -lt 220 ] && MODEL_FMT="${CYAN}[${MODEL% (*}]${RESET}"

CACHE_SECTION="${SEP}💾 $(good_color "$CACHE_HIT_PCT" "%")"
DIFF_SECTION="${SEP}✏️ ${DIFF_FMT}"
BURN_SECTION=" 🔥 ${YELLOW}\$${BURN_RATE}/hr${RESET} ${CYAN}\$${API_BURN_RATE}/api-hr${RESET}"
API_SECTION=" 🤖 ${MAGENTA}${API_DURATION_FMT}${RESET} ${BLUE}${API_PCT}%${RESET}"
SEVEN_DAY_SECTION="${SEP}${SEVEN_DAY}"

[ "$COLS" -lt 200 ] && CACHE_SECTION=""
[ "$COLS" -lt 180 ] && DIFF_SECTION=""
[ "$COLS" -lt 160 ] && API_SECTION=""
[ "$COLS" -lt 140 ] && BURN_SECTION=""
[ "$COLS" -lt 120 ] && SEVEN_DAY_SECTION=""

OUT="${MODEL_FMT} 📁 ${BOLD}${MAGENTA}${DIR##*/}${RESET}${BRANCH}"
OUT+="${SEP}🧠 ${BAR_COLOR}${BAR}${RESET} ${PCT}%"
OUT+="${CACHE_SECTION}${DIFF_SECTION}"
OUT+="${SEP}💰 ${YELLOW}${COST_FMT}${RESET}${BURN_SECTION}"
OUT+="${SEP}⏱️ ${MAGENTA}${TOTAL_DURATION_FMT}${RESET}${API_SECTION}"
OUT+="${SEP}${FIVE_HOUR}${SEVEN_DAY_SECTION}"
echo -e "$OUT"
