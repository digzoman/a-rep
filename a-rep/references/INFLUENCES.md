# A Rep design influences

A Rep is an independent lightweight framework. These systems provide useful concepts and vocabulary without becoming mandatory runtime dependencies.

## We Rep

Carry forward these principles.

- One PRIMARY owns coordination and prioritization.
- Durable state outranks conversational memory.
- Separate durable state, execution, and recovery concerns.
- Heartbeats provide liveness and recovery rather than pacing productive work.
- Direct bounded work should proceed immediately when safe rather than waiting for a polling cycle.
- A route is not proof that a worker started.
- Evidence continuity matters more than worker-process continuity.
- Prefer one mutable owner for one bounded mutable scope.
- Verify actual outcomes rather than trusting narration.
- Human interruption should be consequence-aware.
- Keep protected human authority distinct from agent provenance.
- Avoid orchestration infrastructure until experience proves it necessary.

Generalize We Rep beyond software by treating the relevant real-world systems as evidence sources while the agent repository remains durable control and memory state.

## LangGraph

Use LangGraph vocabulary when formalizing stable procedures, without requiring LangGraph for A Rep V1.

Useful terms include.

- State.
- Node.
- Edge.
- START.
- END.
- Command.
- Send.
- Interrupt.
- Checkpoint.
- Thread.
- Store.
- Subgraph.

The important conceptual distinction is that workflows follow predetermined paths while agents dynamically choose processes and tools. A Rep V1 intentionally starts agentic and nondeterministic.

Reference documentation.

https://docs.langchain.com/oss/python/langgraph/overview
https://docs.langchain.com/oss/python/langgraph/graph-api
https://docs.langchain.com/oss/python/langgraph/workflows-agents
https://docs.langchain.com/oss/python/langgraph/interrupts

## OpenClaw

Useful ideas include.

- Persistent agent workspaces.
- Skills as instructions around already-available tools.
- Lightweight heartbeat behaviour.
- Isolated temporary subagents.
- Governed self-improvement through proposals before trusted skill mutation.
- Hash-bound or stale-aware updates and rollback as later hardening options.
- Distinguishing reusable learning from one-off facts.

A Rep V1 adopts the conservative proposal-first spirit for procedure promotion, while keeping the mechanism much simpler.

Reference documentation.

https://docs.openclaw.ai/skills
https://docs.openclaw.ai/gateway/heartbeat
https://docs.openclaw.ai/tools/skill-workshop
https://docs.openclaw.ai/tools/self-learning

## Hermes Agent

Useful ideas include.

- Persistent goals that continue across turns.
- Completion contracts.
- Verification and hard quality gates.
- Fixed and adaptive recurring loops.
- Separating in-session loops from unattended cron work.
- Persistent agent profiles and richer multi-agent coordination as later-version references.

A Rep borrows the completion-contract concepts of outcome, verification, constraints, boundaries, and stop conditions while keeping the Issue format flexible.

Reference documentation.

https://hermes-agent.nousresearch.com/docs/user-guide/features/goals
https://hermes-agent.nousresearch.com/docs/user-guide/features/loops
https://hermes-agent.nousresearch.com/docs/user-guide/features/kanban

## Agent Skills

A Rep's portable skill should follow the open Agent Skills format where practical.

The skill lives in a directory containing `SKILL.md` with YAML frontmatter. Supporting material may live under `references/`, `scripts/`, and `assets/`. Progressive disclosure is preferred so the core skill stays concise and the agent loads supporting details only when needed.

Reference documentation.

https://agentskills.io/specification
