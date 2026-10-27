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
- `swift-docc-plugin` is an approved root dependency, for `swift package generate-documentation` only; no target links it, so packages that depend on taylr never resolve it (2026-10-27).
- Model complex manifest choices as SwiftUI-style protocols (a protocol, concrete conforming types, static members via `extension P where Self == Concrete`), not enums with rich associated values. Payload-free choices stay `String`-raw enums. Existing enums move in #118 (2026-10-27).
- Never hand-write `==`: use synthesized `Equatable` all the way down. Ask about identity explicitly (e.g. compare `name`), never by redefining equality (2026-10-27).
- The `.ci` workflow file is `integration.yml` in apps and packages alike; no `taylr-` prefix on workflow files (2026-10-27).
- The `.android` matrix entry always takes an API level: `.android(api: Int)`, no default (2026-10-27).
- Allow-list docs-mandated short names (`CI`, `ci`, `s3`, `uv`) in every taylr-owned `.swiftlint.yml` instead of suppressing them per line (2026-10-27).
- Independent plan steps within a phase may run in parallel worktrees when the maintainer asks; dependent steps stack on an integration branch (2026-10-27).
