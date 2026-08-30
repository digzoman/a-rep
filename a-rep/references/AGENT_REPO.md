# A Rep V1 agent repository convention

Each persistent PRIMARY agent has its own private repository.

The public A Rep repository defines the framework. The private agent repository contains live identity, state, Issues, procedures, scratch memory, configuration, and work.

## Required zones

### scratch

The sandbox. PRIMARY may create material here without asking permission when it helps the job.

Useful subdirectories include `scratch/memory/`, `scratch/notes/`, `scratch/documents/`, `scratch/scripts/`, and `scratch/experiments/`.

Scratch memory is recollection and working context. It is lower authority than current external evidence, current work Issues, approved configuration, and reviewed procedures.

### procedures

Trusted operating material, including SOPs, reviewed documents, skills, tested scripts, formal process descriptions, and LangGraph-style graph descriptions where useful.

V1 rule. Material does not become trusted merely because the agent wrote it. Promotion from scratch into procedures requires review and human approval.

### work

Actual artifacts created while pursuing goals. Structure beneath `work/` should follow the work itself rather than an A Rep taxonomy.

## Configuration and local runtime state

The bootstrap creates `config/arep.env` as the small non-secret runtime configuration.

The launcher keeps raw process logs and local runtime artifacts under `.arep/`. That directory is Git ignored.

Do not store secrets in Git. Authentication for GitHub, coding agents, or external systems remains outside the repository unless a separate approved secret-management mechanism is used.

## GitHub Issues

Bootstrap the reserved system Issues before normal work so that real work reliably starts at Issue 21.

See `ISSUES.md` for the complete topology.

## Bootstrap

The public framework includes `scripts/bootstrap-agent.sh`.

It expects a newly created empty private GitHub repository with no commits, Issues, or pull requests. It clones the repository, creates the standard zones and config, makes the initial commit on `main`, sets `origin/main` as upstream, then creates Issues 1 through 20 in order.

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

A later version may support more autonomous governed promotion. V1 does not.
