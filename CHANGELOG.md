# Changelog

## 1.4.1

Human-notification provenance patch based on live Fred V1.4 event-wake and Pocket Alert testing.

- Added `references/HUMAN_NOTIFICATIONS.md` as the first-class A Rep contract for asynchronous human alerts.
- Reused the existing `[Agent | Platform | Role | Instance]` provenance format instead of inventing a notification-specific identity scheme.
- For transports with a visible title/subject, the title SHOULD be an exact provenance header.
- When one A Rep surface originates a message and another relays it, preserve the origin header as the notification title and add `Relayed-By: [Agent | Platform | Role | Instance]` for the actual delivery surface.
- Added concise `Source:` guidance for durable Issue/URL attribution and optional `Path:` guidance for diagnostic/test messages.
- Clarified that notification delivery is attention, not approval or authority.
- Clarified machine-side delivery evidence versus proof the human actually received/read the alert.
- Updated `SKILL.md`, `PROVENANCE.md`, README, and CURRENT to make notification provenance part of the portable framework.
- Added no notification daemon, message bus, database, vendor dependency, new role, or runtime scheduler. Delivery adapters remain approved agent skills.

## 1.4.0

Event-wake and backup-heartbeat release based on live Fred operating-cost/responsiveness discussion.

### GitHub event wake

- Added `runtime/arep-watch-github.sh`, a cheap deterministic watcher intended to poll the configured private agent repository every minute.
- Added explicit `event` support to `runtime/arep-run.sh`; heartbeat, event, and rejuvenation continue to share one local PRIMARY `flock`.
- Added `prompts/event.md` and `references/EVENT_WAKE.md`.
- The watcher reacts to a deliberately narrow control surface: new Issues, reopened Issues, and new/updated Issue comments.
- No-change watcher polls exit without launching the coding agent/model.
- First watcher run initializes a local cursor to current time instead of replaying historical repository activity.
- Cursor advances only after all required GitHub reads succeed and uses poll-start time as the next boundary to avoid losing changes created while polling.
- Added Git-ignored pending event hints rather than a queue/database.
- Event wakes carry a `Wake reason: github-change` routing hint and must reconstruct authoritative current GitHub reality before acting.
- Event execution failure or PRIMARY lock contention preserves pending input for retry.
- Successful event execution removes pending input only when the pending file did not change during the run, preventing newly arrived events from being discarded.
- Multiple changes discovered in one poll are coalesced into one event wake.

### Loop prevention and provenance

- Reused V1.3 producer provenance as a conservative routing signal to suppress clearly self-produced PRIMARY comments from waking the same configured execution platform again.
- Guardian, Worker, Reviewer, human/unlabelled, and unknown-origin comments remain wake candidates.
- Kept provenance as routing evidence rather than authentication or authority; ambiguous origin prefers waking over silent discard.
- Added explicit guidance not to post durable comments merely to acknowledge an event wake.

### Backup heartbeat and scheduled work

- Changed the generic active-agent normal heartbeat default/example from 15 minutes to **30 minutes**.
- Kept the five-minute heartbeat cron poll so explicit fast/deadline mode can take effect promptly.
- Added `.arep/primary.last` as the last successful productive PRIMARY completion from heartbeat or event wake.
- Backup heartbeat due calculation now uses the latest successful productive PRIMARY completion, so a successful event wake postpones a redundant immediate heartbeat.
- Retained `.arep/heartbeat.last` as the last successful heartbeat completion rather than overloading its meaning.
- Added guidance that when PRIMARY knows authorized scheduled work needs another wake sooner than the normal 30-minute backup, it should explicitly enter fast mode or `DEADLINE_MODE=true` early enough to meet the window, then restore normal state when appropriate.
- If work is due sooner than fast cadence plus scheduler polling can reliably support, PRIMARY should continue in the current authorized cycle when practical or use an already-authorized explicit scheduler mechanism.
- Automatic parsing/inference of GitHub Issue deadlines remains deferred rather than being silently added to V1.4.

### Runtime/config/bootstrap

- Added config fields for `EVENT_ENABLED`, `GITHUB_WATCH_ENABLED`, watcher binary, watcher cursor/lock, pending event file, and productive PRIMARY timestamp.
- Updated `cron.example` with a one-minute watcher plus existing five-minute heartbeat poll.
- Updated bootstrap defaults for the event watcher and 30-minute normal backup heartbeat.
- Added `event-<UTC timestamp>` run IDs with the same producer-provenance injection used by other PRIMARY cycles.
- `paused` remains authoritative and suppresses heartbeat/event PRIMARY execution while preserving pending event state.

### Tests

- Expanded `runtime-test.sh` for event execution, event failure, event/heartbeat timing interaction, pending-state preservation, pause behavior, and shared PRIMARY lock contention.
- Added `github-watch-test.sh` covering first-run cursor initialization, no-change cheap polling, external/Worker comment wake, self-PRIMARY suppression, new/reopened Issue wake, coalescing, API-failure cursor preservation, and pending retry after lock contention.

### Deliberate exclusions

- No webhook receiver.
- No database/Redis queue.
- No event bus or background worker pool.
- No activity-scoring scheduler.
- No automatic active/idle/dormant cadence states.
- No day/night or quiet-hours logic.
- No automatic deadline parsing.
- No second PRIMARY or distributed lock.

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
