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
: "${HEARTBEAT_NORMAL_MINUTES:=30}"
: "${HEARTBEAT_SLOW_MINUTES:=60}"
: "${RUNTIME_DIR:=.arep}"
: "${LOG_DIR:=$RUNTIME_DIR/raw-logs}"
: "${LOCK_FILE:=$RUNTIME_DIR/primary.lock}"
: "${HEARTBEAT_LAST_FILE:=$RUNTIME_DIR/heartbeat.last}"
: "${PRIMARY_LAST_FILE:=$RUNTIME_DIR/primary.last}"
: "${EVENT_PENDING_FILE:=$RUNTIME_DIR/github-event.pending}"

cd "$AGENT_REPO_DIR"
umask 077
mkdir -p "$RUNTIME_DIR" "$LOG_DIR"
mkdir -p "$(dirname "$LOCK_FILE")" "$(dirname "$HEARTBEAT_LAST_FILE")" "$(dirname "$PRIMARY_LAST_FILE")" "$(dirname "$EVENT_PENDING_FILE")"

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

read_numeric_file() {
  file="$1"
  value=0
  [ -f "$file" ] && value="$(cat "$file" 2>/dev/null || printf '0')"
  case "$value" in *[!0-9]*|'') value=0 ;; esac
  printf '%s\n' "$value"
}

last_productive_primary_success() {
  heartbeat_last="$(read_numeric_file "$HEARTBEAT_LAST_FILE")"
  primary_last="$(read_numeric_file "$PRIMARY_LAST_FILE")"
  if [ "$primary_last" -gt "$heartbeat_last" ]; then
    printf '%s\n' "$primary_last"
  else
    printf '%s\n' "$heartbeat_last"
  fi
}

heartbeat_due() {
  [ "${HEARTBEAT_ENABLED:-true}" = "true" ] || return 1
  mins="$(interval_minutes)"
  [ "$mins" -gt 0 ] || return 1
  now="$(date +%s)"
  last="$(last_productive_primary_success)"
  [ "$now" -ge $((last + mins * 60)) ]
}

case "$CYCLE" in
  heartbeat)
    heartbeat_due || exit 0
    PROMPT_KIND="heartbeat"
    ;;
  event)
    [ "${EVENT_ENABLED:-true}" = "true" ] || exit 0
    [ "$HEARTBEAT_MODE" != "paused" ] || exit 0
    [ -s "$EVENT_PENDING_FILE" ] || exit 0
    PROMPT_KIND="event"
    ;;
  rejuvenation)
    [ "${REJUVENATION_ENABLED:-true}" = "true" ] || exit 0
    [ "${DEADLINE_MODE:-false}" != "true" ] || exit 0
    PROMPT_KIND="rejuvenation"
    ;;
  *)
    echo "Usage: $0 heartbeat|event|rejuvenation [config]" >&2
    exit 2
    ;;
esac

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_ID="${PROMPT_KIND}-${STAMP}"
PROVENANCE_PLATFORM_VALUE="${PROVENANCE_PLATFORM:-$EXECUTION_DRIVER}"
PROVENANCE_INSTANCE_VALUE="${PROVENANCE_INSTANCE:-runtime-$PROMPT_KIND}"
LOG="$LOG_DIR/${PROMPT_KIND}-${STAMP}.log"
PROMPT_FILE="$(dirname "$A_REP_SKILL_PATH")/prompts/${PROMPT_KIND}.md"
[ -f "$PROMPT_FILE" ] || { echo "Missing prompt: $PROMPT_FILE" >&2; exit 2; }

EVENT_HINT=""
EVENT_PENDING_CKSUM=""
if [ "$CYCLE" = "event" ]; then
  EVENT_HINT="$(cat "$EVENT_PENDING_FILE" 2>/dev/null || true)"
  EVENT_PENDING_CKSUM="$(cksum "$EVENT_PENDING_FILE" 2>/dev/null || true)"
fi

PROMPT="$(cat "$PROMPT_FILE")

Runtime coordinates for this invocation.
Agent ID: $AGENT_ID
Agent charter role: ${AGENT_ROLE:-unspecified}
Agent repository: $AGENT_REPO
Agent repository checkout: $AGENT_REPO_DIR
A Rep repository: $A_REP_REPO
A Rep ref: $A_REP_REF
A Rep skill path: $A_REP_SKILL_PATH
Cycle: $PROMPT_KIND
Heartbeat mode: $HEARTBEAT_MODE
Deadline mode: ${DEADLINE_MODE:-false}

Producer provenance for this PRIMARY invocation.
Agent: $AGENT_ID
Platform: $PROVENANCE_PLATFORM_VALUE
Role: PRIMARY
Instance: $PROVENANCE_INSTANCE_VALUE
Agent-Run: $RUN_ID
Use this exact provenance tuple and Agent-Run on material durable comments, handoffs, sanitized execution records, and agent-authored commits when practical, following references/PROVENANCE.md.
"

if [ "$CYCLE" = "event" ]; then
  PROMPT="$PROMPT

Deterministic event-wake hint. This is a routing hint, not authoritative work state.
Wake reason: github-change
Observed changes:
$EVENT_HINT
Inspect current GitHub reality before acting. Do not assume every observed change requires action."
fi

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
  now_success="$(date +%s)"
  if [ "$CYCLE" = "heartbeat" ]; then
    printf '%s\n' "$now_success" >"$HEARTBEAT_LAST_FILE"
  fi
  if [ "$CYCLE" = "heartbeat" ] || [ "$CYCLE" = "event" ]; then
    printf '%s\n' "$now_success" >"$PRIMARY_LAST_FILE"
  fi
  if [ "$CYCLE" = "event" ]; then
    current_cksum="$(cksum "$EVENT_PENDING_FILE" 2>/dev/null || true)"
    if [ -n "$EVENT_PENDING_CKSUM" ] && [ "$current_cksum" = "$EVENT_PENDING_CKSUM" ]; then
      rm -f "$EVENT_PENDING_FILE"
    fi
  fi
  exit 0
else
  rc=$?
  cat "$LOG" >&2
  exit "$rc"
fi
