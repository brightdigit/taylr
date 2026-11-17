# Slash commands — core dev loop (`/generate`, `/lint`, `/test`)

**Labels:** `ai-integration`, `slash-command`, `enhancement`
**Depends on:** #01

## Summary

Ship three user-invoked slash commands that front the daily inner-loop `make`
targets, so a developer (or `@claude`) can drive the Tuist/lint/test workflow by
name and Claude knows the exact, project-correct invocation.

## Motivation & the "earn the custom code" test

We deliberately avoid thin wrappers. These three earn their place because:

- **Discoverability.** A new contributor types `/` and sees the project's real
  workflow instead of guessing flags.
- **Encoded correctness.** Each command carries the *gotchas* Claude otherwise
  re-derives: regenerate after `Project.swift` changes; strict vs auto-fix lint
  mode; test the **Kit** package specifically (`Packages/{{TEMPLATE_APP_NAME}}Kit`),
  not the whole workspace.
- **CI parity.** Committed under `.claude/commands/`, they're auto-available to
  `claude-code-action`, so `@claude run /test` behaves identically in CI.

Commands that would be *pure* aliases with no added guidance should instead be a
line in `CLAUDE.md`. These three carry guidance, so they ship as commands.

## Proposed files

`.claude/commands/generate.md`:

```markdown
---
description: Regenerate the Xcode project with Tuist (run after any Project.swift or package change).
---
Regenerate the Xcode project.

- Default (auto-fix lint): `make generate`
- Strict mode (matches CI): `make generate-strict`
- Skip lint: `make generate-no-lint`

Never edit `*.xcodeproj` directly — it is Tuist-generated and not committed.
After editing `Project.swift`, a local Swift package, or a dependency, run this.
$ARGUMENTS
```

`.claude/commands/lint.md`:

```markdown
---
description: Run SwiftLint + swift-format. Auto-fix locally; strict in CI.
---
Run linting via `make lint` (wraps `Scripts/lint.sh`).

- Local auto-fix: `make lint`
- CI-equivalent strict: `CI=true LINT_MODE=STRICT ./Scripts/lint.sh`

Report any violations the auto-fixer could not resolve. $ARGUMENTS
```

`.claude/commands/test.md`:

```markdown
---
description: Run the Swift Testing suite for the Kit package (the primary test target).
---
Run tests for the Kit package:

`swift test --package-path Packages/{{TEMPLATE_APP_NAME}}Kit`

Tests use Swift Testing only (no XCTest). For a single suite, append
`--filter <SuiteName>`. If a test fails, report the failing `#expect`/`#require`
and the file:line. $ARGUMENTS
```

> Note: equivalent files may instead live as `.claude/skills/<name>/SKILL.md` for
> richer structure; the flat `commands/` form is simplest and is what the GitHub
> Action loads today. Pick one form repo-wide (see #11 for plugin packaging).

## Acceptance criteria

- [ ] `/generate`, `/lint`, `/test` resolve in a fresh generated repo.
- [ ] After `setup.sh`, `/test` references the real Kit package path (no token).
- [ ] Each command documents its gotcha (regenerate-after-change, strict-vs-fix,
      Kit-only) — not a bare alias.
- [ ] Works in an `@claude` CI run (`@claude run /lint`).

## References

- Make targets: `Makefile` (`generate`, `generate-strict`, `generate-no-lint`,
  `lint`, `test`).
- Conventions: `CLAUDE.template.md` (Swift Testing, "never edit `.xcodeproj`").
- [Slash commands / skills docs](https://code.claude.com/docs/en/skills.md)
