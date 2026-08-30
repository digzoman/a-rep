# A Rep agent repository scaffold

This is the canonical V1.1 private-agent repository structure.

Top-level locations are deliberate. Prefer placing new material inside the existing zones rather than inventing new top-level directories.

- `admin/` durable operational and runtime documentation plus sanitized Git-visible logs.
- `config/` non-secret agent/runtime configuration.
- `scratch/` exploratory, untrusted working material.
- `procedures/` reviewed and trusted ways of working.
- `work/` artifacts produced while pursuing actual goals.
- `.arep/` local machine runtime state and raw logs; Git ignored.

Bootstrap replaces this root README with agent-specific identity information while preserving the same structural rules.
