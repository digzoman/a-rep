# Current A Rep version

Current version, A Rep V1.

This repository uses a consolidated-current model. The current `a-rep/SKILL.md` and current supporting files define active V1 behaviour. Historical changes belong in Git history or releases rather than additive patches that every agent must mentally compose.

Run 1 defined the minimum protocol.

Run 2 added the minimum runtime and bootstrap implementation.

Run 3 performed the acceptance and simplification pass. It verified shell syntax, heartbeat due and skip behaviour, fast, normal, slow, paused and deadline semantics, the shared heartbeat and rejuvenation lease, rejuvenation suppression during deadline mode, Codex and OpenCode command shapes, failure propagation, bootstrap repository structure, Issues 1 through 20 ordering, and clean `main` branch tracking.

Run 3 found and fixed two material defects. Failed execution-engine runs now return their real nonzero exit status, and bootstrap now creates and tracks `main` correctly. Bootstrap also refuses a private repository that already contains commits.

The acceptance environment did not contain a live Codex or OpenCode binary, so execution-engine mechanics were tested with isolated stub drivers. The first live model and real-world acceptance target is the first persistent agent repository.

V1 deliberately excludes persistent multi-PRIMARY coordination, a team repository, distributed locking, a custom database, queues, workflow engines, custom memory servers, dashboards, and other orchestration infrastructure.

A Rep V1 is ready for its first live agent.
