# A Rep V1.4 minimal runtime

The runtime is intentionally small. It wakes a capable coding agent and gives it enough durable coordinates to recover. The agent, not the shell script, decides the work.

V1.4 adds a deterministic GitHub event-wake path while preserving the existing one-PRIMARY architecture, local `flock`, explicit cadence controls, completion-anchored heartbeat timing, provenance, and cold-start recovery.

## Components

- `runtime/arep-run.sh` runs a `heartbeat`, `event`, or `rejuvenation` PRIMARY cycle.
- `runtime/arep-watch-github.sh` cheaply polls the configured agent GitHub repository and requests an `event` wake when relevant input changes.
- `runtime/arep.conf.example` is the per-agent runtime configuration example.
- `runtime/cron.example` shows the one-minute GitHub watcher, five-minute heartbeat poll, and optional rejuvenation schedule.
- `prompts/heartbeat.md`, `prompts/event.md`, and `prompts/rejuvenation.md` are cold-start PRIMARY prompts.
- `prompts/guardian.md` is an optional external advisory-review prompt and is not run by the PRIMARY launcher.
- `scripts/bootstrap-agent.sh` creates the private agent-repository skeleton and reserves Issues 1 through 20.
- `tests/runtime-test.sh` covers launcher behavior.
- `tests/github-watch-test.sh` covers watcher behavior.

See `EVENT_WAKE.md` for the detailed watcher contract.

## One PRIMARY lease

Heartbeat, event, and rejuvenation use the same `flock` lease at `.arep/primary.lock` by default.

The file's presence is not proof that a lock is held. `flock` ownership belongs to the live process and is released when that process exits.

This remains a local-machine V1 exclusion mechanism, not a distributed lock. Do not deliberately schedule the same PRIMARY mutator on multiple machines in V1.

The GitHub watcher has its own cheap watcher lock so overlapping one-minute polls exit. It does not bypass the PRIMARY lease.

Guardian Angel does not take the PRIMARY lease because it is advisory and normally writes only GitHub Issue comments.

## Wake types

A Rep V1.4 distinguishes three cycle types.

### Heartbeat

Periodic liveness/recovery/opportunity scan. It is the backup even when no GitHub event was detected.

### Event

Immediate PRIMARY wake requested by deterministic GitHub change detection. It bypasses heartbeat due-time but still respects `EVENT_ENABLED`, `paused` mode, and the PRIMARY lease.

### Rejuvenation

Optional lower-priority self-improvement cycle. Deadline mode suppresses rejuvenation.

## Heartbeat state and cadence

`.arep/heartbeat.last` remains the last successful heartbeat completion timestamp.

V1.4 adds `.arep/primary.last`, the last successful productive PRIMARY completion from either heartbeat or event wake.

Heartbeat due calculation uses the most recent of those two timestamps. This prevents a successful event wake from being followed immediately by a redundant backup heartbeat.

Cron may wake the heartbeat launcher more frequently than the desired model cadence. The launcher checks whether heartbeat is due and exits cheaply when it is not.

Supported heartbeat modes remain `fast`, `normal`, `slow`, and `paused`.

`DEADLINE_MODE=true` uses the fast interval unless heartbeat mode is explicitly paused. It also suppresses rejuvenation.

The cadence clock remains anchored to **successful productive PRIMARY completion**, not heartbeat start. The next backup heartbeat can start on the first scheduler poll at or after:

`latest successful heartbeat/event completion + selected heartbeat interval`

Consequences:

- `fast=5` does not guarantee exactly five minutes between cycle start timestamps;
- scheduler polling can add up to roughly one polling interval after the due time;
- a failed heartbeat/event does not advance productive success state;
- a successful event wake postpones the next backup heartbeat.

For active agents, V1.4 changes the recommended/default normal backup interval to **30 minutes**. The example heartbeat cron still polls every five minutes so fast/deadline mode can take effect.

`slow` remains an explicit operator/PRIMARY-selected mode. `paused` suppresses PRIMARY heartbeat and event execution.

## Scheduled work

The 30-minute backup heartbeat is a recovery loop, not an exact business-task scheduler.

If PRIMARY observes an authorized scheduled obligation that requires another wake before the next normal backup, it should explicitly use `HEARTBEAT_MODE=fast` or `DEADLINE_MODE=true` early enough to meet the window, then restore normal state after the time-sensitive period when appropriate.

If the required action is sooner than the configured fast interval plus scheduler polling can reliably provide, PRIMARY should not merely exit and hope for a later wake. Continue within the current authorized cycle when practical or use an already-authorized explicit scheduler mechanism.

The launcher does not parse Issue prose or automatically infer deadlines. Automatic deadline awareness remains a separate evidence-gated feature.

## GitHub watcher

The intended V1.4 schedule is one watcher invocation per minute:

```text
* * * * * .../arep-watch-github.sh .../config/arep.env
```

The watcher uses `gh api` and currently reacts to a deliberately narrow GitHub surface:

- new Issues;
- reopened Issues;
- new/updated Issue comments not clearly attributable to the configured platform's own PRIMARY provenance.

A newly created sub-Issue is naturally detected because it is a new Issue. Relationship-only sub-Issue metadata is not separately modeled.

The watcher does not launch the execution model if nothing relevant changed.

Default Git-ignored watcher files:

- `.arep/github-watch.cursor`
- `.arep/github-watch.lock`
- `.arep/github-event.pending`

On first run the watcher initializes its cursor to current time instead of replaying all history. Existing state is still recoverable by the backup heartbeat.

The cursor advances only after all GitHub reads succeed. The watcher writes the poll **start** timestamp as the new cursor so events created while the API calls are in flight are not silently skipped.

