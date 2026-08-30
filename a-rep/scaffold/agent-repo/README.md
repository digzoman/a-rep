# A Rep agent repository scaffold

This is the canonical V1.2 private-agent repository structure.

Top-level locations are deliberate. Prefer placing new material inside the existing zones rather than inventing new top-level directories.

- `admin/` durable operational and runtime documentation plus sanitized Git-visible logs.
- `config/` non-secret runtime configuration plus hot/deep strategic context.
- `scratch/` exploratory, untrusted working material.
- `procedures/` reviewed and trusted ways of working.
- `work/` artifacts produced while pursuing actual goals.
- `.arep/` local machine runtime state and raw logs; Git ignored.

`config/agent-context.md` is always-read hot context. `config/agent-context-deep.md` is loaded only when richer background is materially useful.

Bootstrap replaces this root README with agent-specific identity information and initializes the hot context identity/role while preserving the same structural rules.
