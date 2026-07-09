# Skill — Tuist project editing

**Labels:** `ai-integration`, `skill`, `tuist`
**Depends on:** #01, #01b
**Related:** #14

> **Source of truth:** the "never edit `.xcodeproj`, regenerate with Tuist" rule
> lives in `AGENTS.md` (#01b). This skill is the on-demand **procedure** (edit
> `Project.swift` → `/generate`).
>
> **Adopt prior art (#14):** Tuist ships an official `llms.txt`
> (`https://docs.tuist.dev/llms.txt`) — reference it for the API surface. This
> skill's unique value is **house manifest-authoring patterns** the llms.txt and
> the Cloud-analytics MCP don't cover; don't restate the reference.

## Summary

A model-invoked skill teaching Claude to make project structure changes the Tuist
way: edit `Project.swift` (and `Tuist/ProjectDescriptionHelpers/`), never the
generated `.xcodeproj`, then regenerate.

## Motivation

The single most common way AI breaks a Tuist project is editing the generated
`.xcodeproj` (uncommitted, overwritten on next generate) or hand-adding files
Xcode-style. `CLAUDE.template.md` states the rule ("Never edit `.xcodeproj`
directly; regenerate after changes"), but a skill turns it into an actionable
procedure scoped to project-structure work — adding a target, a local package, a
dependency, or changing destinations/deployment targets.

This complements hook #10 (which *blocks* `.xcodeproj` edits defensively); the
skill tells Claude what to do *instead*.

## Proposed file

`.claude/skills/tuist-project/SKILL.md`:

```markdown
---
description: >
  How to change project structure with Tuist. Use when adding a target, package, or
  dependency, or changing platforms/deployment targets. Never edit .xcodeproj.
---

# Editing the project with Tuist

The Xcode project is generated from `Project.swift` and is NOT committed.
Never edit `*.xcodeproj` directly — changes are lost on regenerate.

## Where things live
- `Project.swift` — targets, dependencies, destinations, deployment targets,
  settings (e.g. `SWIFT_STRICT_CONCURRENCY = complete`).
- `Tuist/ProjectDescriptionHelpers/` — shared helpers used by `Project.swift`.
- Local packages — `Packages/*`; wire them via `.local(path:)` in `Project.swift`.

## Procedure
1. Edit `Project.swift` (and/or a helper) to make the change.
2. Add remote deps as Swift packages; local deps via `.local(path:)`.
3. Regenerate with `/generate` (`make generate`), or `/generate` strict to match CI.
4. Build/test to confirm. If signing/build fails, see the ci-triage agent.

## Gotchas
- Destinations/deployment targets are app-specific
  ({{TEMPLATE_DESTINATIONS}}, {{TEMPLATE_DEPLOYMENT_TARGET}}) — change them in
  `Project.swift`, not Xcode.
- After any `Project.swift` change, regenerate before building.
```

## Acceptance criteria

- [ ] Skill auto-loads for project-structure requests (add target/dep/package).
- [ ] Claude edits `Project.swift` and runs `/generate` rather than touching
      `.xcodeproj`.
- [ ] No `{{TEMPLATE_*}}` tokens remain after `setup.sh`.

## References

- `Project.swift`, `Tuist/ProjectDescriptionHelpers/`.
- `CLAUDE.template.md` → "Key architectural decisions", "Commands".
- Pairs with hook #10 (`.xcodeproj` edit guard) and command #02 (`/generate`).
