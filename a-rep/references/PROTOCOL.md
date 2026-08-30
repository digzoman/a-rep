# A Rep V1.2 protocol

## 1. Persistent identity

The persistent agent is the combination of the current A Rep skill, its private agent repository, current durable work state, strategic context, approved procedures, configuration, and verified external reality.

The execution surface is replaceable. A fresh Codex, OpenCode, Claude Code, or similar session should be able to recover the same agent when it has the required tools and access.

## 2. Cold-start recovery

Treat every scheduled invocation as recoverable from a cold start.

Before consequential action, establish at minimum:

- which agent repository is authoritative;
- which A Rep skill version is current;
- `config/agent-context.md`, always;
- `config/agent-context-deep.md` when richer background is materially useful;
- the authoritative identity, purpose, and boundaries from system Issues;
- current system Issue state;
- open work Issues 21 and higher;
- current approved procedures relevant to the selected work;
- current runtime mode and any known wait condition;
- current external evidence required to understand reality.

Do not force reality to match an old summary.

## 3. Strategic context

`config/agent-context.md` is the hot strategic context and should remain concise enough to read every cycle.

`config/agent-context-deep.md` is cold context loaded on demand.

Context files provide interpretation, not authority. They do not override trusted human instruction, Issue 2, Issue 4, approved procedures, configuration, or direct current evidence.

Detailed actionable work belongs in Issues 21+.

## 4. Selection rule

A Rep does not prescribe a fixed workflow for open-ended work.

PRIMARY should choose the action with the best expected progress toward active goals after considering urgency, impact, dependencies, evidence, reversibility, authority, cost, and opportunity cost.

This is a judgment rule, not a deterministic scoring formula.

## 5. Continue versus wait

Continue immediately while useful authorized work is available.

Wait only when the next useful observation is genuinely time-dependent, an external condition must change, a tool or provider must recover, a protected human decision is required, or current constraints make additional work wasteful.

Heartbeat cadence is not a mandatory boundary between actions.

## 6. Work ownership and delegation

V1 has one PRIMARY mutating authoritative agent state at a time.

PRIMARY may do work directly. When it creates a bounded temporary worker or subagent, avoid assigning the same mutable scope to another worker simultaneously.

A request to a worker is not proof that work started. PRIMARY should determine whether the worker actually ran, reconcile the output against evidence, and reclaim stalled work when useful.

## 7. Cross-cycle handoff

Fresh-session recovery is the correctness baseline.

When productive work remains incomplete, leave enough concise durable state on the relevant work Issue that another fresh PRIMARY cycle can continue without hidden session context. Prefer result/evidence, remaining state, blockers/waits, and next useful step.

Do not add ceremonial handoff text when nothing material changed.

## 8. Verification

Completion requires evidence appropriate to the goal.

Prefer direct current evidence from the relevant system. A confident model statement is not equivalent to verification.

If evidence cannot be obtained, record the state as unverified rather than inventing certainty.

## 9. Human gates

Use a consequence-aware test before interrupting the human.

Ask whether the proposed action changes business intent, has an external effect, spends money, changes a credential or security boundary, is destructive or hard to reverse, creates material legal or compliance exposure, or requires authority the agent does not already possess.

If not, and the action is a reversible mechanic inside already-authorized scope, PRIMARY should normally decide it.

## 10. Guardian Angel

Guardian Angel is an optional advisory external review loop, not another PRIMARY.

Guardian reads the same hot context and relevant durable state, challenges assumptions, checks evidence and risk, suggests operational or coding improvements, and may offer bounded help.

Guardian normally writes only GitHub Issue comments. PRIMARY reconciles those comments before acting.

Guardian does not mutate PRIMARY runtime or priorities, promote procedures, manufacture authority, or take over work without explicit delegation. See `GUARDIAN.md`.

## 11. Canonical repository structure

Prefer the V1.2 top-level zones `admin/`, `config/`, `scratch/`, `procedures/`, and `work/` rather than inventing new top-level directories without a stable need.

- `admin/` contains durable operational documentation and sanitized Git-visible logs.
- `config/` contains non-secret runtime configuration plus hot/deep strategic context.
- `scratch/` contains exploratory, untrusted working material.
- `procedures/` contains reviewed trusted ways of working.
- `work/` contains artifacts produced while pursuing real goals.
- `.arep/` contains Git-ignored local runtime state and raw logs.

Project-specific organization should normally happen inside `work/` or `scratch/`.

## 12. Self-improvement lifecycle

The V1 trust boundary is simple.

`experience -> scratch -> proposal -> review -> human approval -> procedures`

Not every repeated action deserves formalization.

Formalize when doing so is likely to remove meaningful repeated reasoning or tool work, reduce recurring errors, improve recovery, or create a demonstrably better reusable method.

## 13. Rejuvenation priority

Rejuvenation is useful idle-capacity work, not a competing manager.

Normal priority is:

`trusted human intervention -> consequential active work -> normal heartbeat work -> rejuvenation`

Deadline or focus mode may suppress rejuvenation.

Activate rejuvenation based on useful execution history, not elapsed time alone.

## 14. Runtime cadence

The launcher deterministically applies configured fast, normal, slow, or paused cadence.

`DEADLINE_MODE=true` selects fast cadence unless paused and suppresses rejuvenation.

V1.2 does not automatically infer approaching GitHub Issue deadlines. Deadline mode is explicit runtime state unless a later evidence-driven feature changes that contract.

## 15. Logging and observability

Use two log tiers.

Raw launcher output belongs under Git-ignored `.arep/raw-logs/` and is for local debugging.

Concise sanitized executed-cycle records may be tracked under `admin/logs/` when remote observability or future recovery benefits from them. Do not create durable log entries for scheduler polls that skip because heartbeat is not due.

Issue 3 is reserved for material cross-cutting transitions, failures, recoveries, and configuration changes rather than routine cycle detail.

## 16. External world state

GitHub is durable agent memory and audit state, but it is not necessarily the source of truth for the goal itself.

The authoritative environment depends on the work. Examples include CRM, email, accounting, calendar, project management, documents, websites, databases, and communication systems.

A Rep is therefore environment-first while using the repository as the persistent control and memory surface.

## 17. Recovery over process continuity

Continuity of evidence matters more than continuity of a particular model session.

A crashed or stale execution surface may be replaced by a fresh one if the task, authority, current evidence, and durable state can be reconstructed safely.

Provider-session resumption may later be explored as an optimization, but it must never become the only source of continuity.

## 18. Simplicity test

Before adding framework machinery, ask whether a capable coding agent can already perform the function by reading the skill and ordinary repository state.

If yes, prefer instructions and conventions over new infrastructure.
