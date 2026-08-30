# A Rep V1 minimal runtime

The runtime is intentionally small. It wakes a capable coding agent and gives it enough durable coordinates to recover. The agent, not the shell script, decides the work.

## Components

- `runtime/arep-run.sh` runs either a heartbeat or rejuvenation cycle.
- `runtime/arep.conf.example` is the small per-agent runtime configuration example.
- `runtime/cron.example` shows one frequent wake-up schedule plus one nightly rejuvenation schedule.
- `prompts/heartbeat.md` and `prompts/rejuvenation.md` are cold-start prompts.
- `scripts/bootstrap-agent.sh` creates the private agent-repository skeleton and reserves Issues 1 through 20.

## One PRIMARY lease

Heartbeat and rejuvenation use the same `flock` lease keyed by `AGENT_REPO`. If another mutating PRIMARY cycle is already running on the same machine, the later invocation exits without doing work.

This is a local V1 exclusion mechanism, not a distributed lock across machines. Do not deliberately schedule the same PRIMARY mutator on multiple machines in V1.

## Heartbeat cadence

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

## Logs

Raw launcher output is written under `.arep/logs/` in the agent checkout with restrictive local file permissions. `.arep/` should be Git ignored.

Material durable events belong in the appropriate GitHub work Issue and in Issue 3 when they are significant enough for the cross-cutting execution trail.

Never intentionally print or persist secrets in agent output or durable records.

## Installation shape

Install or clone the public A Rep repository at a stable local path. Point `A_REP_SKILL_PATH` in the private agent configuration to its current `a-rep/SKILL.md`.

Run `sh a-rep/scripts/bootstrap-agent.sh` once against a new private agent repository before creating normal work Issues. The repository must have an unused Issue and PR number space so the reserved Issues occupy numbers 1 through 20.

The runtime does not create or manage credentials, install coding agents, authenticate GitHub, or create the private GitHub repository itself.
