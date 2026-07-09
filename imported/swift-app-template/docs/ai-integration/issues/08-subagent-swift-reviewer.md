# Subagent — `swift-reviewer`

**Labels:** `ai-integration`, `subagent`, `code-review`
**Depends on:** #01

## Summary

A read-only review subagent that checks changes against *this template's* specific
rules — strict concurrency, no XCTest, Tuist-not-Xcode, two-package placement,
SwiftUI extension pattern — rather than generic Swift advice.

## Motivation

The repo already wires `claude-code-review.yml` to the generic
`code-review@claude-code-plugins` plugin. That's good for broad correctness, but
it doesn't know our conventions. A template-specific reviewer subagent:

- Flags the failure modes unique to this stack (editing `.xcodeproj`, logic in the
  App target, XCTest creeping in, `Sendable`/`@MainActor` violations under Swift
  6.2 `complete`).
- Is **read-only** (no Edit/Write) — it reports, the human/main thread decides.
- Can be invoked locally before pushing, or by `@claude` on a PR, reusing the same
  definition.

This is complementary to, not a replacement for, the existing generic PR review.
For security specifically, reference Anthropic's official `security-guidance`
plugin and Apple's `audit-xcode-security-settings` skill (#14, #01c) rather than
re-implementing security rules here.

## Proposed file

`.claude/agents/swift-reviewer.md`:

```markdown
---
name: swift-reviewer
description: >
  Reviews Swift changes against this project's conventions. Use before pushing or
  when asked to review a diff/PR. Read-only — reports findings, does not edit.
tools: Read, Grep, Glob, Bash
model: inherit
---

You review changes for this Tuist + two-package Swift project. Check for, and
report (with file:line) any of:

1. **Generated files edited** — changes to `*.xcodeproj`. Must be done via
   `Project.swift` + regenerate instead.
2. **XCTest usage** — any `import XCTest` / `XCTAssert*`. Must be Swift Testing
   (`#expect` / `try #require`).
3. **Concurrency** — `Sendable`/`@MainActor` violations or `@unchecked` escapes
   under `SWIFT_STRICT_CONCURRENCY = complete` (Swift 6.2).
4. **Placement** — business logic in the App package instead of Kit; the App
   depending direction reversed.
5. **SwiftUI pattern** — platform logic in a global `View` extension instead of a
   `private extension` of the view; property/init/method ordering.
6. **Test structure** — suites not following the threshold/naming rules.
7. **Lint** — run `CI=true LINT_MODE=STRICT ./Scripts/lint.sh` and surface
   violations.

Return a prioritized list (blocking vs nit). Do not modify files.
```

## Acceptance criteria

- [ ] Catches an introduced `XCTAssert`, an `.xcodeproj` edit, and logic placed in
      the App package in a test diff.
- [ ] Tool list contains no Edit/Write (read-only).
- [ ] Usable both locally and via `@claude` on a PR; does not conflict with the
      generic `claude-code-review.yml` flow (#12 documents how they coexist).

## References

- `CLAUDE.template.md` (concurrency, testing, architecture, SwiftUI).
- Existing `.github/workflows/claude-code-review.yml` (generic plugin review).
