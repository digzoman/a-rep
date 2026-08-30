# A Rep

A Rep is a lightweight, nondeterministic-first repeating agent framework.

Its purpose is to let a capable coding agent operate as a persistent, goal-seeking, self-improving agent by following one portable skill and using a Git repository as durable operating memory.

A Rep does not require a dedicated orchestration platform. In V1, the coding agent is the execution engine, the skill is the operating protocol, the agent repository is durable state, and a simple scheduler can provide wakeups.

## V1 thesis

A Rep begins with judgment rather than a predetermined workflow.

A PRIMARY repeatedly reconstructs reality, selects the highest-value eligible action, acts, verifies the result, records durable state, learns, and repeats.

Stable recurring behaviour may later be formalized into reviewed procedures, scripts, skills, or graph-based workflows.

## Portability

A Rep is designed to be execution-surface independent. Codex is the first intended execution surface, but the framework should also be usable by OpenCode, Claude Code, and other capable coding agents with suitable repository and tool access.

The persistent agent is not the current model session. Its durable identity and continuity live in the A Rep skill plus its own agent repository.

## Repository layout

The portable skill is under `a-rep/`.

- `a-rep/SKILL.md` contains the current operating rules.
- `a-rep/references/PROTOCOL.md` contains the V1 protocol.
- `a-rep/references/ISSUES.md` defines the reserved issue topology.
- `a-rep/references/AGENT_REPO.md` defines the private agent repository convention.
- `a-rep/references/INFLUENCES.md` records concepts intentionally borrowed from We Rep, LangGraph, OpenClaw, Hermes Agent, and Agent Skills.

Runtime scripts and bootstrap automation are intentionally deferred to Run 2.

## Current status

A Rep V1 is a draft under active development. See `CURRENT.md`.
