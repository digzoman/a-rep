#!/bin/sh
set -eu

REPO="${1:-}"
AGENT_ID="${2:-}"
AGENT_ROLE="${3:-}"
TARGET_DIR="${4:-}"

[ -n "$REPO" ] && [ -n "$AGENT_ID" ] && [ -n "$AGENT_ROLE" ] || {
  echo "Usage: $0 owner/private-repo agent-id agent-role [target-dir]" >&2
  exit 2
}

command -v gh >/dev/null 2>&1 || { echo "gh is required" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 2; }

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
A_REP_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
SCAFFOLD="$A_REP_DIR/scaffold/agent-repo"
[ -d "$SCAFFOLD" ] || { echo "Missing canonical scaffold: $SCAFFOLD" >&2; exit 2; }

visibility="$(gh repo view "$REPO" --json visibility --jq '.visibility')"
[ "$visibility" = "PRIVATE" ] || { echo "Agent repository must be private, got: $visibility" >&2; exit 2; }

existing="$(gh api "repos/$REPO/issues?state=all&per_page=1" --jq 'length')"
[ "$existing" = "0" ] || { echo "Repository already has Issue or PR numbers. Bootstrap requires an unused number space." >&2; exit 2; }

if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$(printf '%s' "$REPO" | awk -F/ '{print $2}')"
fi
[ ! -e "$TARGET_DIR" ] || { echo "Target path exists: $TARGET_DIR" >&2; exit 2; }

gh repo clone "$REPO" "$TARGET_DIR"
cd "$TARGET_DIR"

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "Agent repository must be empty before bootstrap. Existing commits were found." >&2
  exit 2
fi

git branch -M main
cp -R "$SCAFFOLD"/. .
mkdir -p .arep/raw-logs

cat > config/arep.env <<EOFCONF
AGENT_ID="$AGENT_ID"
AGENT_ROLE="$AGENT_ROLE"
AGENT_REPO="$REPO"
AGENT_REPO_DIR="$(pwd)"
A_REP_REPO="digzoman/a-rep"
A_REP_REF="main"
A_REP_SKILL_PATH="/opt/a-rep/a-rep/SKILL.md"
EXECUTION_DRIVER="codex"
EXECUTION_BIN="codex"
EXECUTION_MODEL=""
PROVENANCE_PLATFORM=""
PROVENANCE_INSTANCE=""
HEARTBEAT_ENABLED="true"
HEARTBEAT_MODE="normal"
HEARTBEAT_FAST_MINUTES="5"
HEARTBEAT_NORMAL_MINUTES="15"
HEARTBEAT_SLOW_MINUTES="60"
DEADLINE_MODE="false"
REJUVENATION_ENABLED="true"
RUNTIME_DIR=".arep"
LOG_DIR=".arep/raw-logs"
LOCK_FILE=".arep/primary.lock"
HEARTBEAT_LAST_FILE=".arep/heartbeat.last"
EOFCONF

cat > config/agent-context.md <<EOFCONTEXT
# Agent context — hot

This is the short strategic context PRIMARY and Guardian read on every cycle.

Agent: $AGENT_ID
Role: $AGENT_ROLE
EOFCONTEXT
cat >> config/agent-context.md <<'EOFCONTEXT'

Issue 2 remains authoritative for durable identity, charter, and standing authority. This file is a concise working summary, not a way to manufacture or expand authority.

## Mission

Define the current high-level mission before assigning consequential real work.

## Current priorities

Summarize the few priorities that matter across multiple work Issues. Detailed actionable work remains in Issues 21 and higher.

## Decision principles

Record the small number of standing strategic or operating principles that materially improve decisions.

## Current important context

Capture only information worth loading every cycle.

## When to load deep context

Do not read `config/agent-context-deep.md` automatically during baseline cold-start recovery. First recover current system/work state and identify the likely task or recovery need.

Load deep context only when this hot file points to relevant deep material or when information absent from hot context would materially affect the selected action. Having no active work, by itself, is not a reason to read the deep file.
EOFCONTEXT

cat > README.md <<EOFREADME
# $AGENT_ID

A private A Rep agent repository.

Role, $AGENT_ROLE.
EOFREADME
cat >> README.md <<'EOFREADME'

