#!/usr/bin/env bash
# Claude Code statusline.
#
# Renders:
#   30.7k (1.1%)                    18% 3h19m
#
# Left  : context tokens (yellow) with percent of window (grey, in parens).
# Right : 5h API usage percent and time-to-reset (grey), right-aligned.
#
# API/subscription usage (rate_limits) is part of the JSON Claude Code passes
# on stdin, but it is only populated after the first API response of the
# session, and fetching it fresh from Anthropic's backend would require a
# network call on every render. So instead:
#   - a lightweight background refresher (statusline-usage-refresh.sh) is
#     kept alive per Claude Code session; whenever the statusline is invoked
#     with fresh rate_limits data, that data is handed to the refresher,
#     which atomically writes it to a cache file on a throttled interval.
#   - the statusline itself NEVER performs the write inline and NEVER waits
#     on the refresher; it only ever reads the cache file (or shows a
#     placeholder if the cache is missing/stale).

set -u

readonly CACHE_DIR="$HOME/.claude"
readonly CACHE_FILE="$CACHE_DIR/statusline-usage-cache.json"
readonly REFRESHER="$CACHE_DIR/statusline-usage-refresh.sh"
readonly CACHE_MAX_AGE_SECONDS=120
readonly SECONDS_PER_HOUR=3600
readonly SECONDS_PER_MINUTE=60

readonly COLOR_RESET=$'\033[0m'
readonly COLOR_TOKENS=$'\033[2;37m'    # white-dim
readonly COLOR_USAGE=$'\033[2;90m'     # grey-dim
readonly COLOR_GREY=$'\033[2;90m'      # grey-dim (separator)

input="$(cat)"

# Formats a token count like 30700 -> "30.7k", 1500000 -> "1.5M".
format_tokens() {
  local n="$1"

  if [ "$n" -ge 1000000 ]; then
    awk -v n="$n" 'BEGIN { printf "%.1fM", n/1000000 }'
  elif [ "$n" -ge 1000 ]; then
    awk -v n="$n" 'BEGIN { printf "%.1fk", n/1000 }'
  else
    printf '%d' "$n"
  fi
}

# --- context usage (from stdin JSON, no network) ---
# used_percentage in the payload is integer-rounded, so compute a fractional
# percent from the token counts and window size instead.
ctx_tokens="$(echo "$input" | jq -r '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)' 2>/dev/null)"

left_segment=""
if [ -n "$ctx_tokens" ] && [ "$ctx_tokens" -gt 0 ]; then
  left_segment="${COLOR_TOKENS}$(format_tokens "$ctx_tokens")${COLOR_RESET}"
fi

# --- API/subscription usage (cached, never blocks) ---
# Hand today's rate_limits (if any) to the background refresher and make
# sure a refresher process is alive for this session. Both are fire-and-
# forget: stdin/stdout/stderr are detached so the statusline never waits on
# them, and the refresher itself throttles writes to once every
# CACHE_MIN_WRITE_INTERVAL_SECONDS regardless of how often it's invoked.
# Backgrounding via `(cmd &)` in a subshell (rather than `setsid`, which
# isn't installed by default on macOS) is enough to detach the refresher
# from the statusline process: the subshell exits immediately, so the
# refresher is reparented to init and never keeps the statusline waiting.
# Invoked via `bash <script>` so it runs regardless of the executable bit.
if [ -f "$REFRESHER" ]; then
  rate_limits_json="$(echo "$input" | jq -c '.rate_limits // empty')"
  parent_pid="${PPID:-0}"
  ( bash "$REFRESHER" "$parent_pid" "$rate_limits_json" </dev/null >/dev/null 2>&1 & ) 2>/dev/null
fi

# Prints a file's mtime as a unix epoch, or 0 if it can't be read.
# GNU stat uses `-c %Y`; BSD/macOS stat uses `-f %m`. On GNU, `-f` means
# "filesystem info" and exits 0 with unrelated output, so GNU is tried
# first rather than relying on a `||` fallback to sort the two apart.
file_mtime() {
  local path="$1"

  stat -c '%Y' "$path" 2>/dev/null \
    || stat -f '%m' "$path" 2>/dev/null \
    || echo 0
}

# Formats a resets_at unix epoch as a compact countdown ("3h19m" or "19m").
format_resets_at() {
  local resets_at="$1"
  local now remaining hours minutes

  now="$(date +%s)"
  remaining=$(( resets_at - now ))

  if [ "$remaining" -le 0 ]; then
    echo "now"
    return 0
  fi

  hours=$(( remaining / SECONDS_PER_HOUR ))
  minutes=$(( (remaining % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE ))

  if [ "$hours" -gt 0 ]; then
    printf '%dh%02dm' "$hours" "$minutes"
  else
    printf '%dm' "$minutes"
  fi
}

# --- API/subscription usage (cached, never blocks) ---
api_text=""
if [ -f "$CACHE_FILE" ]; then
  cache_mtime="$(file_mtime "$CACHE_FILE")"
  now="$(date +%s)"
  cache_age=$(( now - cache_mtime ))

  cached_json="$(cat "$CACHE_FILE" 2>/dev/null)"
  five_hour="$(echo "$cached_json" | jq -r '.five_hour.used_percentage // empty' 2>/dev/null)"
  resets_at="$(echo "$cached_json" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)"

  if [ -n "$five_hour" ]; then
    api_text="$(printf '%.0f' "$five_hour")%"

    if [ -n "$resets_at" ]; then
      api_text="$api_text $(format_resets_at "$resets_at")"
    fi

    if [ "$cache_age" -gt "$CACHE_MAX_AGE_SECONDS" ]; then
      api_text="$api_text (stale)"
    fi
  fi
fi

if [ -z "$api_text" ]; then
  api_text="--%"
fi
right_segment="${COLOR_USAGE}${api_text}${COLOR_RESET}"

# Context and API usage separated by a dim grey pipe.
readonly SEPARATOR="${COLOR_GREY} | ${COLOR_RESET}"

printf '%s%s%s\n' "$left_segment" "$SEPARATOR" "$right_segment"
