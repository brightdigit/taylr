# Subagent — `swift-test-writer`

**Labels:** `ai-integration`, `subagent`, `testing`
**Depends on:** #01, #04

## Summary

A delegated subagent specialized in writing/expanding the Kit package's test
suite to the template's Swift Testing conventions, in its own context window, with
a restricted toolset.

## Motivation

Writing a comprehensive test suite is a verbose, file-heavy task (read source,
enumerate cases, create multiple `+Category.swift` files, run, iterate). Doing it
inline pollutes the main conversation. A subagent:

- Runs in an **isolated context** and returns just a summary.
- Carries the conventions as a focused system prompt (reinforced by skill #04).
- Can be **tool-restricted** to read/write/test — no Fastlane, no destructive
  Bash — so a "write tests" delegation can't wander.

## Proposed file

`.claude/agents/swift-test-writer.md`:

```markdown
---
name: swift-test-writer
description: >
  Writes and expands Swift Testing suites for the Kit package following project
  conventions. Use when asked to add tests, improve coverage, or test a new type.
tools: Read, Edit, Write, Grep, Glob, Bash
model: inherit
---

You write tests for `Packages/{{TEMPLATE_APP_NAME}}Kit` using **Swift Testing
only** (never XCTest). Follow the project's swift-testing skill exactly:

- Suite thresholds: <10 → single `@Suite struct`; ≥10 / multi-category → parent
  `enum <Thing>Tests` + per-category `extension` files; child structs drop the
  `Tests` suffix; file names mirror types (`AppModelTests+Initialization.swift`).
- `private static let` test data via `Self.`; `#expect` / `try #require` only.
- Platform traits via `.enabled(if: Platform.isMacOS)` at suite level.
- MARK order: Test Data Setup → Initialization → Functional → Error Handling → Edge Cases.

Workflow: read the target type, enumerate behaviors and edge cases, create/modify
the test files, then run
`swift test --package-path Packages/{{TEMPLATE_APP_NAME}}Kit` and iterate until
green. Return a concise summary: files added, suites/cases, pass/fail.
```

## Acceptance criteria

- [ ] `@claude` (or local) delegation to write tests produces convention-correct
      suites and runs them.
- [ ] Tool list excludes Fastlane/distribution commands.
- [ ] Real Kit path after `setup.sh`.
- [ ] Returns a summary, not a full file dump, to the main thread.

## References

- Skill #04 (swift-testing conventions), `CLAUDE.template.md` testing section.
- [Subagents docs](https://code.claude.com/docs/en/sub-agents.md)
