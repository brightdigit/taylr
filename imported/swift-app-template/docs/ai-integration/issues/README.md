# AI Integration — Issue Drafts

Draft GitHub issues for shipping **AI-assistant configuration** in the Swift App
Template so that **every app generated from the template** inherits AI-assisted
workflows out of the box — with a **tool-agnostic core** (`AGENTS.md`) that works
in any assistant and a **Claude Code executable layer** (`.claude/` skills,
subagents, slash commands, hooks) layered on top.

Each `NN-*.md` file is one issue, paste-ready into GitHub.

## Two cross-cutting concerns these issues are built around

### 1. Dual audience at the same paths (you vs. the template user)

The template repo needs AI config for **two different people at the same paths**:

- **Template developer (you)** — maintaining the template itself. References
  `_reference/`, validates placeholders, tests `setup.sh`. **Must not ship downstream.**
- **End user** — the developer of an app generated from the template. Wants app-dev
  tooling (testing, review, deploy). **Must ship downstream, with `{{TEMPLATE_*}}`
  tokens replaced.**

The repo already solves this for docs: `CLAUDE.md` (yours/meta) stays; a separate
`CLAUDE.template.md` is promoted to `CLAUDE.md` for the generated app
(`setup.sh:460`). **Issue #01 generalizes that `*.template` promotion to
directories** (`.claude/` vs `.claude.template/`, etc.) instead of the current
blanket `rm -rf .claude`.

### 2. Not everyone uses Claude Code (Codex, Cursor, Xcode 27, Aider, …)

The *conventions* (Swift Testing rules, two-package architecture, Tuist
regeneration, commands) are tool-agnostic. Claude-specific `.claude/` primitives
only help Claude users. **Issue #01b** makes `AGENTS.md` the shared, canonical
knowledge core that every assistant reads; **#01c** makes the `SKILL.md` Agent
Skills folder the **portable executable unit** — the same format **Xcode 27** now
reads natively, plus Codex/Cursor.

```
AGENTS.md ............... declarative floor — every tool reads it
  └─ skills/<name>/SKILL.md ... portable skills — Claude Code AND Xcode 27 read these
  └─ .claude/ ........... Claude-only extras (subagents, hooks, slash commands)
  └─ .cursor/rules/ ..... optional Cursor parity
```

### 3. Apple now owns the framework layer — don't reinvent it (#01c, #14)

Xcode 27 ships **seven built-in Agent Skills** (SwiftUI, UIKit, XCTest→Swift
Testing migration, security audit, device interaction, …) and an official MCP
bridge (`xcrun mcpbridge`). Our skills cover only **house conventions** and the
**tooling gaps Apple ignores** (Tuist authoring, Fastlane, lint). The prior-art
survey (#14) sorts everything into ADOPT / REFERENCE / BUILD so we don't duplicate
existing artifacts or vendor incompatibly-licensed ones.

## Reading order

| # | Issue | Type | Depends on |
|---|---|---|---|
| 00 | [Epic — Ship AI-assistant config in generated apps](00-epic-claude-primitives.md) | epic | — |
| 01 | [Dual-audience config + `setup.sh` staging](01-claude-dir-scaffold-setup.md) | foundation | — (**blocker**) |
| 01b | [Cross-tool core — `AGENTS.md` shared layer](01b-cross-tool-agents-md.md) | foundation | 01 |
| 01c | [Agent Skills (`SKILL.md`) format + Xcode 27 alignment](01c-agent-skills-format-xcode27.md) | foundation | 01, 01b |
| 02 | [Slash commands — core dev loop (`/generate`, `/lint`, `/test`)](02-slash-commands-core-loop.md) | command | 01 |
| 03 | [Slash commands — distribution (`/beta`, `/certs`)](03-slash-commands-distribution.md) | command | 01 |
| 04 | [Skill — Swift Testing house conventions](04-skill-swift-testing-conventions.md) | skill | 01, 01b, 01c |
| 05 | [Skill — two-package feature scaffolding](05-skill-swiftui-kit-scaffolding.md) | skill | 01, 01b, 01c |
| 06 | [Skill — Tuist project editing](06-skill-tuist-project-editing.md) | skill | 01, 01b |
| 07 | [Subagent — `swift-test-writer`](07-subagent-swift-test-writer.md) | subagent | 01, 04 |
| 08 | [Subagent — `swift-reviewer`](08-subagent-swift-reviewer.md) | subagent | 01 |
| 09 | [Subagent — `ci-triage`](09-subagent-ci-triage.md) | subagent | 01 |
| 10 | [Hooks — format-on-edit, generated-file guard, session check](10-hooks-format-guard-session.md) | hooks | 01 |
| 11 | [Package as a plugin + marketplace](11-plugin-packaging-marketplace.md) | plugin | 02–10 |
| 12 | [Docs + `AGENTS.md`/`CLAUDE.md` integration](12-docs-and-claude-template-integration.md) | docs | 02–11 |
| 13 | [MCP integration — live Xcode state (`xcrun mcpbridge`)](13-mcp-xcode-integration.md) | mcp | 01 |
| 14 | [Adopt/reference existing artifacts (don't reinvent)](14-adopt-existing-artifacts.md) | research | 01, 01c |
| 15 | [Maintainer tooling — template-developer `.claude/`](15-maintainer-claude-tooling.md) | maintainer | 01 |

> **Audience note:** #02–#14 ship to **generated apps**. **#15 is the exception** —
> it tools the **template developer's** side (`.claude/`, removed by `setup.sh`),
> not the end user.

## Design principles (apply to every issue)

- **Tool-agnostic core, tool-specific enhancement.** Declarative knowledge lives in
  `AGENTS.md` (single source of truth, every tool). `.claude/` (and any
  `.cursor/`) are thin executable adapters that *reference* it — never re-state it.
- **Dual-audience clean split.** Template-developer config and end-user config never
  collide: end-user config is staged under `*.template` paths and promoted by
  `setup.sh`; developer config is removed at generation time.
- **Downstream-first.** End-user assets survive `setup.sh` with `{{TEMPLATE_*}}`
  tokens replaced and `validate-template.yml` still green.
- **Earn the custom code.** Prefer a line in `AGENTS.md` over a thin wrapper
  command/skill. A primitive must add real value (discoverability, multi-step
  orchestration, encoded conventions).
- **Don't reinvent; don't duplicate Apple.** Author skills as portable
  `SKILL.md` folders (read by Claude Code *and* Xcode 27). Reference Xcode 27's
  built-in skills and existing official artifacts (#14); ship only house
  conventions + the tooling gaps Apple ignores. Vendor only MIT/Apache artifacts.
- **Graceful degradation.** Hooks/commands reference `mise`/`tuist`/`bundle`, which
  may be absent; fail soft, never block.

## Source research

Official docs:
[skills](https://code.claude.com/docs/en/skills.md) ·
[subagents](https://code.claude.com/docs/en/sub-agents.md) ·
[hooks](https://code.claude.com/docs/en/hooks-guide.md) ·
[plugins](https://code.claude.com/docs/en/plugins.md) ·
[GitHub Actions](https://code.claude.com/docs/en/github-actions.md) ·
[memory / `AGENTS.md`](https://code.claude.com/docs/en/memory.md) ·
[AGENTS.md standard](https://agents.md)
