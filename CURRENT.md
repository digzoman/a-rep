# Current A Rep version

Current version, A Rep V1.2.1.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and current supporting files define active behaviour. Historical changes belong in Git history or releases rather than additive patches that every agent must mentally compose.

## What V1.2.1 changes

V1.2.1 is a small evidence-backed hardening release from Fred's first real Issue 21 acceptance test. It does not change the launcher architecture.

- Documents that heartbeat cadence is anchored to the previous **successful completion**, not the previous start.
- Makes clear that scheduler polling can add up to roughly one poll interval after a heartbeat becomes due, so `fast=5` is not an exact five-minute start-to-start promise.
- Standardizes Issue 16 body as the current human-readable runtime snapshot and Issue 16 comments as runtime/cadence transition history, while live/tracked config remains authoritative.
- Clarifies that routine runtime/cadence transitions belong in Issue 16; Issue 3 is reserved for cross-cutting actions, failures, recoveries, incidents, and major transitions.
- Tightens deep-context loading: hot context is always read, but deep context is loaded only after current work/recovery needs are known and deeper information would materially affect the selected action. No-work state alone is not a reason to load it.
- Requires PRIMARY to reconcile stale **cross-cutting current facts** in hot context after material changes, replacing stale current-state prose without turning hot context into a task chronology.

## V1.2 foundations retained

- `config/agent-context.md` as concise hot strategic context read every PRIMARY and Guardian cycle.
- `config/agent-context-deep.md` as richer context loaded only when materially useful.
- Strong cross-cycle durable handoffs for incomplete work.
- Heartbeat PRIMARY may do work directly or use bounded subagents/workers while remaining responsible for reconciliation.
- Optional provider-agnostic Guardian Angel review protocol.
- Guardian communicates primarily through Issue comments.
- `DEADLINE_MODE` remains explicit configured state; the launcher does not infer GitHub Issue deadlines.

The runtime remains one tiny PRIMARY launcher plus cron wakeups. Guardian scheduling is optional and external.

## First live Issue 21 evidence

Fred's first real work/acceptance test successfully demonstrated automatic pickup, normal-to-fast cadence switching, fresh-session recovery, explicit deadline-mode acceleration, durable handoffs/logging, runtime restoration, authority discipline, and clean completion. An independent Guardian verified VM/repository evidence rather than trusting Fred's narrative alone.

The test also produced the V1.2.1 clarifications above: observed fast cycles were roughly 10 minutes start-to-start because the five-minute due interval began after successful completion and the five-minute cron poll added scheduler granularity; Issue 16's body briefly lagged behind actual config; deep context had previously been loaded once when it was unnecessary; and Fred's hot context retained a pre-Issue-21 runtime sentence after the test, showing that current hot context needs explicit reconciliation when material cross-cutting facts change.

## V1.1 foundations retained

- canonical private-agent scaffold;
- `admin/logs/` sanitized Git-visible operational logs;
- `.arep/raw-logs/` raw local output;
- `.arep/primary.lock` and `.arep/heartbeat.last` local state;
- scaffold-based bootstrap;
- launcher regression tests.

## Deliberate exclusions / evidence-gated follow-up

V1.2.1 still excludes persistent multi-PRIMARY coordination, a team repository, distributed locking, a custom database, queues, workflow engines, custom memory servers, dashboards, and other orchestration infrastructure.

Public framework Issues track deferred work and state why each should wait for more evidence, including bounded timeout/stuck-cycle handling, scaffold migration tooling, optional execution-thread resumption, automatic deadline awareness, a reusable new-agent acceptance-test template, and possible first-class Guardian scheduling support.

## First live agent

Fred is live on the V1.2 architecture and should be synchronized to V1.2.1 before further acceptance testing.

The highest-value non-framework improvement is still to populate Fred's hot/deep context with real Ampgent founder strategy, assets, distribution advantages, constraints, and prior decisions before asking him for consequential strategic recommendations. The framework deliberately does not invent organization-specific strategy.
