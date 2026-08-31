#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
A_REP_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
WATCHER="$A_REP_ROOT/runtime/arep-watch-github.sh"
SKILL="$A_REP_ROOT/SKILL.md"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
AGENT="$TMP/agent"
CONF="$AGENT/config/arep.env"
FAKE_CODEX="$TMP/fake-codex"
FAKE_GH="$TMP/fake-gh"
COUNT="$TMP/count"
PROMPT_CAPTURE="$TMP/prompt"
COMMENTS="$TMP/comments"
ISSUES="$TMP/issues"
REOPENED="$TMP/reopened"
mkdir -p "$AGENT/config"
: > "$COMMENTS"; : > "$ISSUES"; : > "$REOPENED"

cat > "$FAKE_CODEX" <<'FAKE'
#!/bin/sh
printf 'run\n' >> "${FAKE_COUNT_FILE:?}"
last=""
for arg in "$@"; do last="$arg"; done
printf '%s\n' "$last" > "${FAKE_PROMPT_FILE:?}"
exit 0
FAKE
chmod +x "$FAKE_CODEX"

cat > "$FAKE_GH" <<'FAKE'
#!/bin/sh
endpoint="${2:-}"
case "$endpoint" in
  *issues/comments*)
    [ "${FAKE_GH_FAIL:-}" != "comments" ] || exit 41
    cat "${FAKE_COMMENTS_FILE:?}"
    ;;
  *issues/events*)
    [ "${FAKE_GH_FAIL:-}" != "events" ] || exit 42
    cat "${FAKE_REOPENED_FILE:?}"
    ;;
  *issues\?*)
    [ "${FAKE_GH_FAIL:-}" != "issues" ] || exit 43
    cat "${FAKE_ISSUES_FILE:?}"
    ;;
  *) exit 44 ;;
esac
FAKE
chmod +x "$FAKE_GH"

cat > "$CONF" <<EOFCONF
AGENT_ID="test"
AGENT_ROLE="Test"
AGENT_REPO="example/test"
AGENT_REPO_DIR="$AGENT"
A_REP_REPO="digzoman/a-rep"
A_REP_REF="main"
A_REP_SKILL_PATH="$SKILL"
EXECUTION_DRIVER="codex"
EXECUTION_BIN="$FAKE_CODEX"
EXECUTION_MODEL=""
PROVENANCE_PLATFORM="Codex"
PROVENANCE_INSTANCE="test-vm"
HEARTBEAT_ENABLED="true"
HEARTBEAT_MODE="normal"
HEARTBEAT_FAST_MINUTES="5"
HEARTBEAT_NORMAL_MINUTES="30"
HEARTBEAT_SLOW_MINUTES="60"
DEADLINE_MODE="false"
EVENT_ENABLED="true"
GITHUB_WATCH_ENABLED="true"
GITHUB_WATCH_BIN="$FAKE_GH"
REJUVENATION_ENABLED="false"
RUNTIME_DIR=".arep"
LOG_DIR=".arep/raw-logs"
LOCK_FILE=".arep/primary.lock"
HEARTBEAT_LAST_FILE=".arep/heartbeat.last"
PRIMARY_LAST_FILE=".arep/primary.last"
EVENT_PENDING_FILE=".arep/github-event.pending"
GITHUB_WATCH_CURSOR_FILE=".arep/github-watch.cursor"
GITHUB_WATCH_LOCK_FILE=".arep/github-watch.lock"
EOFCONF

fail() { echo "FAIL: $*" >&2; exit 1; }
runs() { [ -f "$COUNT" ] && wc -l < "$COUNT" | tr -d ' ' || printf '0\n'; }
run_watch() {
  FAKE_COUNT_FILE="$COUNT" FAKE_PROMPT_FILE="$PROMPT_CAPTURE" \
  FAKE_COMMENTS_FILE="$COMMENTS" FAKE_ISSUES_FILE="$ISSUES" FAKE_REOPENED_FILE="$REOPENED" \
  FAKE_GH_FAIL="${1:-}" sh "$WATCHER" "$CONF" >/dev/null 2>&1
}
reset_outputs() { rm -f "$COUNT" "$PROMPT_CAPTURE" "$AGENT/.arep/github-event.pending"; : > "$COMMENTS"; : > "$ISSUES"; : > "$REOPENED"; }
set_old_cursor() { mkdir -p "$AGENT/.arep"; printf '%s\n' '2026-01-01T00:00:00Z' > "$AGENT/.arep/github-watch.cursor"; }

