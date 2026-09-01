# Current A Rep version

Current version, **A Rep V1.4.1**.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and supporting files define active behaviour. Historical changes belong in Git history/changelog rather than additive patches every agent must mentally compose.

## V1.4.1 patch: human-facing notification provenance

Live Fred testing exposed a practical provenance gap: GitHub comments correctly carried `[Agent | Platform | Role | Instance]`, but Pocket Alert phone pushes were titled with task names such as `A Rep V1.4 sub-issue wake test`. On the phone, the human could not immediately tell which agent surface the message came from or whether another surface had originated it.

V1.4.1 fixes that without changing runtime architecture.

### Notification envelope

Material A Rep human notifications SHOULD reuse the existing four-field provenance format:

`[Agent | Platform | Role | Instance]`

For transports with a visible title/subject, the title SHOULD be an exact provenance header.

If the delivering surface also originated the notification, use that producer header directly.

If one A Rep surface originated the message and another surface relays it, preserve the upstream origin as the title and add a concise relay line in the body:

`Relayed-By: [Agent | Platform | Role | Instance]`

Example:

```text
Title:
[Fred | ChatGPT | Reviewer | A-Rep-design-chat]

Body:
Relayed-By: [Fred | Codex | PRIMARY | VM-runtime]
A Rep messaging test
Source: Issue #11
```

This keeps both the human-relevant origin and the actual delivery path visible without creating a general trace graph.

### Source and authority

When useful, include a concise `Source:` pointer to the durable Issue/URL that caused the notification.

A notification is only an attention mechanism. It is **not** approval and cannot manufacture human authority.

Machine-side delivery success is evidence that a transport accepted/delivered the message, not proof the human read it. Preserve that distinction in consequential workflows.

### Delivery remains skill-level

A Rep does not add a Pocket Alert dependency, Discord dependency, notification daemon, message bus, or notification database.

The framework defines the provenance/authority contract. Approved agent skills implement actual transports.

This is intentionally a patch release because it tightens an existing V1.3 provenance concept after live V1.4 use rather than adding a new orchestration subsystem.

See `a-rep/references/HUMAN_NOTIFICATIONS.md` and `a-rep/references/PROVENANCE.md`.

## Why V1.4

Live Fred operation exposed a simple tension:

- a 30-minute heartbeat is useful as a recovery/scheduling safety net, but can be slow for fresh human/Guardian input;
- polling itself is cheap, while unnecessary coding-agent/model executions are the meaningful cost;
- reducing heartbeat frequency too aggressively can make scheduled work harder unless PRIMARY has another reliable way to wake promptly.

V1.4 addresses this with a small deterministic GitHub watcher rather than a new orchestration service.

## What V1.4 adds

### One-minute GitHub change watcher

`runtime/arep-watch-github.sh` is intended to run every minute.

It watches a deliberately narrow control surface:

- new Issues;
- reopened Issues;
- new/updated Issue comments that are not clearly self-produced PRIMARY comments from the configured execution platform.

If nothing relevant changed, the watcher exits without launching the coding agent.

When relevant input changes, it records a concise Git-ignored pending hint and requests an explicit `event` PRIMARY wake.

### Explicit event cycle

`arep-run.sh` now supports:

- `heartbeat`
- `event`
- `rejuvenation`

All three use the same local PRIMARY `flock`. Event wake is not another PRIMARY.

An event wake:

- bypasses heartbeat due-time because concrete durable input changed;
- respects `EVENT_ENABLED` and `paused` mode;
- receives an `event-<UTC timestamp>` Agent-Run ID;
- gets a concise `Wake reason: github-change` routing hint;
- must inspect current GitHub reality before consequential action;
- keeps pending input after failure or lock contention;
- clears pending input only after successful execution when it did not change during that run.

### Minimal local watcher state

Default Git-ignored state:

- `.arep/github-watch.cursor`
- `.arep/github-watch.lock`
- `.arep/github-event.pending`
- `.arep/primary.last`

