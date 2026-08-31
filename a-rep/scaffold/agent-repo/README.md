# A Rep agent repository scaffold

This is the canonical V1.3 private-agent repository structure.

Top-level locations are deliberate. Prefer placing new material inside the existing zones rather than inventing new top-level directories.

- `admin/` durable operational and runtime documentation plus sanitized Git-visible logs.
- `config/` non-secret runtime configuration plus hot/deep strategic context.
- `scratch/` exploratory, untrusted working material, including `scratch/skills/` experimental capability packages.
- `procedures/` reviewed and trusted ways of working, including `procedures/skills/` approved capability packages.
- `work/` artifacts produced while pursuing actual goals.
- `.arep/` local machine runtime state and raw logs; Git ignored.

`config/agent-context.md` is always-read hot context. `config/agent-context-deep.md` is loaded only when current work/recovery materially benefits from richer background.

Material agent-authored durable GitHub comments/reviews/handoffs should use A Rep producer provenance `[Agent | Platform | Role | Instance]`; launcher-run PRIMARY cycles also receive an `Agent-Run` identifier. Provenance identifies the producer and does not create authority.

Experimental skills may be created/evolved autonomously under `scratch/skills/` within current work authority. Promotion into `procedures/skills/` requires review and explicit human approval. Skills describe capability, not permission.

Bootstrap replaces this root README with agent-specific identity information and initializes the hot context identity/role while preserving the same structural rules.
