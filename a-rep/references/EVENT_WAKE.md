# A Rep V1.4 event wake

V1.4 adds a lightweight deterministic GitHub change watcher so an idle PRIMARY can react quickly to durable input without running a paid/model execution every poll.

## Two wake paths

A Rep now distinguishes:

- **event wake** — deterministic GitHub evidence says something relevant changed;
- **backup heartbeat** — periodic liveness/recovery/opportunity scan even when no event was observed.

The watcher is not another agent and does not interpret business meaning. It only decides whether a fresh PRIMARY recovery is worth requesting.

## Default cadence

Recommended starting point for an active agent:

- GitHub watcher cron: every **1 minute**;
- heartbeat scheduler poll: every **5 minutes**;
- normal backup heartbeat: every **30 minutes**;
- fast/deadline heartbeat: every **5 minutes**.

The one-minute job is intentionally cheap. If nothing relevant changed, it exits without launching the execution model.

V1.4 deliberately does **not** add activity scoring, day/night schedules, automatic idle slowdowns, or a webhook receiver. Those remain evidence-gated optimizations.

## Watched GitHub changes

The minimal watcher reacts to:

- a new Issue;
- a reopened Issue;
- a new or updated Issue comment that is not clearly a self-produced PRIMARY comment from the configured execution platform.

A newly created sub-Issue is naturally a new Issue and is therefore seen. Relationship-only sub-Issue metadata is not separately modeled in V1.4.

The watcher does not try to interpret every label, assignment, body edit, reaction, commit, PR event, or project-board mutation. The 30-minute backup heartbeat remains the recovery net for events outside the small watcher surface.

## Local state

All watcher state is machine-local and Git ignored under `.arep/` by default:

- `.arep/github-watch.cursor` — last successful poll boundary;
- `.arep/github-watch.lock` — prevents overlapping watcher polls;
- `.arep/github-event.pending` — concise pending event hints;
- `.arep/primary.last` — last successful productive PRIMARY wake from heartbeat or event.

No database or queue is required.

On first watcher run, the cursor initializes to current time instead of replaying repository history. Existing repository state remains recoverable through the normal heartbeat.

The watcher advances its cursor only after all required GitHub reads succeed. It records the poll **start** time as the next cursor so changes created while the API calls are in flight are not silently skipped.

## Event wake path

When the watcher observes relevant changes, it writes only a concise hint, for example:

```text
- New Issue #23: Investigate failed campaign (...)
- New or updated Issue comment: ...
```

It then calls:

```text
arep-run.sh event <config>
```

The event launcher:

- uses the same PRIMARY `flock` as heartbeat/rejuvenation;
- respects `EVENT_ENABLED`;
- respects `paused` mode;
- bypasses heartbeat due-time because a concrete input change was observed;
- supplies `Wake reason: github-change` plus the concise hint;
- requires PRIMARY to inspect current GitHub reality before acting;
- generates an `event-<UTC timestamp>` Agent-Run ID;
- leaves pending state in place on execution failure;
- removes unchanged pending state only after successful execution.

If new pending input is appended while the event run is executing, checksum comparison prevents the launcher from deleting it. A later watcher poll retries it. This intentionally prefers an occasional redundant wake over lost input.

## PRIMARY lock contention

If Fred/PRIMARY is already running, the event launcher cannot acquire the shared PRIMARY lease and exits without consuming the pending event. The next one-minute watcher poll sees the pending file and retries.

No background worker pool or task queue is needed.

## Self-loop suppression

A PRIMARY may itself post durable GitHub comments. Waking again from every self-comment could create a feedback loop.

The watcher uses V1.3 provenance as a practical suppression signal. A comment whose first line clearly identifies the configured platform with Role `PRIMARY`, for example:

`[Fred | Codex | PRIMARY | VM-runtime]`

is normally treated as self-produced and does not cause an event wake.

Guardian, Worker, Reviewer, Voice, human/unlabelled, and unknown-origin comments remain wake candidates.

Provenance is not authentication and does not create authority. This suppression is a routing heuristic only. When origin is not clearly self-produced, prefer waking rather than silently discarding potentially important input.

PRIMARY should also avoid posting comments merely to acknowledge an event wake. Material durable writes only.

## Backup heartbeat and scheduled work

Event wake improves responsiveness but does not replace the heartbeat.

For active agents, V1.4 changes the example/default normal heartbeat from 15 minutes to **30 minutes**. A successful event wake writes `.arep/primary.last`, and heartbeat due calculation uses the most recent successful productive PRIMARY execution so a just-completed event run does not immediately trigger a redundant backup heartbeat.

Heartbeat timing remains completion-anchored and subject to scheduler polling granularity.

The 30-minute normal backup is not an exact business-task scheduler. If PRIMARY observes an authorized scheduled obligation that needs another wake sooner than the next normal backup, it should explicitly use existing `fast` or `DEADLINE_MODE=true` runtime controls early enough to meet the window, then restore normal state when appropriate.

If a required action is sooner than the configured fast/poll cadence can reliably provide, PRIMARY must not assume a future heartbeat will save it. Continue within the current authorized cycle when practical or use an already-authorized explicit scheduler mechanism.

V1.4 does not parse Issue prose or automatically infer deadlines. Public Issue #4 continues to track evidence-driven automatic deadline awareness separately.

## Paused mode

`paused` remains authoritative for PRIMARY execution. The watcher may continue recording changes cheaply, but `arep-run.sh event` does not launch PRIMARY while paused. Pending input remains for later reconciliation.

## Cron versus webhook

V1.4 intentionally starts with cron polling because it is portable, observable, and does not require inbound HTTPS infrastructure or webhook-secret handling.

A webhook can be reconsidered later if many agents make polling overhead meaningful or sub-minute response becomes important. If added, it should signal pending work and still route through the existing PRIMARY launcher/lease rather than executing a second path around A Rep concurrency rules.

## Non-goals

V1.4 does not add:

- Redis or another queue;
- a database;
- an event bus;
- a daemon mesh;
- a webhook receiver;
- a task scheduler/registry;
- automatic business-hour/night logic;
- activity-based heartbeat scoring;
- automatic deadline inference;
- a second PRIMARY.

The intended implementation remains: one small watcher, a few local files, one explicit `event` launcher mode, and the existing PRIMARY lock.
