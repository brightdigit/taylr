# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, Xcode) working in this repository. `CLAUDE.md` is a symlink to this file.

## Overview

XcodePilot drives a running Xcode from Swift through Xcode's AppleScript scripting dictionary: open a workspace or project, wait for a scheme to load, resolve a run destination, then build, debug or test. The `XcodeScriptingBridge` target declares the scripting dictionary by hand as `package`-scoped `@objc` protocols whose requirements are all `@objc optional`, with `SBApplication` and `SBObject` declared to conform; there are no generated headers, no bridging header and no Objective-C target. The `XcodePilot` target exposes `XcodeApp`, `XcodeWorkspaceDocument.debug(scheme:runDestination:...)`, `RunDestination` and `PilotError`, and parses `xcodebuild -showdestinations` output with the internal `Destination` type. It was copied from Swoop. It currently lives inside taylr's `Packages/` directory and taylr depends on it by path; it will move to its own repository.

Depends on ScriptingBridge (macOS only) and swift-subprocess.

## Boundaries

- Everything that uses ScriptingBridge sits behind `#if canImport(ScriptingBridge)`. On other platforms it compiles out, leaving the destination parser, so the package builds and its parser tests run on Linux.
- The only process XcodePilot launches is `xcodebuild -showdestinations`, through swift-subprocess. Unit tests never launch Xcode or `xcodebuild`; they parse captured output fixtures.
- Report failures by throwing `PilotError`, never with `fatalError()`.
- XcodePilot knows nothing about taylr.
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
  @Suite("Destination")
  internal enum DestinationTests {
    @Suite("parseFrom(output:)")
    internal struct ParseTests {
      private static let macID = "00006000-000A1B2C3D4E5F60"

      @Test("A macOS destination keeps its arch, id and name")
      internal func parsesMacDestination() throws {
        let destination = try #require(try Self.parsedFixture().first)
        #expect(destination.id == Self.macID)
      }
    }
  }
  ```

- Keep test data in `private static let` properties on the suite, not in locals repeated across tests.
- Assert with `#expect`; unwrap or stop early with `#require`.
- Give every `@Suite` and `@Test` a readable display name.
- Fixture files go under the test target (`Tests/XcodePilotTests/Fixtures/`) and are loaded with `Bundle.module`.
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
