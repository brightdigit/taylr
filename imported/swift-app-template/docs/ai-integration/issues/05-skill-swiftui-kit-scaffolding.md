# Skill — SwiftUI patterns + Kit feature scaffolding

**Labels:** `ai-integration`, `skill`, `architecture`
**Depends on:** #01, #01b, #01c

> **Source of truth:** architecture conventions live in `AGENTS.md` (#01b). This
> skill is the on-demand **scaffolding procedure** (where files go, the regenerate
> step), authored as a portable `SKILL.md` folder (#01c).
>
> **Boundary vs Xcode 27 (#01c):** Apple's `swiftui-specialist` /
> `swiftui-whats-new-27` own **idiomatic SwiftUI**. This skill must NOT duplicate
> generic SwiftUI guidance — its unique value is the **two-package
> architecture/placement** Apple's skills can't know (logic+tests in `*Kit`, views
> in `*App`, the dependency direction, the `@Observable`/`@MainActor` AppModel,
> regenerate via Tuist). Keep only the house-style `private extension` view pattern;
> defer SwiftUI idioms to Apple's skill.

## Summary

A model-invoked skill that captures the template's two-package architecture and
SwiftUI conventions, and walks Claude through adding a feature the *template's*
way: business logic in `*Kit`, view in `*App`, tests in `*Kit`, regenerate.

## Motivation

The template enforces a specific shape (`CLAUDE.template.md`):

- **Two packages.** `*Kit` (pure Swift, cross-platform, holds the tests) and
  `*App` (SwiftUI). Business logic goes in Kit; the app depends on Kit.
- **`@Observable` AppModel** with `@MainActor`, Swift 6.2 `complete` strict
  concurrency.
- **SwiftUI platform logic** goes in a `private extension` of the *view itself*,
  not a global `View` extension; properties → `init` → methods ordering.

Left implicit, AI-generated features tend to dump logic into the view or the App
target. This skill makes the correct placement and the regenerate step explicit,
on demand, without bloating always-on context.

## Proposed file

`.claude/skills/swift-feature/SKILL.md`:

```markdown
---
description: >
  How to add a feature in this two-package app. Use when adding models, logic, or
  views. Business logic + tests go in the Kit package; SwiftUI goes in the App package.
---

# Adding a feature

## Placement
- Models & business logic → `Packages/{{TEMPLATE_APP_NAME}}Kit/Sources/{{TEMPLATE_APP_NAME}}Kit/`
- Tests → `Packages/{{TEMPLATE_APP_NAME}}Kit/Tests/` (use the swift-testing skill)
- SwiftUI views → `Packages/{{TEMPLATE_APP_NAME}}App/Sources/{{TEMPLATE_APP_NAME}}App/Views/`
- The App package depends on Kit — never the reverse.

## Conventions
- State lives in the `@Observable` `@MainActor` AppModel (Kit). Swift 6.2
  `SWIFT_STRICT_CONCURRENCY = complete` — keep types Sendable-correct.
- Platform-specific view logic goes in a `private extension MyView { ... }`
  (the view's own extension), NOT a global `View` extension.
- Property order in a view: stored properties → `init` → methods/`@ViewBuilder`.

## After adding code
- If you added a package, target, or dependency, edit `Project.swift` and run
  `/generate` (see the tuist-project skill). Otherwise just build/test.
- Run `/test` and `/lint`.
```

## Acceptance criteria

- [ ] Skill auto-loads when Claude is asked to "add a feature / model / view."
- [ ] Generated code lands logic in Kit and views in App, following the
      `private extension` SwiftUI pattern.
- [ ] References the real package paths after `setup.sh`.
- [ ] Cross-links the swift-testing (#04) and tuist-project (#06) skills.

## References

- `CLAUDE.template.md` → "Template Architecture", "SwiftUI Patterns".
- Shipped `AppModel.swift`, `Views/` under `Packages/{{TEMPLATE_APP_NAME}}*`.
