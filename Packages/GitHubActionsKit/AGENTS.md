# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, Xcode) working in this repository. `CLAUDE.md` is a symlink to this file.

## Overview

GitHubActionsKit holds `Codable` models of GitHub Actions workflows, encoded to and decoded from YAML with Yams. The planned model covers `Workflow`, `Triggers` (push, pull request, workflow dispatch, schedule), `Job`, `RunsOn`, `Strategy`, `Matrix` (named dimensions plus `include` and `exclude`) and `Step` (`uses` or `run`). YAML keys use GitHub's spelling (`runs-on`, `timeout-minutes`, `working-directory`) through `CodingKeys`, and the `on` key must encode as `on`, not `true`. Right now the package holds only a placeholder. It currently lives inside taylr's `Packages/` directory and taylr depends on it by path; it will move to its own repository.

Depends on Yams.

## Boundaries

- GitHubActionsKit describes a file format and nothing else: no knowledge of taylr, no file I/O beyond encoding and decoding `Data`.
- It depends on sibling packages only through `.package(path: "../<Sibling>")`. It carries its own tests, lint configuration and license, so nothing is shared through a parent package.

## Rules

- Swift 6 language mode, strict concurrency, Swift Testing (never XCTest), `swift-format` and SwiftLint clean.
- A change is done only when `swift build` and `swift test` pass. Never leave failing or skipped tests.
- Do not add a dependency, a product, a public type or a public API that this file or the README does not name. If one seems needed, stop and ask.
- Every public type gets a doc comment.
- No secrets, Apple IDs, team IDs or real org names in tests or fixtures; use `Acme`, `com.acmecorp`, `ABCDE12345`.

## Commands

```bash
mise install   # once: the pinned swift-format and SwiftLint (Swift itself is pinned in .swift-version)
make build     # swift build
make test      # swift test
make lint      # header, swift-format and SwiftLint fixes, then a strict lint
make clean     # swift package clean and remove .build
```

In CI (`CI` set) `Scripts/lint.sh` only lints, never fixes. The tool versions live in `.mise.toml`.

## Swift Testing conventions

- Use Swift Testing (`import Testing`), never XCTest.
- Group tests under a parent `enum` suite named after the type or module, with nested `struct` suites per behavior:

  ```swift
  @Suite("Workflow")
  internal enum WorkflowTests {
    @Suite("Triggers")
    internal struct TriggerTests {
      private static let branch = "main"

      @Test("The on key encodes as on, not true")
      internal func encodesOnKey() throws {
        let yaml = try #require(try Self.encodedFixture())
        #expect(yaml.contains("on:"))
      }
    }
  }
  ```

- Keep test data in `private static let` properties on the suite, not in locals repeated across tests.
- Assert with `#expect`; unwrap or stop early with `#require`.
- Give every `@Suite` and `@Test` a readable display name.
- Fixture files go under the test target (`Tests/GitHubActionsKitTests/Fixtures/`) and are loaded with `Bundle.module`.
- Access control is explicit everywhere, tests included (`internal`, `private`), because SwiftLint's `explicit_acl` rule is on.

## Code style

- 2-space indentation, 100-column lines (`.swift-format`); SwiftLint's opt-in rules in `.swiftlint.yml` run in strict mode, so warnings fail.
- `InternalImportsByDefault` is enabled; write `public import` only when a public declaration needs the module.
- Every Swift file under `Sources/` starts with the MIT header that `Scripts/header.sh` writes; `make lint` adds or refreshes it.
- macOS-only code sits behind `#if canImport(<Framework>)` or `#if os(macOS)` so the package still builds on Linux.

## Memory & Corrections Convention

Two committed files are the source of truth for how to work in this repository:

- `.agents/agent-notes.md` (also `.claude/agent-notes.md`): an append-only log of the maintainer's corrections and always/never directives.
- `.agents/memory/MEMORY.md` (also `.claude/memory/MEMORY.md`): the index of the project's memory files, one file per project-scoped fact.

Read both before doing any work. Append corrections to the notes and memories to `.agents/memory/` proactively, without being asked. Never store project-scoped memories in a native or global memory system (such as Claude Code's `~/.claude/projects/.../memory/` or Cursor memories) instead of the repository.
