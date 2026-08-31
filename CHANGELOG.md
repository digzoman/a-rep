# Changelog

## 1.3.0

Additive provenance and reusable-skill release based on live multi-agent use around Fred.

### Agent provenance

- Added `references/PROVENANCE.md` with the canonical `[Agent | Platform | Role | Instance]` producer header for material agent-authored GitHub comments, reviews, handoffs, and similar durable posts.
- Defined core provenance Roles: `PRIMARY`, `Worker`, `Guardian`, `Reviewer`, and `Voice`.
- Explicitly separated producer provenance from authority: provenance says who/what produced a record and cannot manufacture permission, correctness, or PRIMARY status.
- Clarified that GitHub native author identity may be transport identity when multiple agent surfaces share one account/token/bot.
- Added `Agent-Provenance: Agent/Platform/Role/Instance` Git commit trailer guidance.
- Added `Agent-Run:` guidance for audit-relevant PRIMARY execution correlation.
- Kept provenance as a SHOULD convention in V1.3; existing history without provenance remains valid and needs no retroactive rewrite.
- Excluded mutable current-state Issue bodies such as Pulse/Issue 16 from producer-header prefixes; provenance belongs in accompanying material comments/logs/commits.

### Runtime provenance

- The minimal launcher now reuses its existing UTC raw-log timestamp to generate a run ID such as `heartbeat-20260831T170001Z`.
- Launcher prompts now include persistent Agent, Platform, Role `PRIMARY`, Instance, and `Agent-Run` coordinates.
- Added optional non-secret `PROVENANCE_PLATFORM` and `PROVENANCE_INSTANCE` config labels with safe fallbacks.
- Updated runtime regression tests to verify heartbeat/rejuvenation provenance and run-ID injection.
- No cadence, completion anchoring, deadline, locking, heartbeat success-state, or one-PRIMARY semantics changed.

### First-class skills

- Added `references/SKILLS.md` defining skills as reusable capability packages that may combine instructions, judgment rules, prompts, checklists, code/scripts, templates, schemas, examples, tool-use patterns, evidence requirements, failure modes, and learned heuristics.
- Added canonical experimental location `scratch/skills/<skill-name>/SKILL.md`.
- Retained/expanded canonical approved location `procedures/skills/<skill-name>/SKILL.md`.
- Added `scratch/skills/README.md` to the canonical scaffold and expanded `procedures/skills/README.md`.
- Defined lifecycle: `live work -> learning -> experimental skill -> evidence -> promotion proposal -> review -> human approval -> approved skill`.
- Experimental skills may be created/evolved autonomously within current work authority.
- Promotion into approved `procedures/skills/` requires review and explicit human approval.
- Added concise `trigger` metadata guidance for low-cost skill discovery; ~70 characters is a portability target rather than a hard framework limit.
- Made semantic versioning optional for experimental skills; approved skills SHOULD carry explicit versions.
- Added optional `related_skills` metadata and near-duplicate review guidance.
- Added dependency hygiene: approved skills should normally depend only on approved/stable resources and must not silently depend on mutable scratch material.
- Skills do not create authority; they describe capability/how, not permission.
- No manually synchronized skill INDEX, registry, database, package manager, marketplace, or dedicated skill-management API was added.
- Promotion uses Git move/equivalent when practical; no duplicate scratch redirect stub is required by default.

### Agent/Guardian/onboarding integration

- Updated `SKILL.md`, protocol, Issue topology, repository convention, heartbeat/rejuvenation/Guardian prompts, runtime docs, bootstrap, scaffold docs, and admin-log guidance for provenance and skills.
- Guardian now checks for repeated work that may justify a skill, near-duplicate skills, unstable dependencies, weak promotion evidence, and accidental capability/authority conflation.
- Worker guidance now distinguishes Worker provenance from PRIMARY and allows bounded experimental skill evolution within delegated scope.
- Bootstrap-generated agent READMEs explain provenance and skill lifecycle; new repos receive the experimental skill scaffold automatically.

## 1.2.1

Small hardening release based on Fred's first real Issue 21 live acceptance test and independent Guardian verification.

- Clarified that heartbeat due time is anchored to the previous successful heartbeat **completion**, because `.arep/heartbeat.last` is written only after a successful execution.
- Documented that scheduler polling can add up to roughly one poll interval after due time; `fast=5` is therefore not an exact five-minute start-to-start guarantee.
- Standardized Issue 16 body as the current human-readable runtime snapshot and Issue 16 comments as material runtime/cadence transition history.
- Clarified that live/tracked runtime configuration and direct host evidence remain authoritative if Issue prose is stale.
- Clarified that routine runtime/cadence transitions belong in Issue 16; Issue 3 is for cross-cutting actions, failures, recoveries, incidents, and major transitions rather than duplicate runtime logging.
- Tightened `agent-context-deep.md` loading so it is task/recovery-gated after baseline hot-context/system/work recovery; no active work by itself is not a reason to load deep context.
- Added an explicit heartbeat rule to reconcile stale **cross-cutting current facts** in hot context after material changes, without turning hot context into a chronological task log.
- Kept launcher code and runtime architecture unchanged.

## 1.2.0

Context and independent-review release based on pre-Issue-21 live Fred discussion.

- Added concise always-read `config/agent-context.md` hot context.
- Added on-demand `config/agent-context-deep.md` for richer organizational and strategic background.
- Updated bootstrap and canonical scaffold for both context layers.
- Updated heartbeat recovery order to read hot context before selecting work.
- Strengthened durable handoffs for incomplete work across fresh sessions.
- Clarified that heartbeat PRIMARY may do work directly or use bounded temporary subagents/workers while retaining ownership and reconciliation.
- Added optional provider-agnostic Guardian Angel prompt and protocol.
- Defined Guardian as advisory rather than a second PRIMARY, with GitHub Issue comments as its normal write surface.
- Added Guardian use of Issue 11 Inbox and relevant work/improvement Issues.
- Clarified that `DEADLINE_MODE` is explicit runtime state; V1.2 does not automatically infer GitHub Issue deadlines.
- Deferred optional execution-thread resumption and automatic deadline awareness to evidence-gated follow-up Issues.

## 1.1.0

Hardening and canonicalization release based on the first live Fred installation.

- Added a canonical private-agent repository scaffold with README guidance.
- Added `admin/logs/` for sanitized Git-visible operational logs.
- Renamed the default local raw execution directory to `.arep/raw-logs/`.
- Moved recommended local PRIMARY lock and heartbeat timestamp files under `.arep/`.
- Updated bootstrap to copy the canonical scaffold.
- Added launcher regression tests using a fake execution driver.
- Clarified logging, runtime documentation, cold-start organization, and top-level directory conventions.
- Kept rejuvenation semantics and overall V1 architecture unchanged.
- Deferred bounded timeout/stuck-cycle handling and scaffold migration tooling until operating evidence justifies them.

## 1.0.0

Initial accepted V1 protocol, runtime, heartbeat/rejuvenation launcher, bootstrap, reserved Issue topology, and first-agent deployment model.