# First run initializes cursor and never replays history.
run_watch
[ -f "$AGENT/.arep/github-watch.cursor" ] || fail "cursor not initialized"
[ "$(runs)" = "0" ] || fail "first-run cursor initialization woke agent"

# No changes exits without model execution.
reset_outputs; set_old_cursor
run_watch
[ "$(runs)" = "0" ] || fail "no-change poll woke agent"

# External/unlabelled comment produces one event wake.
reset_outputs; set_old_cursor
printf '%s\t%s\n' 'https://example.invalid/comments/1' 'Human comment' > "$COMMENTS"
run_watch
[ "$(runs)" = "1" ] || fail "external comment did not wake exactly once"
grep -q 'New or updated Issue comment' "$PROMPT_CAPTURE" || fail "external comment hint missing"
[ ! -f "$AGENT/.arep/github-event.pending" ] || fail "successful event left unchanged pending file"

# Clearly self-produced PRIMARY comment on same platform is suppressed.
reset_outputs; set_old_cursor
printf '%s\t%s\n' 'https://example.invalid/comments/2' '[Fred | Codex | PRIMARY | test-vm]' > "$COMMENTS"
run_watch
[ "$(runs)" = "0" ] || fail "self PRIMARY comment caused loop wake"

# Worker/Guardian-style provenance is not suppressed.
reset_outputs; set_old_cursor
printf '%s\t%s\n' 'https://example.invalid/comments/3' '[Fred | Codex | Worker | task-1]' > "$COMMENTS"
run_watch
[ "$(runs)" = "1" ] || fail "Worker comment should wake PRIMARY"

# New Issue wakes PRIMARY.
reset_outputs; set_old_cursor
printf '%s\t%s\t%s\n' '23' 'https://example.invalid/issues/23' 'New work' > "$ISSUES"
run_watch
[ "$(runs)" = "1" ] || fail "new Issue did not wake PRIMARY"

# Reopened Issue wakes PRIMARY.
reset_outputs; set_old_cursor
printf '%s\t%s\n' '23' 'https://example.invalid/issues/23' > "$REOPENED"
run_watch
[ "$(runs)" = "1" ] || fail "reopened Issue did not wake PRIMARY"

# Multiple changes in one poll coalesce into one event execution.
reset_outputs; set_old_cursor
printf '%s\t%s\n%s\t%s\n' \
  'https://example.invalid/comments/4' 'Human one' \
  'https://example.invalid/comments/5' 'Human two' > "$COMMENTS"
printf '%s\t%s\t%s\n' '24' 'https://example.invalid/issues/24' 'Another issue' > "$ISSUES"
run_watch
[ "$(runs)" = "1" ] || fail "coalesced changes spawned more than one execution"
grep -q 'comments/4' "$PROMPT_CAPTURE" || fail "first coalesced event missing"
grep -q 'comments/5' "$PROMPT_CAPTURE" || fail "second coalesced event missing"
grep -q 'Issue #24' "$PROMPT_CAPTURE" || fail "coalesced Issue event missing"

# API failure must not advance the cursor.
reset_outputs; set_old_cursor
before="$(cat "$AGENT/.arep/github-watch.cursor")"
set +e
run_watch comments
rc=$?
set -e
[ "$rc" -ne 0 ] || fail "API failure returned success"
after="$(cat "$AGENT/.arep/github-watch.cursor")"
[ "$before" = "$after" ] || fail "API failure advanced cursor"

# Lock contention preserves pending event; a later no-change poll retries it.
reset_outputs; set_old_cursor
printf '%s\t%s\n' 'https://example.invalid/comments/6' 'Human while busy' > "$COMMENTS"
(
  mkdir -p "$AGENT/.arep"
  exec 7>"$AGENT/.arep/primary.lock"
  flock 7
  sleep 2
) &
locker=$!
sleep 1
run_watch
[ "$(runs)" = "0" ] || fail "watcher bypassed PRIMARY lock"
[ -s "$AGENT/.arep/github-event.pending" ] || fail "lock contention lost pending event"
wait "$locker"
: > "$COMMENTS"
run_watch
[ "$(runs)" = "1" ] || fail "pending event was not retried after lock release"
[ ! -f "$AGENT/.arep/github-event.pending" ] || fail "retried pending event not cleared"

echo "A Rep GitHub watcher tests passed."
