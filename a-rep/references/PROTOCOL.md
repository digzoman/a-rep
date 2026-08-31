# A Rep V1.4 protocol

## 1. Persistent identity

The persistent agent is the combination of the current A Rep skill, its private agent repository, current durable work state, strategic context, approved procedures/skills, configuration, and verified external reality.

The execution surface is replaceable. A fresh Codex, OpenCode, Claude Code, or similar session should be able to recover the same agent when it has the required tools and access.

## 2. Cold-start recovery

Treat every PRIMARY invocation as recoverable from a cold start.

Before consequential action, establish at minimum:

- the authoritative agent repository;
- current A Rep skill version;
- `config/agent-context.md`, always;
- deep context only after the current task/recovery need is known and richer background materially helps;
- identity, purpose, and boundaries from system Issues;
- current system Issue state;
- open work Issues 21+;
- relevant approved procedures/skills;
- current runtime/event state;
- external evidence required to understand reality.

Do not force reality to match an old summary.

## 3. Strategic context

`config/agent-context.md` is hot context and should remain concise enough to read every PRIMARY/Guardian cycle.

`config/agent-context-deep.md` is cold context loaded on demand.

Context provides interpretation, not authority. Detailed actionable work belongs in Issues 21+.

## 4. Selection rule

A Rep does not prescribe a fixed workflow for open-ended work.

PRIMARY should choose the action with the best expected progress toward active goals after considering urgency, impact, dependencies, evidence, reversibility, authority, cost, and opportunity cost.

This is a judgment rule, not a deterministic scoring formula.

## 5. Continue versus wait

Continue immediately while useful authorized work is available.

Wait only when the next useful observation is genuinely time-dependent, an external condition must change, a protected human decision is required, or current constraints make additional work wasteful.

Heartbeat cadence is not a mandatory boundary between actions.

## 6. Work ownership and delegation

V1 has one PRIMARY mutating authoritative agent state at a time.

PRIMARY may do work directly or use bounded temporary workers/subagents. Workers do not become PRIMARY. A request to a worker is not proof it ran; PRIMARY remains responsible for reconciliation and evidence.

Avoid assigning the same mutable scope to multiple workers simultaneously.

## 7. Producer provenance

When several agent surfaces share one GitHub account, native GitHub authorship may identify only transport identity.

Material agent-authored durable posts SHOULD use:

`[Agent | Platform | Role | Instance]`

Core Roles: `PRIMARY`, `Worker`, `Guardian`, `Reviewer`, `Voice`.

Agent-authored commits SHOULD carry `Agent-Provenance:` and, when available, `Agent-Run:` trailers.

Provenance does not create authority or prove correctness.

## 8. Cross-cycle handoff

Fresh-session recovery is the correctness baseline.

When productive work remains incomplete, leave enough concise durable state on the relevant work Issue that another fresh PRIMARY cycle can continue without hidden session context.

Prefer result/evidence, remaining state, blockers/waits, and next useful step. Avoid ceremonial handoffs when nothing material changed.

## 9. Verification

Completion requires evidence appropriate to the goal.

Prefer direct current evidence from the relevant real system. A confident model statement is not equivalent to verification.

If evidence cannot be obtained, record uncertainty rather than inventing certainty.

## 10. Human gates

Interrupt the human when business intent, external effects, spend, credential/security boundaries, destructive or hard-to-reverse action, legal/compliance judgment, or missing authority make the decision consequential.

For reversible implementation mechanics inside already-authorized scope, PRIMARY should normally decide autonomously.

## 11. Guardian Angel

Guardian Angel is an optional advisory external review loop, not another PRIMARY.

Guardian reads the same hot context and relevant durable state, challenges assumptions, checks evidence/risk, suggests improvements, and may offer bounded help.

Guardian normally writes only GitHub Issue comments and SHOULD identify itself with provenance. PRIMARY reconciles those comments before acting.

A material Guardian comment may wake PRIMARY through the V1.4 GitHub watcher; that still does not give Guardian PRIMARY authority.

## 12. Canonical repository structure

Prefer top-level zones `admin/`, `config/`, `scratch/`, `procedures/`, and `work/`.

`.arep/` contains Git-ignored local runtime state, raw logs, watcher state, and pending event hints.

Project-specific organization should normally happen inside `work/` or `scratch/`.

## 13. First-class skills

Experimental skills live under:

`scratch/skills/<skill-name>/SKILL.md`

Approved skills live under:

