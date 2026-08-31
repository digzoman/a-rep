#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
A_REP_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
LAUNCHER="$A_REP_ROOT/runtime/arep-run.sh"
SKILL="$A_REP_ROOT/SKILL.md"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
AGENT="$TMP/agent"
CONF="$AGENT/config/arep.env"
FAKE_BIN="$TMP/fake-codex"
COUNT="$TMP/count"
PROMPT_CAPTURE="$TMP/prompt"
mkdir -p "$AGENT/config"

cat > "$FAKE_BIN" <<'FAKE'
#!/bin/sh
printf 'run\n' >> "${FAKE_COUNT_FILE:?}"
last=""
for arg in "$@"; do last="$arg"; done
[ -z "${FAKE_PROMPT_FILE:-}" ] || printf '%s\n' "$last" > "$FAKE_PROMPT_FILE"
if [ -n "${FAKE_APPEND_PENDING:-}" ]; then
  printf '%s\n' "$FAKE_APPEND_PENDING" >> "${FAKE_PENDING_FILE:?}"
fi
exit "${FAKE_EXIT_CODE:-0}"
FAKE
chmod +x "$FAKE_BIN"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_eq() { [ "$1" = "$2" ] || fail "$3: expected '$1', got '$2'"; }
assert_prompt_contains() { grep -E "$1" "$PROMPT_CAPTURE" >/dev/null || fail "$2"; }
runs() { [ -f "$COUNT" ] && wc -l < "$COUNT" | tr -d ' ' || printf '0\n'; }
reset_state() { rm -f "$COUNT" "$PROMPT_CAPTURE"; rm -rf "$AGENT/.arep"; mkdir -p "$AGENT/.arep"; }

write_config() {
  mode="$1"; deadline="$2"; rejuvenation="$3"
  cat > "$CONF" <<EOFCONF
AGENT_ID="test"
AGENT_ROLE="Test"
AGENT_REPO="example/test"
AGENT_REPO_DIR="$AGENT"
A_REP_REPO="digzoman/a-rep"
A_REP_REF="main"
A_REP_SKILL_PATH="$SKILL"
EXECUTION_DRIVER="codex"
EXECUTION_BIN="$FAKE_BIN"
EXECUTION_MODEL=""
PROVENANCE_PLATFORM=""
PROVENANCE_INSTANCE=""
HEARTBEAT_ENABLED="true"
HEARTBEAT_MODE="$mode"
HEARTBEAT_FAST_MINUTES="5"
HEARTBEAT_NORMAL_MINUTES="30"
HEARTBEAT_SLOW_MINUTES="60"
DEADLINE_MODE="$deadline"
EVENT_ENABLED="true"
REJUVENATION_ENABLED="$rejuvenation"
RUNTIME_DIR=".arep"
LOG_DIR=".arep/raw-logs"
LOCK_FILE=".arep/primary.lock"
HEARTBEAT_LAST_FILE=".arep/heartbeat.last"
PRIMARY_LAST_FILE=".arep/primary.last"
EVENT_PENDING_FILE=".arep/github-event.pending"
EOFCONF
}

run_cycle() {
  cycle="$1"; code="${2:-0}"
  FAKE_COUNT_FILE="$COUNT" FAKE_PROMPT_FILE="$PROMPT_CAPTURE" FAKE_EXIT_CODE="$code" FAKE_PENDING_FILE="$AGENT/.arep/github-event.pending" FAKE_APPEND_PENDING="${FAKE_APPEND_PENDING:-}" sh "$LAUNCHER" "$cycle" "$CONF" >/dev/null 2>&1
}

# Missing config fails clearly.
set +e
sh "$LAUNCHER" heartbeat "$TMP/missing.env" >/dev/null 2>&1
rc=$?
set -e
assert_eq 2 "$rc" "missing config exit"

# Normal default/example cadence is 30 minutes: recent skips, >30m runs.
reset_state; write_config normal false true
date +%s > "$AGENT/.arep/heartbeat.last"
run_cycle heartbeat
assert_eq 0 "$(runs)" "normal due-skip"
printf '%s\n' "$(( $(date +%s) - 1801 ))" > "$AGENT/.arep/heartbeat.last"
run_cycle heartbeat
assert_eq 1 "$(runs)" "normal due run"

# Provenance/run ID remains injected.
assert_prompt_contains '^Agent: test$' "heartbeat provenance agent missing"
assert_prompt_contains '^Platform: codex$' "heartbeat provenance platform fallback missing"
assert_prompt_contains '^Role: PRIMARY$' "heartbeat provenance role missing"
assert_prompt_contains '^Instance: runtime-heartbeat$' "heartbeat provenance instance fallback missing"
assert_prompt_contains '^Agent-Run: heartbeat-[0-9]{8}T[0-9]{6}Z$' "heartbeat run ID malformed"

# Explicit provenance labels override launcher fallbacks.
reset_state; write_config normal false true
cat >> "$CONF" <<'EOFPROV'
PROVENANCE_PLATFORM="Codex"
PROVENANCE_INSTANCE="test-vm"
EOFPROV
run_cycle heartbeat
assert_prompt_contains '^Platform: Codex$' "explicit provenance platform missing"
assert_prompt_contains '^Instance: test-vm$' "explicit provenance instance missing"

# Fast and slow modes remain explicit; deadline accelerates to fast; paused wins.
reset_state; write_config fast false true
printf '%s\n' "$(( $(date +%s) - 301 ))" > "$AGENT/.arep/heartbeat.last"
run_cycle heartbeat
assert_eq 1 "$(runs)" "fast due run"
reset_state; write_config slow false true
printf '%s\n' "$(( $(date +%s) - 3601 ))" > "$AGENT/.arep/heartbeat.last"
run_cycle heartbeat
assert_eq 1 "$(runs)" "slow due run"
reset_state; write_config normal true true
printf '%s\n' "$(( $(date +%s) - 301 ))" > "$AGENT/.arep/heartbeat.last"
run_cycle heartbeat
assert_eq 1 "$(runs)" "deadline acceleration"
reset_state; write_config paused true true
run_cycle heartbeat
assert_eq 0 "$(runs)" "paused heartbeat suppression"

