# Changelog

## 1.1.0

Hardening and canonicalization release based on the first live Fred installation.

- Added a canonical private-agent repository scaffold with README guidance.
- Added `admin/logs/` for sanitized Git-visible operational logs.
- Renamed the default local raw execution directory to `.arep/raw-logs/`.
- Moved recommended local PRIMARY lock and heartbeat timestamp files under `.arep/`.
- Updated bootstrap to copy the canonical scaffold.
- Added launcher regression tests using a fake execution driver.
- Clarified logging, runtime documentation, cold-start organization, and top-level directory conventions.
- Kept rejuvenation semantics and overall V1 architecture unchanged.
- Deferred bounded timeout/stuck-cycle handling and scaffold migration tooling until operating evidence justifies them.

## 1.0.0

Initial accepted V1 protocol, runtime, heartbeat/rejuvenation launcher, bootstrap, reserved Issue topology, and first-agent deployment model.
