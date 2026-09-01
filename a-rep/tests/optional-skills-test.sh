#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
PLANCTL="$ROOT/a-rep/scaffold/agent-repo/procedures/skills/plan-work/planctl.py"
LEDGERCTL="$ROOT/a-rep/scaffold/agent-repo/procedures/skills/data-ledger/ledgerctl.py"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  needle="$1"
  file="$2"
  grep -F "$needle" "$file" >/dev/null || fail "$file missing: $needle"
}

assert_not_contains() {
  needle="$1"
  file="$2"
  if grep -F "$needle" "$file" >/dev/null; then
    fail "$file unexpectedly contains: $needle"
  fi
}

REPO="$TMP/agent"
mkdir -p "$REPO/work/plans/short-check" "$REPO/work/plans/long-campaign"

cat > "$REPO/work/plans/short-check/PLAN.md" <<'EOF'
# Short Check

Status: READY
Current chunk: Verify one response
Next action: Check provider truth
Next due: 2100-01-01T00:00:00Z
Waiting on: none
Work issue: #21
Plan version: 1
Updated: 2026-09-01T12:00:00Z
Last PRIMARY: heartbeat-test

## Goal

Verify one response.
EOF
cat > "$REPO/work/plans/short-check/EVENTS.md" <<'EOF'
# Plan Events

## 2026-09-01 12:00 UTC

Event: plan created
Chunk: Verify one response
EOF

cat > "$REPO/work/plans/long-campaign/PLAN.md" <<'EOF'
# Multi-week Campaign

Status: WAIT_HUMAN
Current chunk: Approve Day 1
Next action: Wait for human decision
Next due: 2000-01-01T00:00:00Z
Waiting on: human
Work issue: #28
Plan version: 1
Updated: 2026-09-01T12:00:00Z
Last PRIMARY: event-test

## Goal

Run a multi-week campaign using the same plan structure.
EOF
cat > "$REPO/work/plans/long-campaign/EVENTS.md" <<'EOF'
# Plan Events

## 2026-09-01 09:00 UTC

Event: plan created
Chunk: Candidate selection

## 2026-09-01 10:00 UTC

Event: chunk completed
Chunk: Candidate selection
EOF

PLAN_HASH_BEFORE="$(sha256sum "$REPO/work/plans/short-check/PLAN.md" "$REPO/work/plans/long-campaign/PLAN.md")"
"$PLANCTL" --root "$REPO" reindex
assert_contains "Short Check" "$REPO/work/plans/INDEX.md"
assert_contains "Multi-week Campaign" "$REPO/work/plans/INDEX.md"
assert_contains "WAIT_HUMAN" "$REPO/work/plans/INDEX.md"

rm "$REPO/work/plans/INDEX.md"
PLAN_HASH_AFTER_DELETE="$(sha256sum "$REPO/work/plans/short-check/PLAN.md" "$REPO/work/plans/long-campaign/PLAN.md")"
[ "$PLAN_HASH_BEFORE" = "$PLAN_HASH_AFTER_DELETE" ] || fail "deleting plan INDEX changed authoritative plans"
"$PLANCTL" --root "$REPO" reindex
[ -f "$REPO/work/plans/INDEX.md" ] || fail "plan reindex did not recreate INDEX.md"

"$PLANCTL" --root "$REPO" status > "$TMP/plan-status.md"
assert_contains "Short Check" "$TMP/plan-status.md"
assert_contains "Multi-week Campaign" "$TMP/plan-status.md"

"$PLANCTL" --root "$REPO" due --within-hours 24 > "$TMP/plan-due.md"
assert_contains "Multi-week Campaign" "$TMP/plan-due.md"
assert_contains "OVERDUE" "$TMP/plan-due.md"
assert_not_contains "Short Check" "$TMP/plan-due.md"

mkdir -p "$REPO/work/plans/due-soon"
DUE_SOON="$(python3 - <<'PY'
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc) + timedelta(hours=1)).isoformat())
PY
)"
cat > "$REPO/work/plans/due-soon/PLAN.md" <<EOF
# Due Soon

Status: WAIT_UNTIL
Current chunk: Timed follow-up
Next action: Check again
Next due: $DUE_SOON
Waiting on: time
Work issue: #29
Plan version: 1
Updated: 2026-09-01T12:00:00Z
Last PRIMARY: heartbeat-test

## Goal

Demonstrate a due plan.
EOF
cat > "$REPO/work/plans/due-soon/EVENTS.md" <<'EOF'
# Plan Events
EOF
"$PLANCTL" --root "$REPO" due --within-hours 24 > "$TMP/plan-due-2.md"
assert_contains "Due Soon" "$TMP/plan-due-2.md"
assert_contains "DUE" "$TMP/plan-due-2.md"

FIRST_EVENT_LINE="$(grep -n 'Event: plan created' "$REPO/work/plans/long-campaign/EVENTS.md" | cut -d: -f1)"
SECOND_EVENT_LINE="$(grep -n 'Event: chunk completed' "$REPO/work/plans/long-campaign/EVENTS.md" | cut -d: -f1)"
[ "$FIRST_EVENT_LINE" -lt "$SECOND_EVENT_LINE" ] || fail "plan events are not chronological"

# Replanning preserves history rather than rewriting it.
cat >> "$REPO/work/plans/long-campaign/EVENTS.md" <<'EOF'

## 2026-09-01 11:00 UTC

Event: replanned
Chunk: Approve Day 1

