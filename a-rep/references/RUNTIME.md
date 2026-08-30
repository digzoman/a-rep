# A Rep V1.1 minimal runtime

The runtime is intentionally small. It wakes a capable coding agent and gives it enough durable coordinates to recover. The agent, not the shell script, decides the work.

## Components

- `runtime/arep-run.sh` runs either a heartbeat or rejuvenation cycle.
- `runtime/arep.conf.example` is the small per-agent runtime configuration example.
- `runtime/cron.example` shows one frequent wake-up schedule plus one nightly rejuvenation schedule.
- `prompts/heartbeat.md` and `prompts/rejuvenation.md` are cold-start prompts.
- `scripts/bootstrap-agent.sh` creates the private agent-repository skeleton and reserves Issues 1 through 20.
- `scaffold/agent-repo/` is the canonical private-agent repository structure.
- `tests/runtime-test.sh` is the lightweight regression suite for the launcher.

## One PRIMARY lease

Heartbeat and rejuvenation use the same `flock` lease. V1.1 recommends keeping the lease file at `.arep/primary.lock` in the private agent checkout.

The file's presence is not proof that a lock is held. `flock` ownership belongs to the live process and is released when that process exits.

This remains a local-machine V1 exclusion mechanism, not a distributed lock across machines. Do not deliberately schedule the same PRIMARY mutator on multiple machines in V1.

## Heartbeat state and cadence

V1.1 recommends `.arep/heartbeat.last` for the last successful heartbeat timestamp. Keeping it inside the agent's Git-ignored runtime directory makes local state easier to inspect and avoids dependence on `/tmp` persistence.

Cron may wake the launcher more frequently than the desired agent cadence. The launcher checks whether the heartbeat is due and exits cheaply when it is not.

Supported modes are `fast`, `normal`, `slow`, and `paused`.

`DEADLINE_MODE=true` uses the fast interval unless heartbeat mode is explicitly paused. It also suppresses rejuvenation.

PRIMARY may change the configured mode when reality warrants it and should record material rationale in Issue 16. Temporary workers may request changes through Issue 16 but do not own runtime configuration.

The cron polling interval must be no slower than the configured fast interval if that fast cadence is expected to be achievable.

## Execution engines

V1 directly supports two simple non-interactive CLI shapes.

- Codex, `codex exec PROMPT`.
- OpenCode, `opencode run PROMPT`.

Set `EXECUTION_DRIVER`, `EXECUTION_BIN`, and optionally `EXECUTION_MODEL` in the private agent config. The persistent agent identity is not tied to either execution engine.

## Two logging levels

Raw execution output and machine-local runtime artifacts live under `.arep/`, which is Git ignored.

The default raw output directory is:

` .arep/raw-logs/ `

Raw logs may contain large command output, model text, or sensitive context and should not be committed merely for observability.

Git-visible operational history belongs under the tracked private-agent path `admin/logs/`. These entries must be concise and sanitized. Prefer a daily Markdown file and record only executed cycles, not scheduler polls that exit because a heartbeat is not due.

Issue 3 remains the cross-cutting durable trail for material actions, failures, recoveries, and major configuration transitions rather than routine cycle detail.

Never intentionally print or persist secrets in either log tier.

## Canonical private-agent scaffold

`scaffold/agent-repo/` defines the standard top-level zones:

- `admin/`, durable operational documentation and sanitized logs.
- `config/`, non-secret configuration.
- `scratch/`, exploratory working material.
- `procedures/`, reviewed trusted ways of working.
- `work/`, actual goal artifacts.
- `.arep/`, Git-ignored local runtime state and raw logs.

Prefer these top-level zones over inventing new ones. Project-specific organization should normally happen inside `work/` or `scratch/`.

## Bootstrap

Install or clone the public A Rep repository at a stable local path. Point `A_REP_SKILL_PATH` in the private agent configuration to its current `a-rep/SKILL.md`.

Run `sh a-rep/scripts/bootstrap-agent.sh` once against a newly created, empty private agent repository before creating normal work Issues. Bootstrap copies the canonical scaffold, writes the agent-specific runtime config and root README, then creates Issues 1 through 20 sequentially.

The repository must have no commits and an unused Issue/PR number space so the reserved Issues occupy numbers 1 through 20.

The runtime does not create or manage credentials, install coding agents, authenticate GitHub, or create the private GitHub repository itself.

## Regression tests

Run:

`sh a-rep/tests/runtime-test.sh`

The suite uses a fake execution binary, not a live paid model call. It covers cadence modes, deadline behaviour, missing configuration, execution failure, success timestamp behaviour, due-skip, PRIMARY lock contention, and rejuvenation suppression.

## Deferred timeout policy

V1.1 does not add a process timeout merely because cron polls frequently. The lease already prevents overlap. Add bounded timeout or stuck-cycle detection only when real operating evidence shows hanging or unexpectedly long executions; track that as a future framework improvement rather than speculative runtime complexity.
