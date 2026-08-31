# A Rep V1.3 agent repository convention

Each persistent PRIMARY agent has its own private repository.

The public A Rep repository defines the framework. The private agent repository contains live identity, state, Issues, strategic context, procedures, approved/experimental skills, scratch memory, configuration, operational records, and work.

The canonical scaffold lives at `scaffold/agent-repo/` and should be used for new agents. Existing agents may be patched forward conservatively without overwriting their work.

## Canonical top-level zones

Prefer these top-level locations rather than inventing new ones without a real structural need.

### admin

Durable operational information about the agent itself.

- `admin/logs/`, concise sanitized Git-visible records of executed cycles.
- `admin/runtime/`, machine/runtime installation, scheduler, verification, and recovery documentation.

Raw model/runtime output does not belong here.

Material executed-cycle log entries SHOULD identify producer provenance and reuse the launcher-provided `Agent-Run` when available.

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

The sandbox. PRIMARY may create material here without asking permission when it helps authorized work.

Canonical subdirectories are:

- `scratch/memory/`
- `scratch/notes/`
- `scratch/documents/`
- `scratch/scripts/`
- `scratch/skills/`
- `scratch/experiments/`

`scratch/skills/<skill-name>/SKILL.md` is the canonical home for experimental reusable capability packages. PRIMARY may create and evolve them autonomously within current work authority.

Scratch memory and experimental skills are recollection/capability drafts. They are lower authority/trust than current external evidence, current work Issues, approved configuration, and reviewed procedures.

### procedures

Trusted operating material.

Canonical subdirectories are:

- `procedures/sops/`
- `procedures/scripts/`
- `procedures/skills/`
- `procedures/graphs/`

`procedures/skills/<skill-name>/SKILL.md` contains approved reusable capability packages.

V1 rule: material does not become trusted merely because the agent wrote it. Promotion from scratch into procedures requires review and explicit human approval.

Approved skills SHOULD carry an explicit version and normally depend only on approved/stable resources. They must not silently depend on mutable scratch resources.

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

## Producer provenance

When multiple agents/surfaces share a GitHub account, native GitHub author metadata may identify only the transport.

Material agent-authored GitHub comments, reviews, and handoffs SHOULD begin with:

`[Agent | Platform | Role | Instance]`

Core Roles are defined in `PROVENANCE.md`.

Agent-authored commits SHOULD use `Agent-Provenance:` and, when available, `Agent-Run:` Git trailers.

Do not prefix mutable shared current-state bodies such as Issue 1 or Issue 16 with a producer header; use the accompanying comment/log/commit for provenance.

Provenance identifies producer identity. It never manufactures authority.

## Guardian communication

The optional Guardian Angel reads the same context files and relevant Issues but is not PRIMARY.

Guardian normally writes only Issue comments. Issue 11 Inbox is the default place for cross-cutting review, warnings, questions, and offers of bounded help. Task-specific review belongs on the relevant work Issue; operational/coding suggestions may go to Issues 14 and 15.

Guardian comments SHOULD use producer provenance so multiple Guardians sharing the same GitHub account are distinguishable.

## Skills

Skills are reusable capability packages and are first-class A Rep artifacts in V1.3.

Experimental:

`scratch/skills/<skill-name>/SKILL.md`

Approved:

`procedures/skills/<skill-name>/SKILL.md`

Do not create a manually synchronized skill index, registry, dependency manager, or package service in V1.3. List skill directories and inspect concise front matter when discovery is needed.

See `SKILLS.md` for lifecycle, trigger metadata, dependencies, promotion, Guardian review, and authority rules.

## GitHub Issues

Bootstrap the reserved system Issues before normal work so that real work reliably starts at Issue 21.

See `ISSUES.md` for the complete topology.

## Bootstrap

The public framework includes `scripts/bootstrap-agent.sh`.

It expects a newly created private GitHub repository with no commits and no existing Issues or pull requests. It copies the canonical scaffold, writes the agent-specific root README, runtime config, and hot context identity/role, commits the initial repository, then creates Issues 1 through 20 in order.

V1.3 scaffold includes both experimental `scratch/skills/` and approved `procedures/skills/` locations plus their lightweight guidance.

Before consequential real work, the human or PRIMARY should populate the mission and useful strategic context rather than leaving the hot-context placeholders empty.

The bootstrap does not create the GitHub repository itself and does not install or authenticate coding-agent CLIs.

## Procedure and skill promotion

The V1 path is deliberately conservative.

1. Discover or invent a potentially reusable improvement.
2. Work on it in scratch; for a reusable capability, normally use `scratch/skills/<skill-name>/`.
3. Gather evidence that it is useful, safer, or more reusable.
4. Check for substantial overlap with existing experimental/approved skills.
5. Propose promotion.
6. Review capability, evidence, dependencies, failure modes, and authority assumptions.
7. Obtain explicit human approval.
8. Promote the approved material into procedures; for a skill, use `procedures/skills/<skill-name>/`.

Use a Git move/equivalent when practical. Do not leave duplicate scratch redirect stubs by default; Git history is the normal audit trail.

A later version may support more autonomous governed promotion. V1.3 does not.
