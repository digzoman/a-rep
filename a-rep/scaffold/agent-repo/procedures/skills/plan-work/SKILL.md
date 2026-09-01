---
name: plan-work
status: approved
version: "1.0.0"
trigger: Use for authorized work spanning multiple meaningful chunks or PRIMARY runs.
owner: A Rep framework
approved_by: human
approved_on: 2026-09-01
related_skills: [data-ledger]
---

# Plan Work

## Purpose

Use a small durable Markdown plan when already-authorized work is too large or stateful to recover reliably from one Issue comment or one PRIMARY run.

The same convention works for work lasting minutes, hours, days, or weeks. Do not create a second long-term planning system.

A plan never expands authority. Planning itself is normally not an approval gate.

## When to use

Use judgment. A plan is useful when work has several meaningful chunks, dependencies, acceptance criteria, waits, or evidence transitions that a fresh PRIMARY should recover cheaply.

Examples that may justify a plan:

- a multi-day experiment with many contacts and adaptation rules;
- a multi-week validation project;
- a staged implementation with independent acceptance criteria;
- work that repeatedly waits on human, Guardian, external evidence, or time.

Do not require a plan for small work such as checking whether somebody replied or doing one short research pass.

## Location

Create plan artifacts only when needed:

```text
work/plans/
  INDEX.md
  <plan-id>/
    PLAN.md
    EVENTS.md
```

`PLAN.md` is authoritative for current plan state. `EVENTS.md` is concise chronological transition history. `INDEX.md` is only a rebuildable convenience registry.

A substantial plan SHOULD point back to its existing Issue 21+ work radar rather than becoming a competing work queue.

## PLAN.md state header

Keep a small human-readable header near the top:

```markdown
# Decision Aug 28 LinkedIn Sprint

Status: WAIT_HUMAN
Current chunk: Approve Day 1
Next action: Wait for the human owner to approve outreach
Next due: none
Waiting on: human
Work issue: #28
Plan version: 1
Updated: 2026-09-01T15:45:00-04:00
Last PRIMARY: event-20260901T145902Z
```

For `Next due`, use `none` or an ISO-8601 timestamp with an explicit timezone. The helper does not infer deadlines from prose.

Supported state vocabulary:

- `READY`
- `RUNNING`
- `WAIT_UNTIL`
- `WAIT_EVENT`
- `WAIT_HUMAN`
- `WAIT_GUARDIAN`
- `BLOCKED`
- `COMPLETE`
- `CANCELLED`

These values are recovery vocabulary, not a workflow engine or enforced transition graph.

## Plan body

Normal Markdown is enough. Include what materially improves execution and recovery, such as:

- Goal
- Why a plan is warranted
- Scope
- Success criteria
- Constraints
- Assumptions
- Chunks or phases
- Estimated active work time
- Expected elapsed time where useful
- Dependencies
- Acceptance criteria per chunk
- Gate per chunk
- Expected outputs
- Stop conditions
- Replanning rules

A chunk can stay simple:

```markdown
## Chunk 3: Prepare Day 1 messages

Estimate: 45 minutes

Acceptance criteria:

- 20 primary contacts selected.
- 10 alternates selected.
- Every contact has a hypothesis and research question.

Gate: self

Next expected state: READY
```

## Gates and authority

A chunk may use a plain-language gate such as `self`, `guardian`, `human`, `external condition`, or `none`.

- `self` means PRIMARY may evaluate the acceptance criteria within existing authority.
- `guardian` means advisory review is required for quality. Guardian comments on the relevant work Issue; PRIMARY verifies the review and updates the plan.
- `human` means an existing authority rule requires a human decision. The plan does not manufacture approval.
- `external condition` means current external evidence must satisfy the stated condition.
- `none` means no separate gate beyond ordinary verification.

Guardian review can satisfy a quality gate but can never substitute for human authorization where human approval is independently required.

If an approved human-notification capability exists and prompt attention is warranted, entering `WAIT_HUMAN` may justify one concise notification with a durable source pointer. Notification delivery is not approval, and repeated pings are not implied.

## Rolling execution

Do not schedule an entire plan in advance.

At the end of a meaningful chunk:

1. Persist the result and strongest useful evidence.
2. Evaluate the chunk acceptance criteria.
3. Update the state header in `PLAN.md`.
4. Append a concise transition to `EVENTS.md`.
5. Determine the next state and next eligible action.
6. Continue immediately if the next chunk is eligible and the current PRIMARY context is healthy; otherwise leave a durable handoff and exit normally.

Do not launch PRIMARY directly from this skill and do not manufacture GitHub comments merely to wake the same PRIMARY.

Existing A Rep wake behavior remains authoritative:

- GitHub Issue activity may cause an `event` wake through the existing watcher;
- heartbeat remains the backup recovery loop;
- near-term known obligations may use existing fast/deadline behavior;
- an already-authorized external scheduler may be used when exact future timing genuinely requires it.

This skill adds no scheduler.

`WAIT_EVENT` means an externally observable condition is being awaited. It does not imply a webhook subscription exists. If no real event path exists, use a sensible fallback `Next due` check when appropriate.

A wake never creates authority.

## EVENTS.md

Keep events concise and chronological. Do not copy raw logs into this file.

```markdown
# Plan Events

## 2026-09-01 14:59 UTC

Event: chunk completed
Chunk: Day 1 packet
PRIMARY: event-20260901T145902Z

Twenty primaries and ten alternates completed. Evidence: work packet linked from Issue #28.

## 2026-09-01 15:00 UTC

Event: waiting human
Chunk: Approve Day 1

Waiting for the human owner to review the campaign. Source: Issue #28.
```

Point to durable evidence when useful rather than duplicating it.

## Replanning

Plans may change when evidence changes.

When a material replan is needed:

1. append why the plan changed to `EVENTS.md`;
2. increment `Plan version` in `PLAN.md`;
3. update remaining chunks;
4. preserve completed history;
5. recheck gates and authority.

Never rewrite history to make the original plan appear correct.

## Fresh PRIMARY recovery

A fresh PRIMARY can recover with ordinary files:

1. inspect `work/plans/INDEX.md` if present;
2. open the relevant `PLAN.md`;
3. read its small state header;
4. read enough recent `EVENTS.md` entries to understand the last transition;
5. reconcile the plan with current Issue/external evidence;
6. continue the next eligible chunk within current authority.

If `INDEX.md` is missing, scan `work/plans/*/PLAN.md`. No authoritative state is lost.

## planctl.py

`planctl.py` is deliberately mechanical. It does not create plans, transition states, execute chunks, evaluate gates, or schedule work.

From the agent repository root:

```sh
procedures/skills/plan-work/planctl.py reindex
procedures/skills/plan-work/planctl.py status
procedures/skills/plan-work/planctl.py due
```

`due` reports overdue plans plus future plans due within 24 hours by default. Use `--within-hours N` to change only that reporting horizon.

The helper reads `PLAN.md` directly. `INDEX.md` is generated output and never authoritative.

## Failure modes

- malformed state header: fail clearly rather than guessing;
- missing or timezone-free `Next due`: require `none` or an explicit timezone;
- stale plan versus current provider/business evidence: reconcile reality before consequential action;
- plan ceremony on trivial work: remove the plan and use the Issue directly;
- self-created wake loops: do not post comments solely to wake PRIMARY;
- authority drift: recheck the underlying Issue/human authority before consequential action.

## Anti-bloat

This skill is not:

- a workflow engine;
- a scheduler;
- a task database;
- a replacement for GitHub Issues;
- a second PRIMARY;
- a custom planning language.

If plain Markdown and the existing A Rep loop are enough, use them.