Canonical top-level zones are `admin/`, `config/`, `scratch/`, `procedures/`, and `work/`. Prefer organizing new material inside those zones rather than inventing new top-level directories.

- `admin/` durable operational documentation and sanitized Git-visible logs.
- `config/` non-secret runtime configuration plus hot/deep strategic context.
- `scratch/` exploratory and untrusted working material, including experimental `scratch/skills/` capability packages.
- `procedures/` reviewed and trusted ways of working, including approved `procedures/skills/` capability packages.
- `work/` actual artifacts produced while pursuing goals.
- `.arep/` local machine runtime state and raw logs; Git ignored.

PRIMARY always reads `config/agent-context.md`. It reads `config/agent-context-deep.md` only when the current task/recovery need materially benefits from deeper background.

Material agent-authored GitHub comments, reviews, and handoffs should use A Rep producer provenance: `[Agent | Platform | Role | Instance]`. Launcher-run PRIMARY cycles receive an `Agent-Run` ID. Provenance identifies the producer; it does not create authority. See the public A Rep `references/PROVENANCE.md`.

Reusable experimental capabilities may be created and evolved under `scratch/skills/<skill-name>/SKILL.md`. Promotion into `procedures/skills/` requires review and explicit human approval. Skills describe capability, not permission. See `references/SKILLS.md` in the public A Rep repo.

Durable operating state is also maintained through GitHub Issues. Normal real work starts at Issue 21.
EOFREADME

git add .
git commit -m "Initialize A Rep agent repository"
git push -u origin main

create_issue() {
  title="$1"
  body="$2"
  gh issue create --repo "$REPO" --title "$title" --body "$body" >/dev/null
}

create_issue "[A Rep] Pulse" "Current concise operational state. Maintain current focus, waits, heartbeat mode, and next likely action here."
create_issue "[A Rep] Identity and Charter" "Agent ID, $AGENT_ID. Role, $AGENT_ROLE. Record durable purpose, boundaries, standing authority, and relationship to the human or organization here."
create_issue "[A Rep] Execution Trail" "Append material actions, outcomes, meaningful failures, recoveries, and major state transitions. Avoid trivial tool-call logging."
create_issue "[A Rep] Human Decisions and Authority" "Record genuine human authority questions, standing approvals, consequential decisions, and durable resolutions."
create_issue "[A Rep] Goal Stack and Priority Context" "Record high-level goals, strategic emphasis, deadlines, and priority changes spanning multiple work Issues."
create_issue "[A Rep] Evidence and Verification" "Record cross-cutting evidence standards or verification that does not naturally belong to a specific work Issue."
create_issue "[A Rep] Recovery and Incidents" "Record material runtime incidents, conflicting durable state, and recovery information needed for safe cold-start continuation."
create_issue "[A Rep] Reserved 8" "Reserved for a future stable framework-level need."
create_issue "[A Rep] Reserved 9" "Reserved for a future stable framework-level need."
create_issue "[A Rep] Reserved 10" "Reserved for a future stable framework-level need."
create_issue "[A Rep] Inbox" "Targeted inbound communication intended for this PRIMARY, including optional Guardian Angel review or offers of bounded help. Triage when useful."
create_issue "[A Rep] Outbox" "Optional bulletin board for information other agents may inspect without mandatory acknowledgement."
create_issue "[A Rep] Research" "Backlog of worthwhile questions and investigations for free cycles or rejuvenation."
create_issue "[A Rep] Operational Improvements" "Candidates for improving the agent's nondeterministic methods, organization, recovery, procedures, and reusable capabilities."
create_issue "[A Rep] Coding Improvements" "Candidates for scripts, automation, tools, deterministic helpers, and reusable coding capabilities that may replace repeated work."
create_issue "[A Rep] Runtime and Heartbeat Requests" "Requests and rationale for runtime or cadence changes. The configured runtime remains authoritative."
create_issue "[A Rep] Rejuvenation" "Rejuvenation focus, findings, proposals, experimental-skill learnings, and material self-improvement outcomes."
create_issue "[A Rep] Reserved 18" "Reserved for a future stable framework-level need."
create_issue "[A Rep] Reserved 19" "Reserved for a future stable framework-level need."
create_issue "[A Rep] Reserved 20" "Reserved for a future stable framework-level need."

echo "Bootstrapped $REPO. Normal work starts at Issue 21."
