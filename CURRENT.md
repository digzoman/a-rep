# Current A Rep version

Current version, A Rep V1.3.0.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and current supporting files define active behaviour. Historical changes belong in Git history or releases rather than additive patches that every agent must mentally compose.

## What V1.3 adds

V1.3 is an additive feature release based on live multi-agent use around Fred.

Two concrete problems emerged:

1. Multiple execution/review surfaces can post through the same GitHub account, so native GitHub authorship no longer reliably identifies which actual agent/platform/role/instance produced a durable record.
2. Live use showed agents naturally discovering reusable capabilities, including Hermes creating a reusable skill without being explicitly asked, while A Rep previously had only partial folder-level skill support rather than a first-class experimental-to-approved lifecycle.

V1.3 addresses both with lightweight conventions rather than new orchestration infrastructure.

### Producer provenance

Material agent-authored comments, reviews, handoffs, and similar durable GitHub posts SHOULD begin with:

`[Agent | Platform | Role | Instance]`

Core Roles are:

- `PRIMARY`
- `Worker`
- `Guardian`
- `Reviewer`
- `Voice`

Agent-authored Git commits SHOULD carry:

`Agent-Provenance: Agent/Platform/Role/Instance`

Launcher-run PRIMARY cycles also receive a UTC-stamped `Agent-Run` identifier correlated with the raw-log timestamp.

The launcher accepts optional non-secret `PROVENANCE_PLATFORM` and `PROVENANCE_INSTANCE` labels and otherwise uses lightweight fallbacks.

Provenance is deliberately a SHOULD convention: missing provenance does not invalidate otherwise useful historical/current evidence.

Provenance identifies the producer. It does **not** create authority.

### First-class skills

Experimental reusable capabilities now have a canonical home:

`scratch/skills/<skill-name>/SKILL.md`

Approved durable capabilities remain under:

`procedures/skills/<skill-name>/SKILL.md`

PRIMARY may autonomously create, test, edit, and evolve experimental skills within current work authority.

Promotion into `procedures/skills/` requires review and explicit human approval.

The normal lifecycle is:

`live work -> learning -> experimental skill -> evidence -> promotion proposal -> review -> human approval -> approved skill`

Skills normally use directories so supporting scripts/templates/examples can grow with the capability.

A concise `trigger` metadata field supports cheap relevance routing before full skill content is loaded. Around 70 characters is a portability target, not a hard framework parser limit.

Git is the authoritative experimental history; semver is optional in scratch. Approved skills SHOULD carry an explicit version.

Approved skills should normally depend only on approved/stable resources and must not silently depend on mutable experimental scratch material.

No manually synchronized INDEX, skill registry, package manager, marketplace, database, or skill-management API is added.

Skills describe capability/how. They never grant authority for the underlying action.

## Runtime change

The V1.3 launcher change is intentionally tiny.

For every executed heartbeat/rejuvenation, the launcher already creates a UTC timestamp for the raw log. V1.3 reuses that timestamp to generate:

`Agent-Run: <cycle>-<timestamp>`

It injects the persistent Agent, Platform, Role `PRIMARY`, Instance, and run ID into the execution prompt.

Cadence, completion-anchored due timing, deadline behaviour, flock ownership, heartbeat success state, and one-PRIMARY architecture are unchanged.

The runtime regression suite now includes provenance/run-ID prompt injection checks.

## V1.2.1 foundations retained

- heartbeat cadence anchored to successful completion;
- scheduler polling granularity documented;
- Issue 16 body = current runtime snapshot, comments = material transition history;
- Issue 3 reserved for cross-cutting material events rather than routine runtime duplication;
- hot context always read and reconciled when materially stale;
- deep context loaded only after current task/recovery need is known and it materially helps.

## V1.2 foundations retained

- concise hot/deep strategic context layers;
- strong fresh-session handoffs;
- one persistent PRIMARY plus bounded temporary workers;
- optional provider-agnostic Guardian Angel review;
- explicit `DEADLINE_MODE` rather than automatic deadline inference.

## Deliberate exclusions / evidence-gated follow-up

V1.3 still excludes persistent multi-PRIMARY coordination, distributed locking, a custom database, queues, workflow engines, custom memory servers, dashboards, a skill registry/marketplace, and other orchestration infrastructure.

Public framework Issues continue to track evidence-gated follow-up including bounded timeout/stuck-cycle handling, scaffold migration tooling, optional execution-thread resumption, automatic deadline awareness, reusable live acceptance testing, first-class Guardian scheduling only if external scheduling proves insufficient, and the future recurring-responsibility/scheduled-subagent coordination vision.

## Existing-agent migration

V1.3 is additive and backward compatible.

Existing private agents do not need history rewritten.

For an existing agent such as Fred, the recommended hot patch is:

- sync the public A Rep checkout to V1.3;
- create `scratch/skills/README.md` / directory and update existing `procedures/skills/README.md` guidance;
- add optional provenance labels to runtime config when a more useful Platform/Instance name is desired;
- update agent/runtime README guidance as appropriate;
- do not retroactively relabel old Issue comments or commits;
- preserve all existing work/procedures/scratch state;
- run launcher/bootstrap syntax checks and `a-rep/tests/runtime-test.sh`;
- let future material comments/commits adopt provenance naturally.

Do not manufacture a first skill merely to test the folder. Let the first experimental skill emerge from real repeated work.
