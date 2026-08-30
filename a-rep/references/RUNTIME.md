# A Rep V1.2 minimal runtime

The runtime is intentionally small. It wakes a capable coding agent and gives it enough durable coordinates to recover. The agent, not the shell script, decides the work.

## Components

- `runtime/arep-run.sh` runs either a heartbeat or rejuvenation PRIMARY cycle.
- `runtime/arep.conf.example` is the small per-agent runtime configuration example.
- `runtime/cron.example` shows one frequent wake-up schedule plus one nightly rejuvenation schedule.
- `prompts/heartbeat.md` and `prompts/rejuvenation.md` are cold-start PRIMARY prompts.
- `prompts/guardian.md` is an optional external advisory-review prompt and is not run by the PRIMARY launcher.
- `scripts/bootstrap-agent.sh` creates the private agent-repository skeleton and reserves Issues 1 through 20.
- `scaffold/agent-repo/` is the canonical private-agent repository structure, including hot/deep context files.
- `tests/runtime-test.sh` is the lightweight regression suite for the launcher.

## One PRIMARY lease

Heartbeat and rejuvenation use the same `flock` lease. Keep the lease file at `.arep/primary.lock` in the private agent checkout.

The file's presence is not proof that a lock is held. `flock` ownership belongs to the live process and is released when that process exits.

This remains a local-machine V1 exclusion mechanism, not a distributed lock across machines. Do not deliberately schedule the same PRIMARY mutator on multiple machines in V1.

Guardian Angel does not take this lease because it is not PRIMARY and its default write surface is GitHub Issue comments rather than authoritative repository mutation.

## Heartbeat state and cadence

Keep `.arep/heartbeat.last` as the last successful heartbeat timestamp.

Cron may wake the launcher more frequently than the desired agent cadence. The launcher checks whether the heartbeat is due and exits cheaply when it is not.

Supported modes are `fast`, `normal`, `slow`, and `paused`.

`DEADLINE_MODE=true` uses the fast interval unless heartbeat mode is explicitly paused. It also suppresses rejuvenation.

Important V1.2 clarification: the shell launcher does not inspect GitHub Issue due dates and does not infer that a deadline is approaching. `DEADLINE_MODE` is explicit configured state. PRIMARY may change it when current evidence warrants and should record material rationale in Issue 16.

Temporary workers and Guardian may request cadence changes through Issue 16 but do not own runtime configuration.

The cron polling interval must be no slower than the configured fast interval if that fast cadence is expected to be achievable.

## Strategic context loading

Every heartbeat reads `config/agent-context.md` before selecting work.

`config/agent-context-deep.md` is intentionally on-demand. The model should load it when the hot context points to it, active work is unclear, or richer background materially improves execution.

The same hot/deep rule applies to Guardian review and, where useful, rejuvenation.

## Execution engines

V1 directly supports two simple non-interactive CLI shapes for PRIMARY runtime.

- Codex, `codex exec PROMPT`.
- OpenCode, `opencode run PROMPT`.

Set `EXECUTION_DRIVER`, `EXECUTION_BIN`, and optionally `EXECUTION_MODEL` in the private agent config. The persistent agent identity is not tied to either execution engine.

Heartbeat PRIMARY may use bounded subagents/workers if its execution surface provides them. That delegation remains model/tool behavior rather than new A Rep orchestration infrastructure.

## Guardian Angel scheduling

Guardian is provider-agnostic and externally scheduled.

ChatGPT tasks, Claude scheduling, or another capable execution environment may periodically invoke `prompts/guardian.md` with access to the public A Rep repository and the private agent repository.

An hourly cadence is a reasonable starting point for some agents, but A Rep does not prescribe one. Guardian should remain silent when nothing material warrants a comment.

Guardian normally posts only Issue comments and does not mutate PRIMARY runtime state. See `GUARDIAN.md`.

## Two logging levels

Raw execution output and machine-local runtime artifacts live under `.arep/`, which is Git ignored.

The default raw output directory is `.arep/raw-logs/`.

Raw logs may contain large command output, model text, or sensitive context and should not be committed merely for observability.

Git-visible operational history belongs under the tracked private-agent path `admin/logs/`. These entries must be concise and sanitized. Prefer a daily Markdown file and record only executed PRIMARY cycles, not scheduler polls that exit because a heartbeat is not due.

Issue 3 remains the cross-cutting durable trail for material actions, failures, recoveries, and major configuration transitions rather than routine cycle detail.

Never intentionally print or persist secrets in either log tier.

## Canonical private-agent scaffold

`scaffold/agent-repo/` defines the standard top-level zones:

- `admin/`, durable operational documentation and sanitized logs.
- `config/`, non-secret runtime configuration plus hot/deep strategic context.
- `scratch/`, exploratory working material.
- `procedures/`, reviewed trusted ways of working.
- `work/`, actual goal artifacts.
- `.arep/`, Git-ignored local runtime state and raw logs.

Prefer these top-level zones over inventing new ones. Project-specific organization should normally happen inside `work/` or `scratch/`.

## Bootstrap

Install or clone the public A Rep repository at a stable local path. Point `A_REP_SKILL_PATH` in the private agent configuration to its current `a-rep/SKILL.md`.

Run `sh a-rep/scripts/bootstrap-agent.sh` once against a newly created, empty private agent repository before creating normal work Issues. Bootstrap copies the canonical scaffold, writes the agent-specific runtime config, root README, and hot-context identity/role, then creates Issues 1 through 20 sequentially.

The repository must have no commits and an unused Issue/PR number space so the reserved Issues occupy numbers 1 through 20.

The runtime does not create or manage credentials, install coding agents, authenticate GitHub, or create the private GitHub repository itself.

## Regression tests

Run `sh a-rep/tests/runtime-test.sh`.

The suite uses a fake execution binary, not a live paid model call. It covers cadence modes, explicit deadline behaviour, missing configuration, execution failure, success timestamp behaviour, due-skip, PRIMARY lock contention, and rejuvenation suppression.

## Deferred runtime optimizations

V1.2 does not add provider-session/thread resumption as a continuity dependency. It may be explored later as a token/latency optimization, but durable cold-start recovery remains authoritative.

V1.2 also does not add a process timeout merely because cron polls frequently. The lease already prevents overlap. Add bounded timeout or stuck-cycle detection only when real operating evidence shows hanging or unexpectedly long executions.
