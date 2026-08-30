# Current A Rep version

Current design target, A Rep V1 draft.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and current supporting files define active V1 behaviour. Historical changes belong in Git history or releases rather than additive patches that every agent must mentally compose.

Run 1 defined the minimum protocol.

Run 2 adds the minimum runtime and bootstrap implementation.

Current V1 runtime includes one shared local PRIMARY lease, heartbeat modes, deadline mode, nightly rejuvenation support, local raw logs, cold-start prompts, Codex and OpenCode CLI adapters, and a bootstrap script that creates the private agent repository skeleton and reserves Issues 1 through 20.

V1 deliberately excludes persistent multi-PRIMARY coordination, a team repository, distributed locking, a custom database, queues, workflow engines, custom memory servers, dashboards, and other orchestration infrastructure.

Run 3 remains the fresh-agent acceptance and simplification pass. V1 should not be considered ready for the first live agent until that pass is complete.
