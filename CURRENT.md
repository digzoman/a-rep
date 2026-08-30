# Current A Rep version

Current version, A Rep V1.2.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and current supporting files define active behaviour. Historical changes belong in Git history or releases rather than additive patches that every agent must mentally compose.

## What V1.2 adds

V1.2 strengthens context and independent review without changing the one-PRIMARY architecture.

- `config/agent-context.md` as concise hot strategic context read every PRIMARY and Guardian cycle.
- `config/agent-context-deep.md` as richer context loaded only when materially useful.
- Heartbeat prompt explicitly loads hot context before selecting work.
- Stronger cross-cycle durable handoff guidance for incomplete work.
- Explicit rule that heartbeat PRIMARY may do work directly or use bounded subagents/workers while remaining responsible for reconciliation.
- Optional provider-agnostic Guardian Angel review prompt and protocol.
- Guardian communicates primarily through Issue comments, especially Issue 11, relevant work Issues, and Issues 14/15.
- Explicit clarification that `DEADLINE_MODE` is configured state; the launcher does not infer GitHub Issue deadlines.

The runtime remains one tiny PRIMARY launcher plus cron wakeups. Guardian scheduling is optional and external.

## V1.1 foundations retained

- canonical private-agent scaffold;
- `admin/logs/` sanitized Git-visible operational logs;
- `.arep/raw-logs/` raw local output;
- `.arep/primary.lock` and `.arep/heartbeat.last` local state;
- scaffold-based bootstrap;
- launcher regression tests.

## Deliberate exclusions

V1.2 still excludes persistent multi-PRIMARY coordination, a team repository, distributed locking, a custom database, queues, workflow engines, custom memory servers, dashboards, and other orchestration infrastructure.

Evidence-gated future Issues track bounded execution timeout/stuck-cycle handling, versioned scaffold migration, optional execution-thread resumption, and possible automatic deadline awareness.

## First live agent

Fred should be patched to the V1.2 context scaffold and the live runtime checkout synchronized before receiving Issue 21.

Fred's hot context should be populated with real founder mission/strategic priorities before consequential real work; the framework deliberately does not invent organization-specific strategy.
