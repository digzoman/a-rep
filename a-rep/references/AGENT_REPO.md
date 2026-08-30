# A Rep V1.2 agent repository convention

Each persistent PRIMARY agent has its own private repository.

The public A Rep repository defines the framework. The private agent repository contains live identity, state, Issues, strategic context, procedures, scratch memory, configuration, operational records, and work.

The canonical scaffold lives at `scaffold/agent-repo/` and should be used for new agents. Existing agents may be patched forward conservatively without overwriting their work.

## Canonical top-level zones

Prefer these top-level locations rather than inventing new ones without a real structural need.

### admin

Durable operational information about the agent itself.

- `admin/logs/`, concise sanitized Git-visible records of executed cycles.
- `admin/runtime/`, machine/runtime installation, scheduler, verification, and recovery documentation.

Raw model/runtime output does not belong here.

### config

Non-secret runtime configuration and durable strategic context.

Canonical files include:

- `config/arep.env`, runtime configuration.
- `config/agent-context.md`, concise hot strategic context read on every PRIMARY and Guardian cycle.
- `config/agent-context-deep.md`, richer cold context loaded only when materially useful.

Keep hot context compact enough to justify loading every cycle. Use deep context for organization history, richer strategy, stakeholders, long-lived constraints, terminology, and background.

Issue 2 remains authoritative for identity/charter and Issue 4 for human authority decisions. Context files assist reasoning and cannot create authority.

Machine paths and cadence may be tracked in runtime config. Credentials, tokens, API keys, and passwords must not be committed.

### scratch

The sandbox. PRIMARY may create material here without asking permission when it helps the job.

Canonical subdirectories are:

- `scratch/memory/`
- `scratch/notes/`
- `scratch/documents/`
- `scratch/scripts/`
- `scratch/experiments/`

Scratch memory is recollection and working context. It is lower authority than current external evidence, current work Issues, approved configuration, and reviewed procedures.

### procedures

Trusted operating material.

Canonical subdirectories are:

- `procedures/sops/`
- `procedures/scripts/`
- `procedures/skills/`
- `procedures/graphs/`

V1 rule: material does not become trusted merely because the agent wrote it. Promotion from scratch into procedures requires review and human approval.

### work

Actual artifacts created while pursuing goals. Structure beneath `work/` should follow the work itself rather than an A Rep taxonomy.

## Local runtime state

`.arep/` is the local, Git-ignored runtime directory.

Recommended locations are:

- `.arep/raw-logs/`, raw coding-agent stdout/stderr.
- `.arep/primary.lock`, local PRIMARY lease file.
- `.arep/heartbeat.last`, timestamp of the last successful heartbeat.

The lock file itself is not durable authority and its mere existence does not mean a process owns the lock.

## Logging distinction

Use `admin/logs/` when a human or future agent benefits from Git-visible operational history. Keep entries concise and sanitized.

Use `.arep/raw-logs/` for raw launcher output. It remains local and Git ignored because raw transcripts may be large or contain sensitive context.

Issue 3 is reserved for material cross-cutting transitions, failures, recoveries, and significant runtime changes rather than every heartbeat.

## Guardian communication

The optional Guardian Angel reads the same context files and relevant Issues but is not PRIMARY.

Guardian normally writes only Issue comments. Issue 11 Inbox is the default place for cross-cutting review, warnings, questions, and offers of bounded help. Task-specific review belongs on the relevant work Issue; operational/coding suggestions may go to Issues 14 and 15.

## GitHub Issues

Bootstrap the reserved system Issues before normal work so that real work reliably starts at Issue 21.

See `ISSUES.md` for the complete topology.

## Bootstrap

The public framework includes `scripts/bootstrap-agent.sh`.

It expects a newly created private GitHub repository with no commits and no existing Issues or pull requests. It copies the canonical scaffold, writes the agent-specific root README, runtime config, and hot context identity/role, commits the initial repository, then creates Issues 1 through 20 in order.

Before consequential real work, the human or PRIMARY should populate the mission and useful strategic context rather than leaving the hot-context placeholders empty.

The bootstrap does not create the GitHub repository itself and does not install or authenticate coding-agent CLIs.

## Procedure promotion

The V1 path is deliberately conservative.

1. Discover or invent a potentially reusable improvement.
2. Work on it in scratch.
3. Gather evidence that it is useful, safer, or more reusable.
4. Propose promotion.
5. Review it.
6. Obtain human approval.
7. Promote the approved material into procedures.

A later version may support more autonomous governed promotion. V1.2 does not.
