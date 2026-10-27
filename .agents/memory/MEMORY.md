# Memory index

This directory is the project's memory store, committed to git so it is versioned and visible to the maintainer, to teammates and to every agent working here. `.claude/memory` is a symlink to it.

Convention:

- One markdown file per project-scoped fact worth remembering: decisions, constraints, gotchas, and context that cannot be derived from the code or the git history.
- Each file gets a one-line entry in this index: `- [Title](file.md) — one-line hook`.
- Update or delete memory files that turn out to be wrong rather than leaving stale ones, and keep this index in step.

This directory replaces any native or global memory feature for this project (Claude Code's `~/.claude/projects/<project>/memory/`, Cursor memories, or similar). Do not save project-scoped memories there; write them here.

## Memories

- [MiseKit TOML decision](misekit-toml-decision.md) — tabled: how MiseKit decodes TOML; ask before step 2.2 round-trip work
- [Manifest value serialization](manifest-value-serialization.md) — protocols refine ManifestValue and store an `XSerialization` enum; compiler limits found
- [Profile and CI as protocols](profile-ci-protocols.md) — ProfileSource/ProfileReference/CustomProfile, CI/GitHubActions; pending `.custom` docs edit; key-path crash