New evidence changed the remaining chunks.
EOF
python3 - "$REPO/work/plans/long-campaign/PLAN.md" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("Plan version: 1", "Plan version: 2", 1)
path.write_text(text)
PY
assert_contains "Event: plan created" "$REPO/work/plans/long-campaign/EVENTS.md"
assert_contains "Event: replanned" "$REPO/work/plans/long-campaign/EVENTS.md"
assert_contains "Plan version: 2" "$REPO/work/plans/long-campaign/PLAN.md"

# Fresh-process recovery requires only durable files, not INDEX.md or hidden state.
RECOVER="$TMP/recovered"
mkdir -p "$RECOVER/work"
cp -R "$REPO/work/plans" "$RECOVER/work/plans"
rm -f "$RECOVER/work/plans/INDEX.md"
"$PLANCTL" --root "$RECOVER" status > "$TMP/recovered-status.md"
assert_contains "Multi-week Campaign" "$TMP/recovered-status.md"
"$PLANCTL" --root "$RECOVER" reindex
[ -f "$RECOVER/work/plans/INDEX.md" ] || fail "fresh process could not rebuild plan index"

mkdir -p "$REPO/work/data/external-prospects" "$REPO/work/data/local-experiment"
cat > "$REPO/work/data/external-prospects/README.md" <<'EOF'
# External Prospect Working Set

Authoritative business source: Master CRM
Provider truth: Unipile
Local snapshot authority: working snapshot only
Record type: prospect
Identity field: provider_id
Last synchronized: 2026-09-01T12:00:00Z

## Purpose

Track a bounded working set without replacing the CRM.
EOF
cat > "$REPO/work/data/external-prospects/snapshot.csv" <<'EOF'
provider_id,name,status
p-1,Ada,selected
p-2,Grace,waiting
EOF
cat > "$REPO/work/data/external-prospects/events.csv" <<'EOF'
timestamp,event_id,entity_id,event_type,source_id,context,note
EOF

cat > "$REPO/work/data/local-experiment/README.md" <<'EOF'
# Local Experiment Ledger

Authoritative business source: none
Provider truth: none
Local snapshot authority: authoritative agent working state only
Record type: experiment subject
Identity field: subject_id
Last synchronized: 2026-09-01T12:00:00Z

## Purpose

Track local experiment subjects.
EOF
cat > "$REPO/work/data/local-experiment/snapshot.csv" <<'EOF'
subject_id,variant,outcome
s-1,A,pending
EOF
cat > "$REPO/work/data/local-experiment/events.csv" <<'EOF'
timestamp,event_id,entity_id,event_type,source_id,context,note
EOF

DATA_HASH_BEFORE="$(sha256sum "$REPO/work/data/external-prospects/README.md" "$REPO/work/data/external-prospects/snapshot.csv")"
"$LEDGERCTL" --root "$REPO" reindex
assert_contains "External Prospect Working Set" "$REPO/work/data/INDEX.md"
assert_contains "| prospect | 2 | Master CRM |" "$REPO/work/data/INDEX.md"
assert_contains "Local Experiment Ledger" "$REPO/work/data/INDEX.md"

rm "$REPO/work/data/INDEX.md"
DATA_HASH_AFTER_DELETE="$(sha256sum "$REPO/work/data/external-prospects/README.md" "$REPO/work/data/external-prospects/snapshot.csv")"
[ "$DATA_HASH_BEFORE" = "$DATA_HASH_AFTER_DELETE" ] || fail "deleting data INDEX changed ledger state"
"$LEDGERCTL" --root "$REPO" reindex
[ -f "$REPO/work/data/INDEX.md" ] || fail "ledger reindex did not recreate INDEX.md"

"$LEDGERCTL" --root "$REPO" find external-prospects p-2 > "$TMP/find.csv"
assert_contains "provider_id,name,status" "$TMP/find.csv"
assert_contains "p-2,Grace,waiting" "$TMP/find.csv"

"$LEDGERCTL" --root "$REPO" append-event external-prospects evt-1 p-2 reply_received --source-id provider-msg-7 --context campaign-a --note "positive reply" > "$TMP/event-1.out"
"$LEDGERCTL" --root "$REPO" append-event external-prospects evt-1 p-2 reply_received --source-id provider-msg-7 --context campaign-a --note "duplicate delivery" > "$TMP/event-2.out"
EVENT_ROWS="$(wc -l < "$REPO/work/data/external-prospects/events.csv" | tr -d ' ')"
[ "$EVENT_ROWS" = "2" ] || fail "duplicate event created duplicate logical row"
assert_contains "event already present: evt-1" "$TMP/event-2.out"

if "$LEDGERCTL" --root "$REPO" append-event external-prospects evt-1 p-1 message_sent --source-id provider-msg-8 >/dev/null 2>&1; then
  fail "conflicting event_id reuse should fail"
fi

assert_contains "Authoritative business source: Master CRM" "$REPO/work/data/external-prospects/README.md"
assert_contains "Local snapshot authority: working snapshot only" "$REPO/work/data/external-prospects/README.md"

# Optional skills remain ordinary files; helpers generate no JSON or hidden state.
if find "$REPO/work/plans" "$REPO/work/data" -name '*.json' -print | grep . >/dev/null; then
  fail "optional skills generated JSON"
fi

assert_contains "A plan never expands authority" "$ROOT/a-rep/scaffold/agent-repo/procedures/skills/plan-work/SKILL.md"
assert_contains "Tool capability does not create authority" "$ROOT/a-rep/scaffold/agent-repo/procedures/skills/data-ledger/SKILL.md"

python3 -m py_compile "$PLANCTL" "$LEDGERCTL"

echo "PASS: optional A Rep plan-work/data-ledger skills"
