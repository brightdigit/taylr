# Skill — Swift Testing conventions

**Labels:** `ai-integration`, `skill`, `testing`
**Depends on:** #01, #01b, #01c

> **Source of truth:** the canonical testing conventions live in `AGENTS.md` (#01b)
> so every tool sees them. This skill is the on-demand **procedure** authored as a
> portable `SKILL.md` folder (#01c) — it *references* the `AGENTS.md` testing
> section, not restate it.
>
> **Boundary vs Xcode 27 (#01c):** Apple's built-in `test-modernizer` skill owns the
> generic **XCTest → Swift Testing migration**. This skill must NOT duplicate that —
> it covers only our **house conventions** Apple's skill doesn't know: suite-size
> thresholds, parent-`enum` + per-category `extension` layout, the file-naming
> mirror, `private static let` via `Self.`, suite-level `Platform` traits, and MARK
> order. Say so in the skill body and defer migration to Apple's.

## Summary

Encode the template's Swift Testing conventions as a **model-invoked skill** so
they load on demand whenever Claude writes or edits tests — instead of living
permanently in `CLAUDE.md` context (or being re-explained each session).

## Motivation

`CLAUDE.template.md` already specifies precise rules: Swift Testing only (no
XCTest), suite-structure thresholds (`<10` tests → single `@Suite struct`; `≥10`
→ parent `enum` + per-category extension files), file-naming mirror
(`AppModelTests+Initialization.swift`), `private static let` test data accessed
via `Self.`, `#expect`/`try #require`, platform traits via
`.enabled(if: Platform.isMacOS)`, and MARK ordering.

A skill is the right primitive because this is a **multi-step procedure with
reference detail** that's only relevant during test work — exactly the "load when
relevant" case skills are built for. It keeps `CLAUDE.md` lean while making the
rules executable.

## Proposed file

`.claude/skills/swift-testing/SKILL.md`:

```markdown
---
description: >
  Conventions for writing/editing tests in this project. Use whenever creating or
  modifying Swift test files. Swift Testing only — never XCTest.
---

# Swift Testing conventions

Test the Kit package: `swift test --package-path Packages/{{TEMPLATE_APP_NAME}}Kit`

## Suite structure
- < 10 tests: single `@Suite struct` in one file.
- ≥ 10 tests or multiple categories: parent `enum` named `<Thing>Tests` +
  per-category `extension` files. Child structs do NOT carry the `Tests` suffix.
- File name mirrors the type: `AppModelTests+Initialization.swift`
  (never `...+InitializationTests.swift`).

## Test data & assertions
- Test data is `private static let`, accessed via `Self.`.
- Assertions use `#expect(...)` and `try #require(...)`. Never `XCTAssert*`.

## Platform-conditional tests
- Use `TestHelpers/Platform.swift`'s `Platform` enum.
- Apply `.enabled(if: Platform.isMacOS)` at `@Suite` level (declare once) over
  per-`@Test`.

## MARK order in test files
`// MARK: - Test Data Setup` → `Initialization` → `Functional` →
`Error Handling` → `Edge Cases`.

See `Packages/{{TEMPLATE_APP_NAME}}Kit/Tests/.../AppModelTests.swift` for the
canonical example shipped with the template.
```

## Acceptance criteria

- [ ] Skill auto-loads when Claude is asked to write/modify a test (verified by a
      sample prompt producing a correctly-structured suite).
- [ ] Conventions are stated **once** in `AGENTS.md`; the skill references that
      section rather than duplicating it (no drift — coordinate in #01b/#12).
- [ ] After `setup.sh`, the skill references the real Kit package path.

## References

- `CLAUDE.template.md` → "Swift Testing Conventions".
- Shipped example tests under `Packages/{{TEMPLATE_APP_NAME}}Kit/Tests/`.
- Pairs with subagent #07 (`swift-test-writer`), which uses this skill.
