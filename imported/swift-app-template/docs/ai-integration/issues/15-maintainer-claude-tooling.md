# Maintainer tooling — template-developer `.claude/` (does NOT ship)

**Labels:** `ai-integration`, `maintainer`, `setup-script`, `dx`
**Depends on:** #01
**Audience:** template maintainers only (never reaches generated apps)

## Summary

Put useful tooling into the **template developer's** `.claude/` — the side that
`setup.sh` deletes (#01), active only when Claude Code is opened in *this* repo to
maintain the template. Two tools: a `/test-setup` command that verifies `setup.sh`
still produces a valid project, and a placeholder-integrity checker.

> **This is the other half of #01's split.** `.claude/` = maintainer tooling
> (removed at generation, never shipped). `.claude.template/` = end-user tooling
> (#02–#10). This issue fills in the former; everything here is invisible to users.

## Motivation

The template's number-one failure mode is `setup.sh` silently breaking — a renamed token, a
new file the token-walk misses, a cleanup step that deletes the wrong thing. The
Contributing guide already says to "test with `./Scripts/setup.sh` in a temporary
directory," but that's manual and easy to skip. Encoding it as a command makes the
check one step, and a placeholder checker catches the most common breakage class
before it ships.

These **complement** `validate-template.yml` (CI), they don't replace it: local,
interactive, pre-push, and able to propose fixes.

## Component 1 — `/test-setup` command

`.claude/commands/test-setup.md` (maintainer side):

```markdown
---
description: Verify setup.sh still produces a valid project. Runs it in a temp dir and checks the result.
---
Smoke-test the template generation end to end:

1. Copy the repo (excluding .git) to a fresh temp dir.
2. Run `Scripts/setup.sh` there with sample args (mirror the README "Automated
   Setup" example: --app-name WeatherBar --team-id ABC1234567 ... ).
   Test both client-only and `--server` modes.
3. Assert on the generated dir:
   - `grep -r '{{TEMPLATE_' .` returns nothing (no un-replaced tokens).
   - Packages renamed (`Packages/WeatherBarKit`, `WeatherBarApp`).
   - `.claude.template/` was promoted to `.claude/`; `_reference/`, `docs/`,
     `TemplateGenerator`, `SyntaxKit` removed.
   - `CLAUDE.md`/`README.md` exist (templates promoted).
   - Optionally `swift build` / `tuist generate` succeeds.
4. Report pass/fail per check; on failure, point at the setup.sh step responsible.
   Do not modify the real repo. $ARGUMENTS
```

> Per repo convention ("prefer less custom code"), the assertions could instead live
> in a small `Scripts/test-setup.sh` that this command just runs — decide during
> implementation. The value is the encoded checklist, wherever it lives.

## Component 2 — placeholder-integrity checker

`.claude/skills/placeholder-integrity/SKILL.md` (maintainer side):

```markdown
---
description: >
  Check the {{TEMPLATE_*}} token contract before pushing. Use when editing the
  template, setup.sh, or the token table.
---
Validate the template's placeholder contract:

- Every token in `CLAUDE.md`'s placeholder table is actually used somewhere.
- Every `{{TEMPLATE_*}}` used in the repo is listed in the table (no orphans).
- `setup.sh` has a replacement rule for each token it should replace.
- No template tokens leak into meta docs (`CLAUDE.md`, `README.md`) — only
  `*.template.md` and `.claude.template/` carry tokens.

Report mismatches with file:line; propose the missing table row or setup.sh rule.
```

## Optional stretch — reference-extraction subagent

If wanted later: a `reference-extractor` subagent encoding the "manually copy from
`_reference/{MonthBar,Bitness,AtLeast}`, then tokenize values into `{{TEMPLATE_*}}`"
workflow — read-only on `_reference/`, never modifies those copies. Kept as a
follow-up, not required for this issue.

## Acceptance criteria

- [ ] `/test-setup` runs `setup.sh` in a temp dir (client + server modes) and
      reports per-check pass/fail without touching the real repo.
- [ ] Placeholder-integrity check flags an orphan token and a missing table row.
- [ ] Both live in the maintainer `.claude/` and are removed by `setup.sh` — confirm
      they never appear in a generated app.
- [ ] Documented as complementary to `validate-template.yml`, not a duplicate.

## References

- `Scripts/setup.sh`, `.github/workflows/validate-template.yml`, `CLAUDE.md` token table.
- README "Automated Setup" example (sample flags for the smoke test).
- Memory: `_reference/` is updated by manual copy from upstream; don't modify those repos.