The current implementation intentionally uses a single page of up to 100 results per watched endpoint per poll. For a private single-agent control repo this is expected to be ample. Do not add pagination/queue machinery unless real event volume proves it necessary.

## Event pending state

When the watcher finds relevant changes, it appends concise hints to `.arep/github-event.pending`, keeping only a small recent tail, then calls:

```text
arep-run.sh event <config>
```

The hint is not authoritative work state. The event prompt instructs PRIMARY to inspect current GitHub reality before acting.

If the PRIMARY lease is already held, `arep-run.sh event` exits without consuming pending state; the next watcher poll retries.

If event execution fails, pending state remains.

If event execution succeeds, the launcher removes the pending file only when its checksum is unchanged from the start of the run. If new events arrived while PRIMARY was running, the file remains for a later retry. This prefers an occasional redundant wake over lost input.

## Self-loop suppression

A PRIMARY may itself post durable comments. Waking again on every self-comment can create an execution loop.

The watcher therefore treats a first-line provenance marker matching the configured execution Platform and Role `PRIMARY` as a self-produced routing signal and suppresses that comment as a wake trigger.

Guardian, Worker, Reviewer, Voice, human/unlabelled, and unknown-origin comments remain wake candidates.

This is a routing heuristic, not authentication. Provenance still does not create authority. When origin is ambiguous, prefer waking over silently discarding input.

PRIMARY should avoid posting comments merely to acknowledge an event wake.

## PRIMARY producer provenance and run IDs

Every executed heartbeat, event, or rejuvenation receives:

`<cycle>-<UTC timestamp>`

Examples:

- `heartbeat-20260831T170001Z`
- `event-20260831T170101Z`
- `rejuvenation-20260831T030000Z`

The launcher injects persistent Agent ID, Platform, Role `PRIMARY`, Instance, and `Agent-Run` into the execution prompt.

Optional non-secret config fields:

- `PROVENANCE_PLATFORM`
- `PROVENANCE_INSTANCE`

If one config drives several cycle types, a cycle-neutral instance label such as `VM-runtime` is often more accurate than `VM-heartbeat`.

PRIMARY should reuse the supplied provenance tuple and run ID on material durable comments, handoffs, sanitized admin logs, and agent-authored commit trailers when practical.

## Runtime record: Issue 16

Issue 16 is the canonical human-readable runtime/heartbeat/event-wake record for an agent repository.

Prefer:

- **Issue 16 body:** concise current runtime snapshot, including watcher state, event state, current heartbeat mode, deadline state, important intervals, scheduler state, and host/runtime facts worth seeing at a glance.
- **Issue 16 comments:** material runtime/cadence requests, transitions, rationale, and verification history.

Live/tracked runtime configuration and direct host evidence remain authoritative when Issue prose is stale or contradictory.

Issue 3 is not a second routine runtime log. Mirror only material cross-cutting actions, failures, recoveries, incidents, or major transitions worth preserving beyond Issue 16.

## Strategic context loading

Every heartbeat and event wake reads `config/agent-context.md` before selecting work.

`config/agent-context-deep.md` remains on-demand. First recover hot context and current work/system state; load deep context only when the resulting task or recovery need materially requires it.

No active work by itself is not a reason to load deep context.

## Execution engines

V1 directly supports two simple non-interactive CLI shapes:

- Codex: `codex exec PROMPT`
- OpenCode: `opencode run PROMPT`

Set `EXECUTION_DRIVER`, `EXECUTION_BIN`, and optionally `EXECUTION_MODEL` in the private agent config.

The persistent agent identity is not tied to either execution engine.

## Guardian scheduling

Guardian remains provider-agnostic and externally scheduled through ChatGPT tasks, Hermes, Claude scheduling, or another capable environment.

Guardian normally posts only Issue comments and does not mutate PRIMARY runtime state.

The V1.4 GitHub watcher means a material Guardian comment can wake PRIMARY promptly without Guardian becoming PRIMARY.

## Logging

Raw execution output and machine-local runtime artifacts live under `.arep/`, which is Git ignored.

The default raw output directory is `.arep/raw-logs/`.

Git-visible operational history belongs under `admin/logs/`. Record executed PRIMARY cycles when useful, not one-minute watcher polls or heartbeat polls that exit because no model wake was due.

Never intentionally print or persist secrets in either log tier or event hints.

## Bootstrap

`bootstrap-agent.sh` now writes the V1.4 event-wake configuration, 30-minute normal backup heartbeat, and local watcher/productive-success paths into a new agent repo config.

The runtime does not create/manage credentials, install coding agents, authenticate GitHub, or create the private GitHub repository itself.

The GitHub watcher requires an authenticated `gh` CLI available to the host.

## Regression tests

Run:

```text
sh a-rep/tests/runtime-test.sh
sh a-rep/tests/github-watch-test.sh
```

The tests use fake execution/GitHub binaries and do not call a live paid model.

Coverage includes:

- normal/fast/slow/paused cadence;
- explicit deadline behavior;
- success/failure timestamp semantics;
- heartbeat/event shared PRIMARY lock;
- event prompt/run-ID injection;
- pending event preservation/retry;
- event-success backup-heartbeat postponement;
- first-run cursor initialization;
- no-change cheap polling;
- external/Worker comment wake;
- self-PRIMARY comment suppression;
- new/reopened Issue wake;
- coalescing;
- API-failure cursor preservation.

## Deferred optimizations

V1.4 deliberately does not add:

- webhook delivery;
- activity-based backup cadence;
- day/night or quiet-hour scheduling;
- automatic deadline parsing;
- provider-thread continuity as correctness state;
- database/queue/event-bus infrastructure;
- a background worker pool;
- distributed locking.

Add any of these only after live use demonstrates a concrete problem that the current small design cannot solve.
