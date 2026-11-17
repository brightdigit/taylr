# Epic: Ship AI-assistant config in generated apps

**Labels:** `epic`, `ai-integration`, `enhancement`

## Goal

Make every app generated from this template arrive with working, app-specific
AI-assistant configuration: a **tool-agnostic `AGENTS.md` core** that any
assistant (Codex, Cursor, Aider, Claude Code) can read, plus a **Claude Code
executable layer** (`.claude/` skills, subagents, slash commands, hooks) for
Claude users. The result: locally and in CI via `@claude`, the assistant already
knows how to generate the Xcode project, run the test/lint loop, write tests that
match our conventions, review against our concurrency rules, ship to TestFlight,
and triage CI failures — and a non-Claude user still gets the conventions.

Today the template ships only the two GitHub workflows
(`.github/workflows/claude.yml`, `claude-code-review.yml`). Those survive
`setup.sh` and reach downstream apps, but there is **no shared `AGENTS.md` and no
committed skills, subagents, slash commands, or hooks** — so `@claude` runs with
nothing but `CLAUDE.md`, and non-Claude tools get nothing. This epic closes both
gaps.

## Two framing concerns

1. **Dual audience.** The template needs AI config for *you* (maintaining the
   template) and for the *generated app's developer* — at the same paths. They
   must not collide. Solved by generalizing the existing `*.template` promotion
   (`CLAUDE.template.md` → `CLAUDE.md`) to directories (#01).
2. **Tool-agnostic.** Not everyone uses Claude Code. Conventions live in
   `AGENTS.md` (the cross-tool standard); skills are authored as portable
   `SKILL.md` folders that **Xcode 27 also reads** (#01b, #01c); `.claude/` adds
   Claude-only extras (subagents, hooks, slash commands).
3. **Don't reinvent.** Xcode 27 ships seven built-in Agent Skills and an MCP
   bridge; official artifacts cover SourceKit-LSP and Tuist reference. We ship only
   house conventions + the tooling gaps Apple ignores, and reference the rest
   (#01c, #13, #14).

## Why this matters

- **Consistency at scale.** The same conventions documented in `CLAUDE.template.md`
  (Swift Testing suite structure, strict concurrency, "never edit `.xcodeproj`",
  Tuist regeneration) become *executable* — Claude follows them instead of
  re-deriving them per session.
- **Onboarding.** A developer who generates an app gets discoverable `/generate`,
  `/lint`, `/test`, `/beta` commands and specialized agents on day one.
- **Content series tie-in.** "AI-Powered CI with Claude Code" is an open article
  / workshop topic (see `docs/automation-guide/README.md`). A shippable plugin is
  the concrete artifact that story needs.

## Scope

In scope (one issue each):

- **Foundation** — dual-audience config + `setup.sh` staging (#01, **blocker**)
- **Foundation** — cross-tool `AGENTS.md` core (#01b)
- **Foundation** — Agent Skills (`SKILL.md`) format + Xcode 27 alignment (#01c)
- **Slash commands** — core dev loop (#02), distribution (#03)
- **Skills** — Swift Testing conventions (#04), SwiftUI/Kit scaffolding (#05),
  Tuist editing (#06)
- **Subagents** — `swift-test-writer` (#07), `swift-reviewer` (#08), `ci-triage` (#09)
- **Hooks** — format-on-edit, generated-file guard, session check (#10)
- **Packaging** — distributable plugin + marketplace (#11)
- **Docs** — `AGENTS.md` + README integration (#12)
- **MCP** — live Xcode state via `xcrun mcpbridge` + community servers (#13)
- **Prior art** — adopt/reference existing artifacts; don't reinvent (#14)
- **Maintainer tooling** — template-developer `.claude/` (#15, *does not ship*)

Out of scope (note for later): output styles, organization-managed settings,
personal (`~/.claude/`) primitives, Agent Client Protocol specifics.

## Cross-cutting design constraints

1. **Dual-audience split.** `setup.sh` currently deletes `.claude/` wholesale
   (`Scripts/setup.sh:480`). #01 separates the developer's config from the end
   user's by staging the end-user tree under `*.template` paths and promoting it
   (mirroring `mv CLAUDE.template.md CLAUDE.md`), instead of just not-deleting.
2. **Single source of truth.** Tool-agnostic conventions live in `AGENTS.md`
   (#01b). Skills/commands/other-tool configs *reference* it; they must not
   restate conventions and risk drift.
3. **Placeholder replacement.** Shipped config references the app name and package
   paths (`Packages/{{TEMPLATE_APP_NAME}}Kit`), so it runs through the same
   `{{TEMPLATE_*}}` token replacement and must NOT trip `validate-template.yml`'s
   placeholder grep after setup.
4. **CI auto-load.** Anything under `.claude/` (skills, agents, `settings.json`
   hooks) is auto-discovered by `anthropics/claude-code-action@v1` — no workflow
   change needed for `@claude` runs. The plugin path (#11) needs
   `plugin_marketplaces`/`plugins` inputs.
5. **Earn the custom code.** Prefer a line in `AGENTS.md` over a thin wrapper.
   Each child issue must justify its primitive against "just put it in `AGENTS.md`."
6. **Graceful degradation.** `mise`, `tuist`, `bundle exec fastlane` may be missing
   on a fresh clone or a CI runner; hooks/commands must fail soft.

## Definition of done

- [ ] Generating an app and running `setup.sh` produces `AGENTS.md` + a `.claude/`
      with app-specific skills, agents, commands, and `settings.json` — no
      `{{TEMPLATE_*}}` tokens left, `validate-template.yml` still green.
- [ ] A non-Claude assistant (Codex/Cursor/Xcode 27) opening a generated repo finds
      the conventions in `AGENTS.md` and reads the shipped `SKILL.md` skills.
- [ ] No shipped skill duplicates an Xcode 27 built-in; #14's ADOPT/REFERENCE/BUILD
      register is reconciled against what we author.
- [ ] `/generate`, `/lint`, `/test` work in a fresh generated repo.
- [ ] `@claude` on a PR in a generated repo can invoke the shipped subagents.
- [ ] The whole bundle is also installable as a versioned plugin (#11).
- [ ] `AGENTS.md` + generated `README.md` document what shipped (#12).

## Decisions to confirm

- [ ] **Staging naming (#01):** `.claude.template/` (consistent with
      `CLAUDE.template.md`) vs a visible `claude-template/`.
- [ ] **Source of truth (#01b):** confirm `AGENTS.md` is canonical and
      `CLAUDE.md` becomes a thin `@AGENTS.md` import.
- [x] **Multi-tool depth (#01b):** DECIDED — **L0** (`AGENTS.md` + portable
      `SKILL.md`). Cursor/Codex parity deferred as optional follow-ups.
- [ ] **Opt-in vs default:** ship all by default, or gate behind a
      `setup.sh --with-ai` flag (default on)?
- [ ] **Plugin distribution (#11):** vendored in-repo marketplace vs a separate
      `brightdigit/swift-claude-plugins` repo referenced by `plugin_marketplaces`.
