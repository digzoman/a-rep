#!/bin/sh
set -eu

CYCLE="${1:-heartbeat}"
CONF="${2:-./config/arep.env}"

[ -f "$CONF" ] || { echo "Missing config: $CONF" >&2; exit 2; }
. "$CONF"

: "${AGENT_ID:?AGENT_ID is required}"
: "${AGENT_REPO:?AGENT_REPO is required}"
: "${AGENT_REPO_DIR:?AGENT_REPO_DIR is required}"
: "${A_REP_REPO:?A_REP_REPO is required}"
: "${A_REP_REF:=main}"
: "${A_REP_SKILL_PATH:?A_REP_SKILL_PATH is required}"
: "${EXECUTION_DRIVER:=codex}"
: "${EXECUTION_BIN:=$EXECUTION_DRIVER}"
: "${HEARTBEAT_MODE:=normal}"
: "${HEARTBEAT_FAST_MINUTES:=5}"
: "${HEARTBEAT_NORMAL_MINUTES:=15}"
: "${HEARTBEAT_SLOW_MINUTES:=60}"
: "${RUNTIME_DIR:=.arep}"
: "${LOG_DIR:=$RUNTIME_DIR/raw-logs}"
: "${LOCK_FILE:=$RUNTIME_DIR/primary.lock}"
: "${HEARTBEAT_LAST_FILE:=$RUNTIME_DIR/heartbeat.last}"

cd "$AGENT_REPO_DIR"
umask 077
mkdir -p "$RUNTIME_DIR" "$LOG_DIR"
mkdir -p "$(dirname "$LOCK_FILE")" "$(dirname "$HEARTBEAT_LAST_FILE")"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

interval_minutes() {
  if [ "$HEARTBEAT_MODE" = "paused" ]; then
    printf '0\n'
    return
  fi
  if [ "${DEADLINE_MODE:-false}" = "true" ]; then
    printf '%s\n' "$HEARTBEAT_FAST_MINUTES"
    return
  fi
  case "$HEARTBEAT_MODE" in
    fast) printf '%s\n' "$HEARTBEAT_FAST_MINUTES" ;;
    normal) printf '%s\n' "$HEARTBEAT_NORMAL_MINUTES" ;;
    slow) printf '%s\n' "$HEARTBEAT_SLOW_MINUTES" ;;
    *) echo "Invalid HEARTBEAT_MODE: $HEARTBEAT_MODE" >&2; exit 2 ;;
  esac
}

heartbeat_due() {
  [ "${HEARTBEAT_ENABLED:-true}" = "true" ] || return 1
  mins="$(interval_minutes)"
  [ "$mins" -gt 0 ] || return 1
  now="$(date +%s)"
  last=0
  [ -f "$HEARTBEAT_LAST_FILE" ] && last="$(cat "$HEARTBEAT_LAST_FILE" 2>/dev/null || printf '0')"
  case "$last" in *[!0-9]*|'') last=0 ;; esac
  [ "$now" -ge $((last + mins * 60)) ]
}

case "$CYCLE" in
  heartbeat)
    heartbeat_due || exit 0
    PROMPT_KIND="heartbeat"
    ;;
  rejuvenation)
    [ "${REJUVENATION_ENABLED:-true}" = "true" ] || exit 0
    [ "${DEADLINE_MODE:-false}" != "true" ] || exit 0
    PROMPT_KIND="rejuvenation"
    ;;
  *)
    echo "Usage: $0 heartbeat|rejuvenation [config]" >&2
    exit 2
    ;;
esac

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$LOG_DIR/${PROMPT_KIND}-${STAMP}.log"
PROMPT_FILE="$(dirname "$A_REP_SKILL_PATH")/prompts/${PROMPT_KIND}.md"
[ -f "$PROMPT_FILE" ] || { echo "Missing prompt: $PROMPT_FILE" >&2; exit 2; }

PROMPT="$(cat "$PROMPT_FILE")

Runtime coordinates for this invocation.
Agent ID: $AGENT_ID
Agent role: ${AGENT_ROLE:-unspecified}
Agent repository: $AGENT_REPO
Agent repository checkout: $AGENT_REPO_DIR
A Rep repository: $A_REP_REPO
A Rep ref: $A_REP_REF
A Rep skill path: $A_REP_SKILL_PATH
Cycle: $PROMPT_KIND
Heartbeat mode: $HEARTBEAT_MODE
Deadline mode: ${DEADLINE_MODE:-false}
"

run_agent() {
  case "$EXECUTION_DRIVER" in
    codex)
      if [ -n "${EXECUTION_MODEL:-}" ]; then
        "$EXECUTION_BIN" exec --model "$EXECUTION_MODEL" "$PROMPT"
      else
        "$EXECUTION_BIN" exec "$PROMPT"
      fi
      ;;
    opencode)
      if [ -n "${EXECUTION_MODEL:-}" ]; then
        "$EXECUTION_BIN" run --model "$EXECUTION_MODEL" "$PROMPT"
      else
        "$EXECUTION_BIN" run "$PROMPT"
      fi
      ;;
    *)
      echo "Unsupported EXECUTION_DRIVER: $EXECUTION_DRIVER" >&2
      return 64
      ;;
  esac
}

if run_agent >"$LOG" 2>&1; then
  cat "$LOG"
  if [ "$CYCLE" = "heartbeat" ]; then
    date +%s >"$HEARTBEAT_LAST_FILE"
  fi
  exit 0
else
  rc=$?
  cat "$LOG" >&2
  exit "$rc"
fi