# Failure does not advance heartbeat or primary success state.
reset_state; write_config normal false true
set +e
run_cycle heartbeat 23
rc=$?
set -e
assert_eq 23 "$rc" "failed heartbeat exit"
[ ! -f "$AGENT/.arep/heartbeat.last" ] || fail "failed heartbeat advanced heartbeat timestamp"
[ ! -f "$AGENT/.arep/primary.last" ] || fail "failed heartbeat advanced primary timestamp"

# Successful heartbeat advances both heartbeat.last and primary.last.
reset_state; write_config normal false true
run_cycle heartbeat
[ -f "$AGENT/.arep/heartbeat.last" ] || fail "heartbeat.last missing"
[ -f "$AGENT/.arep/primary.last" ] || fail "primary.last missing"
find "$AGENT/.arep/raw-logs" -type f -name 'heartbeat-*.log' | grep . >/dev/null || fail "raw heartbeat log missing"

# A second immediate heartbeat is due-skipped.
run_cycle heartbeat
assert_eq 1 "$(runs)" "immediate heartbeat due-skip"

# Event without pending state is a cheap no-op.
reset_state; write_config normal false true
run_cycle event
assert_eq 0 "$(runs)" "event without pending"

# Event wake bypasses heartbeat due time, carries hint, gets event run ID, clears unchanged pending, and records primary.last.
reset_state; write_config normal false true
printf '%s\n' "- New Issue #21: Test (https://example.invalid/21)" > "$AGENT/.arep/github-event.pending"
date +%s > "$AGENT/.arep/heartbeat.last"
run_cycle event
assert_eq 1 "$(runs)" "event wake run"
assert_prompt_contains '^Cycle: event$' "event cycle missing"
assert_prompt_contains '^Agent-Run: event-[0-9]{8}T[0-9]{6}Z$' "event run ID malformed"
assert_prompt_contains '^Wake reason: github-change$' "event wake reason missing"
assert_prompt_contains 'New Issue #21' "event hint missing"
[ ! -f "$AGENT/.arep/github-event.pending" ] || fail "successful unchanged event did not clear pending"
[ -f "$AGENT/.arep/primary.last" ] || fail "successful event did not write primary.last"

# If new pending input arrives while an event run is executing, it is not discarded.
reset_state; write_config normal false true
printf '%s\n' "- Original event" > "$AGENT/.arep/github-event.pending"
FAKE_APPEND_PENDING='- Event arriving during run' run_cycle event
[ -s "$AGENT/.arep/github-event.pending" ] || fail "concurrent pending input was lost"
grep -q 'Event arriving during run' "$AGENT/.arep/github-event.pending" || fail "new pending input missing after event success"

# A successful event postpones the normal backup heartbeat even if heartbeat.last is old.
printf '%s\n' "$(( $(date +%s) - 7200 ))" > "$AGENT/.arep/heartbeat.last"
run_cycle heartbeat
assert_eq 1 "$(runs)" "event should postpone immediate backup heartbeat"

# Event failure preserves pending state and does not advance primary.last.
reset_state; write_config normal false true
printf '%s\n' "- New comment: https://example.invalid/c" > "$AGENT/.arep/github-event.pending"
set +e
run_cycle event 29
rc=$?
set -e
assert_eq 29 "$rc" "failed event exit"
[ -s "$AGENT/.arep/github-event.pending" ] || fail "failed event lost pending state"
[ ! -f "$AGENT/.arep/primary.last" ] || fail "failed event advanced primary.last"

# Paused suppresses event execution while preserving pending state.
reset_state; write_config paused false true
printf '%s\n' "- New comment: https://example.invalid/c" > "$AGENT/.arep/github-event.pending"
run_cycle event
assert_eq 0 "$(runs)" "paused event suppression"
[ -s "$AGENT/.arep/github-event.pending" ] || fail "paused event lost pending state"

# Shared PRIMARY lock suppresses event/heartbeat overlap.
reset_state; write_config normal false true
printf '%s\n' "- New comment: https://example.invalid/c" > "$AGENT/.arep/github-event.pending"
(
  exec 8>"$AGENT/.arep/primary.lock"
  flock 8
  sleep 2
) &
locker=$!
sleep 1
run_cycle event
assert_eq 0 "$(runs)" "PRIMARY lock contention"
[ -s "$AGENT/.arep/github-event.pending" ] || fail "lock contention lost pending state"
wait "$locker"

# Rejuvenation behavior remains unchanged.
reset_state; write_config normal false false
run_cycle rejuvenation
assert_eq 0 "$(runs)" "rejuvenation disabled"
reset_state; write_config normal true true
run_cycle rejuvenation
assert_eq 0 "$(runs)" "rejuvenation deadline suppression"
reset_state; write_config normal false true
run_cycle rejuvenation
assert_eq 1 "$(runs)" "rejuvenation execution"
find "$AGENT/.arep/raw-logs" -type f -name 'rejuvenation-*.log' | grep . >/dev/null || fail "raw rejuvenation log missing"
assert_prompt_contains '^Instance: runtime-rejuvenation$' "rejuvenation provenance instance missing"
assert_prompt_contains '^Agent-Run: rejuvenation-[0-9]{8}T[0-9]{6}Z$' "rejuvenation run ID malformed"

echo "A Rep runtime tests passed."
