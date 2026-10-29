# Agent notes

A running, append-only log of the maintainer's corrections and standing always/never directives for this repository. `.claude/agent-notes.md` is a symlink to this file.

How to use this file:

- Read it at the start of every session, before doing any work.
- Append one line per directive, proactively and without being asked, whenever the maintainer corrects you or gives an always/never instruction.
- Newest lines go at the bottom. One line per entry.
- When a directive supersedes an earlier one, update or remove the stale line rather than leaving both.

## Directives

- Always expose `TaylrKit` as a library product of the root package, next to `TaylrDescription` (not only as an internal target).
- Each GitHub issue must be small enough for one PR. A plan step too big for one PR becomes a parent issue with sub-issues; one milestone per plan phase (2026-10-26).
- Never state which macOS version taylr itself runs on in READMEs or docs; say "macOS" only. Package.swift platforms are unaffected (2026-10-26).
- Shared manifest concepts (storage, secrets, Apple team, GitHub organization) are root types in `TaylrDescription`, not nested under the one type that uses them first; types specific to one service (GitHub Actions) stay nested under it (2026-10-29).
