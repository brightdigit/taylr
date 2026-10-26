# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, Xcode) working in this repository. `CLAUDE.md` is a symlink to this file.

## Project overview

taylr is a Swift CLI that creates a complete, ready-to-ship Swift app or Swift package from a few answers, then runs its everyday build, test, lint, sign and release commands. The published docs at [taylr.sh](https://taylr.sh) ([brightdigit/taylr.sh](https://github.com/brightdigit/taylr.sh/tree/main/src/content/docs/docs)) are the authority for user-facing behavior. The specification (`.claude/SPEC.md`) and the implementation plan (`.claude/PLAN.md`) order the work; when they disagree with the docs, the docs win and the disagreement is reported, not resolved.

## Package map

| Package | Location | Depends on | Holds |
| --- | --- | --- | --- |
| `TaylrDescription` | root target | nothing (Foundation only) | `App`, `Package`, `Packages`, `Profile`, `CI`, `License` and the rest of the manifest API, all `Codable`. The only module `Manifest.swift` imports. Published to `/api` with DocC. |
| `TaylrKit` | root target | TaylrDescription, ScaffoldKit, GitHubActionsKit, LintKit, MiseKit, DevContainerKit, XcodePilot | Profiles and `config.yml`, defaults resolution, manifest loading (compile + run + decode, cached), the `validate` rules, Keychain, and the `gh`, `tuist`, `fastlane`, `mise` and `git` wrappers. No terminal UI. |
| `taylr` | root executable | TaylrKit | The three command groups (`profile`, `project`, `package`), prompts, output and `--json`. Thin. |
| `ScaffoldKit` | `Packages/ScaffoldKit` | SyntaxKit, the model packages | `ProjectConfig`, the SyntaxKit generators, the fixed resources, and one `Scaffold.write(config, to:)` entry point. Does not know about TaylrDescription. |
| `GitHubActionsKit` | `Packages/GitHubActionsKit` | (Yams, later) | Workflow, jobs, steps, triggers, matrix, runners. |
| `LintKit` | `Packages/LintKit` | (Yams, Subprocess, later) | The shared lint-tool protocol, with one product per tool: `SwiftLintKit`, `SwiftFormatKit`, `HeaderKit`. |
| `MiseKit` | `Packages/MiseKit` | a minimal TOML encoder | `.mise.toml` tools, tasks and env. |
| `DevContainerKit` | `Packages/DevContainerKit` | Foundation | `devcontainer.json`. |
| `XcodePilot` | `Packages/XcodePilot` | ScriptingBridge, swift-subprocess | Xcode's scripting dictionary as `@objc` Swift protocols, compiled out where ScriptingBridge is missing; copied from Swoop. |
| `SyntaxKit` | `Packages/SyntaxKit` | swift-syntax | Vendored with `git subrepo` from brightdigit/SyntaxKit, branch `taylr`. |

Right now every package holds only a placeholder: Phase 0 of the plan is the repository skeleton.

### Boundaries

- **ScaffoldKit never touches git, GitHub, Keychain or network; TaylrKit never writes project files.**
- The model packages describe file formats and nothing else: no knowledge of taylr, no file I/O beyond encoding and decoding `Data`.
- A package under `Packages/` depends on siblings only through `.package(path: "../<Sibling>")` and never on the root. Each carries its own tests, lint configuration and license, so nothing is shared through the parent. The root `Package.swift` is the only place that knows they are local.
- **Never edit `Packages/SyntaxKit` by hand.** Changes go upstream with `git subrepo push Packages/SyntaxKit`, and come back with `git subrepo pull Packages/SyntaxKit`.

## Rules

- Do the plan's steps in order within a phase. Phases 1 and 2 can run in parallel; nothing else can.
- A step is done only when its "Done when" line is true and `swift build` and `swift test` pass for the affected package. Never mark a step done with failing or skipped tests.
- Do not add a dependency, a package, a public type or a CLI flag that the plan or the docs do not name. If one seems needed, stop and ask.
- Do not change the docs or the spec. Report anything that looks wrong as a question.
- Every public type in `TaylrDescription` gets a doc comment, because DocC publishes it.
- Swift 6 language mode, strict concurrency, Swift Testing (never XCTest), `swift-format` and SwiftLint clean.
- No secrets, Apple IDs, team IDs or real org names in tests or fixtures; use `Acme`, `com.acmecorp`, `ABCDE12345`.
- Report at the end of each step: what was created, test count, anything deferred and why.

## Commands

Every package, and the root, has the same `make` targets:

```bash
mise install   # once: the pinned swift-format and SwiftLint (Swift itself is pinned in .swift-version)
make build     # swift build
make test      # swift test
make lint      # header, swift-format and SwiftLint fixes, then a strict lint
```

`make lint` at the root lints only the root targets; run it inside `Packages/<Name>` for a package. In CI (`CI` set) `Scripts/lint.sh` only lints, never fixes. The tool versions live in `.mise.toml`; the same file is copied into every package.

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
- Fixture files go under the test target (`Tests/<Name>Tests/Fixtures/`) and are loaded with `Bundle.module`.
- Access control is explicit everywhere, tests included (`internal`, `private`), because SwiftLint's `explicit_acl` rule is on.

## Code style

- 2-space indentation, 100-column lines (`.swift-format`); SwiftLint's opt-in rules in `.swiftlint.yml` run in strict mode, so warnings fail.
- `InternalImportsByDefault` is enabled; write `public import` only when a public declaration needs the module.
- Every Swift file under `Sources/` starts with the MIT header that `Scripts/header.sh` writes; `make lint` adds or refreshes it.
- macOS-only code sits behind `#if canImport(<Framework>)` or `#if os(macOS)` so the Linux CI job still builds the root.
