# Changelog

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