`procedures/skills/<skill-name>/SKILL.md`

PRIMARY may autonomously create/evolve experimental skills inside current work authority. Promotion into `procedures/skills/` requires review and explicit human approval.

Skills describe capability, not permission.

## 14. Self-improvement lifecycle

The V1 trust boundary remains:

`experience -> scratch -> proposal -> review -> human approval -> procedures`

For reusable skills:

`live work -> learning -> scratch/skills -> evidence -> promotion proposal -> human approval -> procedures/skills`

Formalize only when doing so is likely to reduce meaningful repeated reasoning/tool work, recurring errors, or recovery cost.

## 15. Rejuvenation priority

Rejuvenation is useful idle-capacity work, not a competing manager.

Normal priority:

`trusted human intervention -> consequential active work -> normal PRIMARY work -> rejuvenation`

Deadline mode suppresses rejuvenation.

Activate rejuvenation based on useful execution history, not elapsed time alone.

## 16. Wake architecture

V1.4 separates **responsiveness** from **recovery**.

### Event wake

A deterministic GitHub watcher may run every minute and cheaply inspect a narrow durable control surface. It currently watches new Issues, reopened Issues, and new/updated Issue comments.

If nothing relevant changed, it exits without launching the model.

If input changed, it leaves a concise local hint and requests `arep-run.sh event`. Event execution uses the same PRIMARY lease and reconstructs authoritative current GitHub reality before acting.

The watcher uses provenance to suppress clearly self-produced PRIMARY comments from the configured platform. Ambiguous origin should wake rather than be silently discarded.

### Backup heartbeat

Heartbeat remains the liveness/recovery/opportunity fallback even if no event was observed.

For active agents, the recommended/default normal backup interval is 30 minutes. The heartbeat cron may poll every five minutes; due checks that are not yet due exit cheaply.

A successful event wake postpones the next backup heartbeat through `.arep/primary.last`.

### Scheduled work

The 30-minute backup is not an exact scheduler.

If PRIMARY knows authorized scheduled work requires another wake sooner than the next normal backup, it should explicitly use fast mode or `DEADLINE_MODE=true` early enough to meet the window, then restore normal state after the time-sensitive period when appropriate.

If the obligation is sooner than fast/poll cadence can reliably support, do not merely wait for a future heartbeat; continue within the current authorized cycle when practical or use an already-authorized explicit scheduler mechanism.

A Rep V1.4 does not automatically parse Issue prose or infer deadlines.

## 17. Runtime cadence

The launcher applies configured `fast`, `normal`, `slow`, or `paused` heartbeat cadence.

`DEADLINE_MODE=true` selects fast cadence unless paused.

Heartbeat timing is anchored to the most recent successful productive PRIMARY completion (heartbeat or event), plus the selected interval and scheduler polling granularity.

Launcher-run heartbeat/event/rejuvenation cycles receive UTC-stamped `Agent-Run` IDs.

`paused` suppresses both heartbeat and event PRIMARY execution. Pending event state may remain for later recovery.

## 18. Logging and observability

Raw launcher output belongs under Git-ignored `.arep/raw-logs/`.

Concise sanitized executed-cycle records may be tracked under `admin/logs/` when remote observability or future recovery benefits from them.

Do not create durable logs for one-minute watcher polls or heartbeat polls that did not launch the execution model.

Issue 16 is canonical for current runtime/cadence/watcher state and transition history. Issue 3 is reserved for material cross-cutting transitions, failures, recoveries, and incidents.

## 19. External world state

GitHub is durable agent control/memory, not necessarily the source of truth for the goal itself.

The authoritative environment depends on the work: CRM, email, accounting, calendar, project management, documents, websites, databases, communication systems, or other external state.

A Rep is environment-first while using the repository as persistent control/memory.

## 20. Recovery over process continuity

Continuity of evidence matters more than continuity of a particular model session.

A crashed or stale execution surface may be replaced by a fresh one if task, authority, current evidence, and durable state can be reconstructed safely.

Provider-session resumption may later be explored as an optimization, but it must never become the only source of continuity.

## 21. Simplicity test

Before adding framework machinery, ask whether a capable coding agent plus ordinary files/GitHub/cron can already solve the problem.

If yes, prefer instructions and small deterministic helpers over infrastructure.

V1.4 deliberately does not add a database, queue, webhook receiver, event bus, activity score, day/night scheduler, or automatic deadline parser. See `EVENT_WAKE.md`.