There is no database, message queue, or event bus.

The first watcher run initializes its cursor to current time rather than replaying repository history.

### Self-loop suppression

V1.3 provenance is reused as a routing hint.

A clearly self-produced comment such as:

`[Fred | Codex | PRIMARY | VM-runtime]`

is normally suppressed as an event trigger for that Codex PRIMARY.

Guardian, Worker, Reviewer, human/unlabelled, and unknown-origin comments remain wake candidates.

This is conservative loop prevention, not authentication. When origin is ambiguous, prefer waking over silently discarding input.

### 30-minute active-agent backup heartbeat

V1.4 changes the generic active-agent normal heartbeat default/example from 15 minutes to **30 minutes**.

Recommended starting schedule:

- watcher poll: every 1 minute;
- heartbeat scheduler poll: every 5 minutes;
- normal backup heartbeat: every 30 minutes;
- fast/deadline heartbeat: every 5 minutes.

A successful heartbeat or event wake updates `.arep/primary.last`. Backup-heartbeat due calculation uses the latest successful productive PRIMARY completion, preventing an event run from being followed immediately by a redundant heartbeat.

### Scheduled work sooner than 30 minutes

The 30-minute heartbeat is a recovery/coordination safety loop, not an exact business scheduler.

If PRIMARY sees an authorized scheduled obligation that requires another wake before the next normal backup, it should explicitly switch to `fast` mode or `DEADLINE_MODE=true` early enough to meet the window, then restore normal state after the time-sensitive period when appropriate.

If the required action is sooner than fast cadence plus scheduler polling can reliably support, PRIMARY should continue within the current authorized cycle when practical or use an already-authorized explicit scheduler mechanism.

V1.4 deliberately does **not** automatically parse Issue prose or infer deadlines. Public Issue #4 remains the separate evidence-gated automatic-deadline-awareness question.

## What V1.4 deliberately does not add

No:

- webhook receiver;
- Redis/database queue;
- event bus;
- background worker pool;
- activity-based heartbeat scoring;
- automatic 1h/2h/6h idle-state cadence;
- day/night or quiet-hours logic;
- automatic deadline parsing;
- distributed lock;
- second PRIMARY.

Those remain future options only if live evidence proves the small cron-based design insufficient.

## Existing V1.3 foundations retained

- producer provenance and `Agent-Run` correlation;
- first-class experimental/approved skill lifecycle;
- one PRIMARY plus bounded workers and advisory Guardians;
- hot context always read, deep context only on demand;
- completion-anchored heartbeat timing;
- explicit `DEADLINE_MODE`;
- Issue 16 body as current runtime snapshot and comments as transition history;
- cold-start recovery as correctness baseline;
- no hidden provider-session continuity requirement.

## Existing-agent migration

For an existing agent, V1.4.x should be installed conservatively rather than by overwriting live work.

Recommended migration:

1. sync the public A Rep checkout to the current V1.4.x release;
2. add/retain V1.4 event/watcher config fields in the private agent config;
3. retain agent-specific provenance labels and deliberate rejuvenation settings;
4. set normal backup cadence to 30 minutes unless current evidence justifies another explicit setting;
5. keep the one-minute watcher cron and five-minute heartbeat poll;
6. run launcher/watcher syntax checks plus both regression suites when runtime code changed;
7. verify a human/Guardian/Reviewer comment wakes PRIMARY and a clearly self-produced PRIMARY comment does not loop;
8. if the agent has approved human-notification skills, update them to preserve the V1.4.1 notification provenance envelope;
9. reconcile Issue 16 with actual live state when runtime state changes;
10. do not manufacture new work merely to exercise the feature.

Existing private repositories and historical comments/notifications do not need rewriting.

## Live rollout status

The public framework defines A Rep V1.4.1. Individual agent repositories/runtimes may need a conservative sync before claiming they use the notification contract or any promoted notification skills.
