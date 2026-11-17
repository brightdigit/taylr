# Docs + `AGENTS.md` / `CLAUDE.md` integration

**Labels:** `ai-integration`, `documentation`
**Depends on:** #02–#11

## Summary

Document the shipped AI config for downstream users (any tool) and finish the
single-source-of-truth wiring: conventions in `AGENTS.md`, `CLAUDE.md` as a thin
pointer, skills/agents/commands referencing `AGENTS.md` rather than duplicating it.

## Motivation

Once #01b–#11 land, a generated repo has an `AGENTS.md` core plus Claude skills,
subagents, commands, and hooks the developer can't use unless we tell them — and we
must make sure no convention is stated in two places (`AGENTS.md` vs a skill vs
`CLAUDE.md`).

## Work

### 1. Finalize `AGENTS.md` as canonical; `CLAUDE.md` as pointer

- Confirm the tool-agnostic conventions live **only** in `AGENTS.md` (per #01b);
  `CLAUDE.template.md` is reduced to Claude-specifics + an `@AGENTS.md` import.
- Add an "AI-assisted development" section (in `AGENTS.md`, so every tool sees it)
  listing the shipped commands, skills, and subagents and when to use each.

### 2. Generated `README.md` (`README.template.md`)

- Add an "AI-assisted development" subsection: the `/generate`, `/lint`, `/test`,
  `/beta`, `/certs` commands; the `swift-test-writer` / `swift-reviewer` /
  `ci-triage` subagents; and that `@claude` works in issues/PRs via the bundled
  workflows.

### 3. Clarify reviewer coexistence

- Document how the template-specific `swift-reviewer` subagent (#08) relates to the
  generic `code-review` plugin already wired in `claude-code-review.yml`: generic
  plugin runs automatically on every PR; `swift-reviewer` is invoked on demand for
  convention-specific checks. State explicitly so they don't appear redundant.

### 4. Plugin update story (if #11 ships)

- Document install/update: `/plugin install swift-app-claude@brightdigit`, how to
  pin/update versions, and the vendored-vs-plugin tradeoff.

### 4b. Xcode 27 + ecosystem (from #01c, #13, #14)

- Note the platform reality: Xcode 27 agentic features need **Apple Silicon +
  macOS 26.4+**; inline completion is **on-device by default**, cloud/agentic work
  is **opt-in**.
- Document exporting Apple's built-in skills to the shared `~/.agents/skills`
  discovery dir (`xcrun agent skills export ~/.agents/skills`, re-run after Xcode
  updates) so Claude Code / Codex / Cursor all pick them up, and wiring
  `xcrun mcpbridge` (#13). Note the project's own `.claude/skills` complement them.
- Add a "Related AI tooling" section linking the REFERENCE-tier artifacts with
  licenses: Xcode 27 built-ins, `swift-lsp`, Tuist `llms.txt`, XcodeBuildMCP,
  `twostraws/Swift-Agent-Skills` (#14).

### 5. Meta-doc updates (template repo itself)

- Update template-repo `CLAUDE.md`/`AGENTS.md` and `README.md` to note the
  dual-audience staging and that `AGENTS.md` + `.claude/` now ship downstream
  (the behavior change from #01/#01b).
- Update `setup.sh`'s "Cleanup" comments and the success-summary "Next steps" to
  mention the AI tooling now present in the generated repo.

### 6. Content-series hook (optional)

- Flag to `docs/automation-guide/` maintainers that this work is the concrete
  artifact for the open "AI-Powered CI with Claude Code" article/workshop topic.
  (Per that directory's `CLAUDE.md`, Claude does not author that content — just
  surface the tie-in for Leo.)

## Acceptance criteria

- [ ] Conventions appear **once**, in `AGENTS.md`; `CLAUDE.md` imports it and no
      skill/command restates them.
- [ ] Generated `README.md` has an "AI-assisted development" section listing the
      shipped commands/skills/subagents and noting `AGENTS.md` works in any tool.
- [ ] Reviewer coexistence (generic plugin vs `swift-reviewer`) is documented.
- [ ] Template-repo meta docs reflect dual-audience staging and that
      `AGENTS.md` + `.claude/` now ship downstream.

## References

- `CLAUDE.template.md`, `README.template.md`, `Scripts/setup.sh` (cleanup + summary).
- `docs/automation-guide/README.md` (content-series backlog).
- [Memory/precedence docs](https://code.claude.com/docs/en/memory.md)
