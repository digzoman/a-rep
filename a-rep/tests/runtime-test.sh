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
mkdir -p "$AGENT/config"

cat > "$FAKE_BIN" <<'FAKE'
#!/bin/sh
printf '%s\n' "$*" >> "${FAKE_COUNT_FILE:?}"
exit "${FAKE_EXIT_CODE:-0}"
FAKE
chmod +x "$FAKE_BIN"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  [ "$1" = "$2" ] || fail "$3: expected '$1', got '$2'"
}

runs() {
  if [ -f "$COUNT" ]; then
    wc -l < "$COUNT" | tr -d ' '
  else
    printf '0\n'
  fi
}

reset_state() {
  rm -f "$COUNT"
  rm -rf "$AGENT/.arep"
  mkdir -p "$AGENT/.arep"
}

write_config() {
  mode="$1"
  deadline="$2"
  rejuvenation="$3"
  cat > "$CONF" <<EOF
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
HEARTBEAT_ENABLED="true"
HEARTBEAT_MODE="$mode"
HEARTBEAT_FAST_MINUTES="5"
HEARTBEAT_NORMAL_MINUTES="15"
HEARTBEAT_SLOW_MINUTES="60"
DEADLINE_MODE="$deadline"
REJUVENATION_ENABLED="$rejuvenation"
RUNTIME_DIR=".arep"
LOG_DIR=".arep/raw-logs"
LOCK_FILE=".arep/primary.lock"
HEARTBEAT_LAST_FILE=".arep/heartbeat.last"
EOF
}

run_heartbeat() {
  FAKE_COUNT_FILE="$COUNT" FAKE_EXIT_CODE="${1:-0}" sh "$LAUNCHER" heartbeat "$CONF" >/dev/null 2>&1
}

run_rejuvenation() {
  FAKE_COUNT_FILE="$COUNT" FAKE_EXIT_CODE="${1:-0}" sh "$LAUNCHER" rejuvenation "$CONF" >/dev/null 2>&1
}

# Missing configuration must fail clearly.
set +e
sh "$LAUNCHER" heartbeat "$TMP/missing.env" >/dev/null 2>&1
rc=$?
set -e
assert_eq 2 "$rc" "missing config exit"

# Normal cadence: recent timestamp skips, old timestamp runs.
reset_state
write_config normal false true
date +%s > "$AGENT/.arep/heartbeat.last"
run_heartbeat
assert_eq 0 "$(runs)" "normal due-skip"
printf '%s\n' "$(( $(date +%s) - 901 ))" > "$AGENT/.arep/heartbeat.last"
run_heartbeat
assert_eq 1 "$(runs)" "normal due run"

# Fast cadence.
reset_state
write_config fast false true
printf '%s\n' "$(( $(date +%s) - 301 ))" > "$AGENT/.arep/heartbeat.last"
run_heartbeat
assert_eq 1 "$(runs)" "fast due run"

# Slow cadence.
reset_state
write_config slow false true
printf '%s\n' "$(( $(date +%s) - 3601 ))" > "$AGENT/.arep/heartbeat.last"
run_heartbeat
assert_eq 1 "$(runs)" "slow due run"

# Paused always suppresses heartbeat.
reset_state
write_config paused false true
run_heartbeat
assert_eq 0 "$(runs)" "paused suppression"

# Deadline mode accelerates normal to fast, but paused still wins.
reset_state
write_config normal true true
printf '%s\n' "$(( $(date +%s) - 301 ))" > "$AGENT/.arep/heartbeat.last"
run_heartbeat
assert_eq 1 "$(runs)" "deadline acceleration"
reset_state
write_config paused true true
run_heartbeat
assert_eq 0 "$(runs)" "paused deadline suppression"

# Failed execution propagates failure and must not advance success state.
reset_state
write_config normal false true
set +e
FAKE_COUNT_FILE="$COUNT" FAKE_EXIT_CODE=23 sh "$LAUNCHER" heartbeat "$CONF" >/dev/null 2>&1
rc=$?
set -e
assert_eq 23 "$rc" "failed execution exit"
[ ! -f "$AGENT/.arep/heartbeat.last" ] || fail "failed execution advanced heartbeat timestamp"
assert_eq 1 "$(runs)" "failed execution invocation"

# Successful execution advances timestamp and writes raw output under raw-logs.
reset_state
write_config normal false true
run_heartbeat
[ -f "$AGENT/.arep/heartbeat.last" ] || fail "successful heartbeat did not write timestamp"
find "$AGENT/.arep/raw-logs" -type f -name 'heartbeat-*.log' | grep . >/dev/null || fail "raw heartbeat log missing"

# A second immediate invocation is due-skipped.
run_heartbeat
assert_eq 1 "$(runs)" "immediate due-skip"

# Shared PRIMARY lock prevents a second mutator.
reset_state
write_config normal false true
(
  exec 8>"$AGENT/.arep/primary.lock"
  flock 8
  sleep 2
) &
locker=$!
sleep 1
run_heartbeat
assert_eq 0 "$(runs)" "PRIMARY lock contention"
wait "$locker"

# Rejuvenation disabled and deadline suppression.
reset_state
write_config normal false false
run_rejuvenation
assert_eq 0 "$(runs)" "rejuvenation disabled"
reset_state
write_config normal true true
run_rejuvenation
assert_eq 0 "$(runs)" "rejuvenation deadline suppression"

# Enabled rejuvenation runs and uses raw-logs.
reset_state
write_config normal false true
run_rejuvenation
assert_eq 1 "$(runs)" "rejuvenation execution"
find "$AGENT/.arep/raw-logs" -type f -name 'rejuvenation-*.log' | grep . >/dev/null || fail "raw rejuvenation log missing"

echo "A Rep runtime tests passed."
