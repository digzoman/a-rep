# Current A Rep version

Current version, **A Rep V1.5.0**.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and supporting files define active behaviour. Historical changes belong in Git history and `CHANGELOG.md` rather than additive patches every agent must mentally compose.

## V1.5: optional durable work skills

V1.5 adds two small, optional, generic approved skills to the canonical private-agent scaffold:

- `plan-work` — human-readable Markdown planning/recovery for already-authorized work that spans multiple meaningful chunks or PRIMARY runs;
- `data-ledger` — Markdown + CSV structured working/audit records for evolving entity collections without creating a CRM or database.

They are optional by design. A Rep behaves exactly as before when an agent never uses either skill.

### plan-work

When useful, live artifacts are:

```text
work/plans/
  INDEX.md
  <plan-id>/
    PLAN.md
    EVENTS.md
```

`PLAN.md` is authoritative for current plan state. Its small header records status, current chunk, next action/due, wait, work Issue, version, update time, and last PRIMARY. `EVENTS.md` is concise chronological transition history. `INDEX.md` is generated convenience output and can be rebuilt by scanning `work/plans/*/PLAN.md`.

The state vocabulary (`READY`, `RUNNING`, `WAIT_UNTIL`, `WAIT_EVENT`, `WAIT_HUMAN`, `WAIT_GUARDIAN`, `BLOCKED`, `COMPLETE`, `CANCELLED`) is recovery vocabulary only. It is not an enforced workflow graph.

`planctl.py` intentionally provides only `reindex`, `status`, and `due`. PRIMARY edits normal Markdown, evaluates gates, chooses the next eligible chunk, and continues through the existing A Rep loop.

The skill does not add a scheduler. It reuses current event/heartbeat/fast/deadline behavior and may use an already-authorized external scheduler only when real timing requires one.

### data-ledger

When useful, live artifacts are:

```text
work/data/
  INDEX.md
  <ledger-id>/
    README.md
    snapshot.csv
    events.csv
```

The README records what the ledger is, provider truth, authoritative business source, local snapshot authority, record type, stable identity field, and last synchronization. `snapshot.csv` is the current structured working set with a ledger-specific schema. `events.csv` uses a tiny generic append envelope:

```text
timestamp,event_id,entity_id,event_type,source_id,context,note
```

`ledgerctl.py` intentionally provides only `reindex`, `find`, and idempotent `append-event`.

The skill explicitly distinguishes provider truth, business truth, and agent working/audit state. A local ledger must not silently become a competing CRM or override an authoritative external business system.

### Authority remains unchanged

Neither skill creates permission.

- A plan never expands the authority of the underlying work Issue/human instruction.
- Guardian review may satisfy a quality gate but cannot manufacture human approval.
- A notification can get the human's attention but is not itself approval.
- Data tool access does not create authority to mutate provider or business records.

## Runtime unchanged

V1.5 does **not** change the A Rep V1.4 runtime architecture.

The existing model remains:

- one persistent PRIMARY;
- one-minute GitHub watcher for narrow durable Issue activity;
- 30-minute normal backup heartbeat with five-minute scheduler polling;
- explicit fast/deadline behavior for known near-term obligations;
- optional external Guardian Angel;
- provenance-preserving human notifications from V1.4.1;
- cold-start recovery as the correctness baseline.

No new daemon, database, queue, scheduler, webhook service, workflow engine, CRM, skill registry, or second PRIMARY was added.

## Storage direction

V1.5 deliberately prefers beginner-readable durable files:

- Markdown for plans, state, metadata, registries, and human-readable history;
- CSV for structured tabular snapshots and event rows.

No JSON is required by either skill or helper.

## Existing-agent migration

Newly bootstrapped agents receive the two approved skill packages automatically because the bootstrap already copies the canonical scaffold.

Existing private agent repositories should upgrade conservatively after the framework release is accepted. Do not overwrite live work. Add the approved skill directories and documentation as appropriate, preserve agent-specific procedures/configuration, and let actual usage decide whether `work/plans/` or `work/data/` should ever be created.

No heartbeat/watcher migration is required solely for V1.5.
