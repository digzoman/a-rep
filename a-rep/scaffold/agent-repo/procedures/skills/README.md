# procedures/skills

Approved durable reusable capability packages specific to this persistent agent.

Use one directory per approved skill:

`procedures/skills/<skill-name>/SKILL.md`

Promotion from `scratch/skills/` requires review and explicit human approval under the A Rep V1 trust boundary. Framework-shipped approved skills may also arrive through an accepted A Rep release.

Approved skills SHOULD carry an explicit version and should normally depend only on approved/stable resources. They must not silently depend on mutable experimental scratch skills/scripts because that would let trusted behaviour change underneath the approval boundary.

When practical, promote with a Git move/equivalent so normal history preserves the experimental lineage. Do not leave duplicate redirect stubs in scratch by default.

Approved skills still do not create authority. They describe trusted capability/how; the underlying action must remain authorized by current human instruction, standing authority, current work, and applicable A Rep rules.

## Framework-shipped optional skills

A Rep V1.5 ships two small optional generic skills:

- `plan-work` — use when already-authorized work spans multiple meaningful chunks or PRIMARY runs and benefits from durable Markdown recovery state.
- `data-ledger` — use when authorized repeated work needs a structured CSV working set or append-oriented audit trail without creating a competing CRM/database.

Neither is mandatory. Small work should remain small.

See the public A Rep `references/SKILLS.md` for lifecycle, metadata, dependencies, and promotion guidance.
