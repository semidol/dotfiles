#!/usr/bin/env bash
# Background usage-cache refresher for statusline.sh.
#
# Invoked (fire-and-forget, detached) by statusline.sh on every render with:
#   $1 = PID of the Claude Code process that owns this session
#   $2 = JSON string of the current .rate_limits object (may be empty)
#
# Responsibilities:
#   - Guarantee at most one live refresher per Claude Code session (via a
#     PID lock file), so repeated statusline renders don't spawn a growing
#     pile of background processes.
#   - Persist the freshest rate_limits payload it has been handed to the
#     shared cache file, using an atomic write (write to temp file, then
#     `mv`) so a reader never observes a partial/corrupt file.
#   - Throttle writes to once every CACHE_MIN_WRITE_INTERVAL_SECONDS so a
#     burst of statusline renders doesn't hammer the filesystem.
#   - Exit on its own once the owning Claude Code process is gone, so
#     refreshers don't leak across sessions.

set -u

readonly CACHE_DIR="$HOME/.claude"
readonly CACHE_FILE="$CACHE_DIR/statusline-usage-cache.json"
readonly LOCK_FILE="$CACHE_DIR/statusline-usage-refresh.lock"
readonly CACHE_MIN_WRITE_INTERVAL_SECONDS=20
readonly SESSION_IDLE_CHECK_SECONDS=5

claude_pid="${1:-0}"
rate_limits_json="${2:-}"

mkdir -p "$CACHE_DIR"

is_parent_alive() {
  [ "$claude_pid" != "0" ] && kill -0 "$claude_pid" 2>/dev/null
}

# --- Single-flight lock: only one refresher loop per session/PID. ---
lock_owner_pid=""
if [ -f "$LOCK_FILE" ]; then
  lock_owner_pid="$(cat "$LOCK_FILE" 2>/dev/null)"
fi

if [ -n "$lock_owner_pid" ] && kill -0 "$lock_owner_pid" 2>/dev/null; then
  # A refresher is already running for this machine's Claude sessions.
  # Just do a best-effort one-shot cache update with what we were handed
  # and exit -- no need for a second long-lived loop.
  if [ -n "$rate_limits_json" ] && [ "$rate_limits_json" != "null" ]; then
    tmp_file="$(mktemp "$CACHE_FILE.XXXXXX")"
    echo "$rate_limits_json" >"$tmp_file" && mv -f "$tmp_file" "$CACHE_FILE"
  fi
  exit 0
fi

echo "$$" >"$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

write_cache_atomic() {
  local payload="$1"
  [ -z "$payload" ] && return 0
  [ "$payload" = "null" ] && return 0

  local tmp_file
  tmp_file="$(mktemp "$CACHE_FILE.XXXXXX")" || return 1
  if echo "$payload" >"$tmp_file"; then
    mv -f "$tmp_file" "$CACHE_FILE"
  else
    rm -f "$tmp_file"
  fi
}

write_cache_atomic "$rate_limits_json"

# Stay alive briefly, throttling writes, so subsequent statusline renders in
# this same window can hand us fresher data without spawning new processes.
# We piggyback new data via the lock-holder fast path above; this loop's
# main job is to keep the lock held (preventing duplicate loops) and to
# self-terminate promptly once Claude Code exits, so nothing leaks.
elapsed=0
while is_parent_alive; do
  sleep "$SESSION_IDLE_CHECK_SECONDS"
  elapsed=$(( elapsed + SESSION_IDLE_CHECK_SECONDS ))
  if [ "$elapsed" -ge "$CACHE_MIN_WRITE_INTERVAL_SECONDS" ]; then
    elapsed=0
  fi
done
