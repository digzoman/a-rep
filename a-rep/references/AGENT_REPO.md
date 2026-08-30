# A Rep V1 agent repository convention

Each persistent PRIMARY agent should have its own private repository.

The public A Rep repository explains the framework. The private agent repository contains the live agent's identity, state, Issues, procedures, memory, and work.

The first planned live agent is Fred, the Founder agent. Fred's repository is intentionally not part of A Rep Run 1.

## Required conceptual zones

### scratch

The sandbox.

The PRIMARY may create material here without asking permission when doing so helps the job.

Suggested subdirectories may include.

- `scratch/memory/`
- `scratch/notes/`
- `scratch/documents/`
- `scratch/scripts/`
- `scratch/experiments/`

These are suggestions, not mandatory bureaucracy.

Scratch memory is recollection and working context. It is lower authority than current external evidence, current work Issues, approved configuration, and reviewed procedures.

### procedures

Trusted operating material.

Typical content may include.

- SOPs.
- Reviewed documents.
- Skills.
- Tested scripts.
- Formal process descriptions.
- LangGraph-style graph descriptions where useful.

V1 rule. Material does not become trusted merely because the agent wrote it. Promotion from scratch into procedures requires review and human approval.

### work

Actual artifacts created while pursuing goals.

The structure beneath `work/` should follow the work itself rather than an A Rep taxonomy.

## Other repository state

Run 2 will define the minimal configuration, runtime logs, scheduler files, and bootstrap mechanism.

Avoid storing secrets in Git.

## GitHub Issues

Create the reserved system Issues before normal work so that real work can reliably start at Issue 21.

See `ISSUES.md` for the topology.

## Procedure promotion

The intended V1 path is lightweight.

1. Discover or invent a potentially reusable improvement.
2. Work on it in scratch.
3. Gather enough evidence to show why it is better or reusable.
4. Propose promotion.
5. Review it.
6. Obtain human approval in V1.
7. Move or merge the approved material into procedures.

A later A Rep version may support more autonomous governed promotion, but V1 starts conservatively.
