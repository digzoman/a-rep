---
name: data-ledger
status: approved
version: "1.0.0"
trigger: Use for authorized structured working records that evolve across repeated work.
owner: A Rep framework
approved_by: human
approved_on: 2026-09-01
related_skills: [plan-work]
---

# Data Ledger

## Purpose

Use a small Markdown + CSV ledger when an agent needs a reproducible structured working set or append-oriented audit trail across repeated work.

Potential uses include prospects, customers, vendors, experiments, research subjects, applications, assets, conversations, inventory, or other entity collections.

This is not a CRM and must not silently compete with an existing authoritative business system.

## Three truth layers

Always distinguish facts by source and authority:

1. **Provider truth** — raw provider facts such as Unipile messages, Gmail messages, GitHub objects, or Asana tasks.
2. **Business truth** — the organization's authoritative CRM, Google Sheet, database, or other approved business system when one exists.
3. **Agent working/audit state** — the local ledger used for reproducibility, selections, classifications, experiment state, recovery, and audit.

Authority is fact-specific. A provider may be authoritative for whether a message was received while a CRM is authoritative for a customer's business status. The local CSV is authoritative only for the agent working/audit facts explicitly assigned to it.

Tool capability does not create authority to edit any of these systems.

## Location

Create ledger artifacts only when needed:

```text
work/data/
  INDEX.md
  <ledger-id>/
    README.md
    snapshot.csv
    events.csv
```

`INDEX.md` is only a rebuildable convenience registry. The ledger's README and CSV files contain the durable ledger records.

## README.md metadata

Keep the metadata human-readable near the top:

```markdown
# Decision Aug 28 LinkedIn Ledger

Authoritative business source: Ampgent Master Prospect Database
Provider truth: Unipile
Local snapshot authority: working copy only
Record type: prospect
Identity field: linkedin_provider_id
Last synchronized: 2026-09-01T15:30:00-04:00

## Purpose

Track the working contact set and campaign evidence for the experiment.
```

The README should make clear:

- what the ledger represents;
- which business system is authoritative, if any;
- which provider contains relevant raw truth;
- whether `snapshot.csv` is a working copy, cache, audit view, or authoritative local working state;
- which field uniquely identifies records;
- when synchronization last occurred.

If there is no external authoritative business system, say so explicitly rather than leaving the field ambiguous.

## snapshot.csv

Use ordinary CSV for the current structured working set. The schema belongs to the ledger, not the framework.

A prospect ledger might use columns such as:

```text
linkedin_provider_id,name,linkedin_url,campaign,status,hypothesis,last_outbound,last_reply,next_action
```

Those are examples, not a universal schema.

Rules:

- prefer stable provider/business IDs over names;
- keep the declared identity field unique;
- preserve source IDs/links when useful;
- preserve timestamps when they materially matter;
- keep long reasoning in Markdown rather than giant CSV cells;
- copy only the data needed for the work; do not mirror entire provider histories by default.

CSV should remain easy to open in GitHub, Excel, Google Sheets, Python, shell tools, and text editors.

## events.csv

Use this small generic envelope:

```text
timestamp,event_id,entity_id,event_type,source_id,context,note
```

Event types are intentionally open-ended. Examples might include `record_discovered`, `record_selected`, `message_approved`, `message_sent`, `reply_received`, `followup_due`, `suppressed`, or `closed`, but the framework does not prescribe them.

For provider/business events, use a stable source event identifier as `event_id` whenever one exists. Otherwise create a stable logical event ID before appending.

Duplicate delivery of the same logical provider event must not create a duplicate logical row.

## ledgerctl.py

The helper intentionally has only three operations:

```sh
procedures/skills/data-ledger/ledgerctl.py reindex
procedures/skills/data-ledger/ledgerctl.py find <ledger-id> <entity-id>
procedures/skills/data-ledger/ledgerctl.py append-event <ledger-id> <event-id> <entity-id> <event-type> [options]
```

### reindex

Scans `work/data/*/README.md`, counts ordinary `snapshot.csv` rows, and rebuilds `work/data/INDEX.md`.

Deleting the index loses no ledger state.

### find

Reads the ledger's declared `Identity field` and prints the matching CSV row. Missing identities return not-found; duplicate identities fail because identity should be stable and unique.

### append-event

Appends one row using the fixed event envelope. `event_id` is the idempotency key.

If the same event ID already exists with the same entity, event type, and source ID, the command succeeds without appending another row. Reusing the same event ID for a conflicting entity/type/source fails loudly.

The helper does not implement snapshot upserts, synchronization, imports, exports, schemas, or a database.

## Synchronization and external authority

Do not build automatic Google Sheets/CRM/provider synchronization merely because this skill exists.

When an external business system is authoritative:

- label it in `README.md`;
- label `snapshot.csv` as a snapshot/cache/working copy as appropriate;
- reconcile external truth before consequential use when staleness matters;
- write back to the external system only when current task authority permits it.

A local ledger may contain legitimate agent-only working facts that do not belong in the business system. Make that distinction explicit rather than pretending the local CSV is globally authoritative.

## Security and data minimization

Never place secrets in Markdown, CSV, Git, logs, Google Sheets, or other human-visible ledger records.

Do not store API keys, tokens, cookies, private keys, passwords, or raw secret-file contents.

Also minimize non-secret sensitive data. Do not copy raw message bodies, full inbox histories, or unnecessary personal information into Git merely because a provider exposes it. Prefer stable IDs, concise derived facts, and source pointers when that is sufficient.

## Recovery

A fresh PRIMARY can recover a ledger by:

1. reading `work/data/INDEX.md` if present;
2. opening the relevant `README.md` to recover authority/source/identity rules;
3. reading only the needed rows from `snapshot.csv` and `events.csv`;
4. reconciling against current provider/business truth when necessary.

If `INDEX.md` is missing, scan `work/data/*/README.md`. No authoritative ledger state is lost.

## Failure modes

- names used as identity despite a stable provider/system ID being available;
- duplicate identity rows in `snapshot.csv`;
- duplicate logical provider events;
- stale local snapshot silently treated as current business truth;
- local ledger becoming an accidental competing CRM;
- huge narrative cells replacing readable Markdown reasoning;
- copying unnecessary private/provider content into Git;
- capability confused with authority to mutate external records.

## Anti-bloat

This skill is not:

- a database;
- a schema engine;
- a CRM;
- a generic import/export pipeline;
- a Google Sheets synchronizer;
- a replacement for provider systems;
- a replacement for an existing business system.

Use ordinary CSV and Markdown until real usage proves something more is necessary.
