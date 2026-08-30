# A Rep

A Rep is a lightweight, nondeterministic-first Repeating Agent Framework.

Its purpose is to let a capable coding agent operate as a persistent, goal-seeking, self-improving agent by following one portable skill and using a private Git repository as durable operating memory.

A Rep does not require a dedicated orchestration platform. In V1, the coding agent is the execution engine, the skill is the operating protocol, the agent repository is durable control and memory state, and a tiny scheduler provides wakeups.

## V1 thesis

A PRIMARY repeatedly reconstructs reality, selects the highest-value eligible action, acts, verifies the result, records durable state, learns, and repeats.

A Rep begins with judgment rather than a predetermined workflow. Stable recurring behaviour may later be formalized into reviewed procedures, scripts, skills, or graph-based workflows.

## Portability

The persistent agent is not the current model session. Codex and OpenCode are directly supported by the minimal launcher, and other capable execution surfaces can be added without changing the agent's durable identity.

## Repository layout

The portable skill is under `a-rep/`.

- `a-rep/SKILL.md`, current operating rules.
- `a-rep/references/`, current protocol, Issue, repository, runtime, and influence references.
- `a-rep/prompts/`, cold-start heartbeat and rejuvenation prompts.
- `a-rep/runtime/`, the tiny launcher, config example, and cron example.
- `a-rep/scripts/bootstrap-agent.sh`, bootstrap for a new private PRIMARY-agent repository.
- `a-rep/scaffold/agent-repo/`, canonical private-agent filesystem scaffold.
- `a-rep/tests/`, lightweight runtime regression tests.

A bootstrapped agent repository reserves Issues 1 through 20 for A Rep system use. Real work starts at Issue 21.

## V1.1 hardening

V1.1 adds a canonical private-agent scaffold with `admin/`, `config/`, `scratch/`, `procedures/`, and `work/` zones; moves recommended local runtime state under Git-ignored `.arep/`; splits raw logs from sanitized Git-visible operational logs; and adds automated launcher regression tests.

Raw coding-agent output lives under `.arep/raw-logs/`. Concise sanitized operational logs may be tracked under `admin/logs/`.

## Runtime philosophy

Cron wakes the launcher frequently. The launcher enforces one local PRIMARY lease and determines whether a heartbeat is due. The fresh coding-agent session reads the skill and private agent repository and decides what to do.

Rejuvenation uses the same lease and is suppressed during deadline mode.

No database, queue, custom orchestration server, workflow engine, or memory service is required.

## Current status

A Rep V1.1 is the current hardened V1 release. See `CURRENT.md` and `CHANGELOG.md`.
