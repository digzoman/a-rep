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
- `a-rep/references/`, protocol, Issue, repository, runtime, Guardian, and influence references.
- `a-rep/prompts/`, cold-start heartbeat, rejuvenation, and optional Guardian prompts.
- `a-rep/runtime/`, the tiny launcher, config example, and cron example.
- `a-rep/scripts/bootstrap-agent.sh`, bootstrap for a new private PRIMARY-agent repository.
- `a-rep/scaffold/agent-repo/`, canonical private-agent filesystem scaffold.
- `a-rep/tests/`, lightweight runtime regression tests.

A bootstrapped agent repository reserves Issues 1 through 20 for A Rep system use. Real work starts at Issue 21.

## Strategic context

Every agent has two standardized context layers.

`config/agent-context.md` is the short hot context read every PRIMARY and Guardian cycle.

`config/agent-context-deep.md` contains richer background loaded only when materially useful. V1.2.1 makes that rule explicit: deep context is not part of automatic baseline cold-start recovery. First recover hot context and current system/work state; load deep only when the resulting task or recovery need materially benefits from information absent from hot context.

This keeps every wake strategically grounded without forcing the model to reread all background every time. Context helps interpretation; Issue 2, Issue 4, current human instruction, approved procedures, and direct evidence remain authoritative where applicable.

## Guardian Angel

A Rep includes an optional provider-agnostic Guardian Angel review loop.

A Guardian can be scheduled independently through ChatGPT, Claude, or another capable surface. It reads the same durable context and work state, critically reviews PRIMARY direction, flags missing evidence/risk, suggests operational or coding improvements, and may offer bounded help.

Guardian is advisory, not another PRIMARY. Its default write surface is GitHub Issue comments and it stays silent when there is nothing material to add.

## Runtime and observability

Cron wakes the PRIMARY launcher frequently. The launcher enforces one local PRIMARY lease and determines whether a heartbeat is due. The fresh coding-agent session reads the skill, hot context, private repository, and current evidence and decides what to do.

Raw coding-agent output lives under `.arep/raw-logs/`. Concise sanitized operational logs may be tracked under `admin/logs/`.

`DEADLINE_MODE=true` deterministically selects fast cadence unless paused. A Rep does not automatically infer approaching Issue deadlines.

Heartbeat cadence is completion-anchored: `.arep/heartbeat.last` advances only after a successful heartbeat finishes. The next execution starts on the first cron poll at or after `successful completion + selected interval`, so a five-minute fast interval is not an exact five-minute start-to-start promise.

Issue 16 is the canonical human-readable runtime record: body for the current snapshot, comments for material transition history. Actual runtime config/direct host evidence remains authoritative if prose lags reality.

Rejuvenation uses the same PRIMARY lease and is suppressed during deadline mode.

No database, queue, custom orchestration server, workflow engine, or memory service is required.

## Current status

A Rep V1.2.1 is the current V1 release. It is a small evidence-backed hardening release from Fred's first real live Issue 21 acceptance test; launcher code and architecture remain unchanged. See `CURRENT.md` and `CHANGELOG.md`.
