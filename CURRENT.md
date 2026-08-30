# Current A Rep version

Current design target: A Rep V1 draft.

This repository uses a consolidated-current model.

The current `a-rep/SKILL.md` and current files under `a-rep/references/` define the active V1 design. Historical changes should be recovered from Git history or releases rather than layered as additive patches that every agent must mentally compose.

V1 deliberately excludes persistent multi-PRIMARY coordination, a team repository, a custom database, queues, workflow engines, custom memory servers, dashboards, and other orchestration infrastructure.

Run 1 defines the protocol only.

Run 2 will add the minimal runtime and bootstrap implementation.

Run 3 will test the framework from a fresh agent context and simplify it before V1 is considered ready for the first live agent.
