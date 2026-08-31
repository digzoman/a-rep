# A Rep

A Rep is a lightweight, nondeterministic-first Repeating Agent Framework.

Its purpose is to let a capable coding agent operate as a persistent, goal-seeking, self-improving agent by following one portable skill and using a private Git repository as durable operating memory.

A Rep does not require a dedicated orchestration platform. In V1, the coding agent is the execution engine, the skill is the operating protocol, the agent repository is durable control/context/memory state, and a tiny scheduler provides wakeups.

## V1 thesis

A PRIMARY repeatedly reconstructs reality, reads concise strategic context, selects the highest-value eligible action, acts, verifies the result, records durable state, leaves a fresh-session handoff when needed, learns, and repeats.

A Rep begins with judgment rather than a predetermined workflow. Stable recurring behaviour may later be formalized into reviewed procedures, scripts, skills, or graph-based workflows.

## Portability

The persistent agent is not the current model session. Codex and OpenCode are directly supported by the minimal PRIMARY launcher, and other capable execution surfaces can be added without changing the agent's durable identity.

Cold-start recovery is the correctness baseline. Provider-session resumption may later be explored as an optional optimization.

## Repository layout

The portable skill is under `a-rep/`.

- `a-rep/SKILL.md`, current operating rules.
- `a-rep/references/`, protocol, Issue, repository, runtime, Guardian, provenance, skill, and influence references.
- `a-rep/prompts/`, cold-start heartbeat, rejuvenation, and optional Guardian prompts.
- `a-rep/runtime/`, the tiny launcher, config example, and cron example.
- `a-rep/scripts/bootstrap-agent.sh`, bootstrap for a new private PRIMARY-agent repository.
- `a-rep/scaffold/agent-repo/`, canonical private-agent filesystem scaffold.
- `a-rep/tests/`, lightweight runtime regression tests.

A bootstrapped agent repository reserves Issues 1 through 20 for A Rep system use. Real work starts at Issue 21.

## Strategic context

Every agent has two standardized context layers.

`config/agent-context.md` is the short hot context read every PRIMARY and Guardian cycle.

`config/agent-context-deep.md` contains richer background loaded only when materially useful. Deep context is not part of automatic baseline cold-start recovery. First recover hot context and current system/work state; load deep only when the resulting task or recovery need materially benefits from information absent from hot context.

This keeps every wake strategically grounded without forcing the model to reread all background every time. Context helps interpretation; Issue 2, Issue 4, current human instruction, approved procedures, and direct evidence remain authoritative where applicable.

## Producer provenance

V1.3 adds first-class lightweight producer provenance for environments where multiple agent surfaces share the same GitHub account or bot identity.

Material agent-authored GitHub comments, reviews, and handoffs SHOULD begin with:

`[Agent | Platform | Role | Instance]`

Examples:

- `[Fred | Codex | PRIMARY | VM-heartbeat]`
- `[Fred | ChatGPT | Guardian | Ampgent-project-chat]`
- `[Fred | Hermes | Guardian | laptop]`

Agent-authored Git commits SHOULD use an `Agent-Provenance:` trailer. The minimal launcher also supplies a UTC-stamped `Agent-Run` ID so heartbeat/rejuvenation comments, logs, raw logs, and commits can be correlated without a run database.

Provenance identifies the producer. It does **not** create authority, prove correctness, or make a Worker/Guardian into PRIMARY. Existing history without provenance remains valid.

See `a-rep/references/PROVENANCE.md`.

## First-class skills

V1.3 makes reusable capabilities a first-class A Rep concept while preserving the existing trust boundary.

Experimental skills:

`scratch/skills/<skill-name>/SKILL.md`

Approved skills:

`procedures/skills/<skill-name>/SKILL.md`

PRIMARY may create, test, and evolve experimental skills autonomously within current work authority. Promotion into `procedures/skills/` requires review and explicit human approval.

Skills may package instructions, judgment rules, prompts, checklists, scripts, templates, schemas, examples, tool-use patterns, evidence requirements, failure modes, and learned heuristics.

Approved skills SHOULD be explicitly versioned and should not silently depend on mutable experimental scratch resources.

A skill describes **capability/how**, not **permission**. The underlying action still requires normal authority.

No skill registry, database, package manager, marketplace, or dedicated skill API is required. Agents discover skills through ordinary filesystem listing and concise metadata.

See `a-rep/references/SKILLS.md`.

## Guardian Angel

A Rep includes an optional provider-agnostic Guardian Angel review loop.

A Guardian can be scheduled independently through ChatGPT, Hermes, Claude, or another capable surface. It reads the same durable context and work state, critically reviews PRIMARY direction, flags missing evidence/risk, suggests operational/coding/skill improvements, and may offer bounded help.

Guardian is advisory, not another PRIMARY. Its default write surface is GitHub Issue comments and it stays silent when there is nothing material to add.

Multiple Guardians can coexist; provenance distinguishes them even if they share the same GitHub transport identity.

## Runtime and observability

Cron wakes the PRIMARY launcher frequently. The launcher enforces one local PRIMARY lease and determines whether a heartbeat is due. The fresh coding-agent session reads the skill, hot context, private repository, and current evidence and decides what to do.

Raw coding-agent output lives under `.arep/raw-logs/`. Concise sanitized operational logs may be tracked under `admin/logs/`.

`DEADLINE_MODE=true` deterministically selects fast cadence unless paused. A Rep does not automatically infer approaching Issue deadlines.

Heartbeat cadence is completion-anchored: `.arep/heartbeat.last` advances only after a successful heartbeat finishes. The next execution starts on the first cron poll at or after `successful completion + selected interval`, so a five-minute fast interval is not an exact five-minute start-to-start promise.

V1.3's launcher adds a run ID and producer-provenance coordinates to the execution prompt, but does not change cadence, completion timing, locking, or one-PRIMARY semantics.

Issue 16 is the canonical human-readable runtime record: body for the current snapshot, comments for material transition history. Actual runtime config/direct host evidence remains authoritative if prose lags reality.

Rejuvenation uses the same PRIMARY lease and is suppressed during deadline mode.

No database, queue, custom orchestration server, workflow engine, memory service, or skill registry is required.

## Current status

A Rep V1.3.0 is the current V1 release. It adds producer provenance and a governed experimental-to-approved skill lifecycle based on live multi-agent use, while keeping the framework Git/file/Issue-native. See `CURRENT.md` and `CHANGELOG.md`.
