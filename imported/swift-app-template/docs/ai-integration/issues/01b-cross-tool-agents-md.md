# Foundation: cross-tool core — `AGENTS.md` shared layer

**Labels:** `ai-integration`, `foundation`, `tooling-agnostic`
**Depends on:** #01
**Informs:** #04–#12

## Problem

Not every developer who uses a generated app uses Claude Code — many use Codex,
Cursor, Aider, or others. Everything else in this epic (`.claude/` skills,
subagents, hooks, slash commands) is **Claude-only** and invisible to those tools.

But the *conventions* themselves are tool-agnostic: Swift Testing rules, the
two-package architecture, "never edit `.xcodeproj` — regenerate with Tuist", the
`make` command vocabulary. Today that knowledge lives only in `CLAUDE.md` /
`CLAUDE.template.md`, which only Claude reads. We're one tool away from every other
assistant flying blind.

## Proposed architecture

A layered model with a single source of truth:

```
AGENTS.md ............... canonical, declarative knowledge — read by EVERY tool
  └─ CLAUDE.md ......... thin pointer/import of AGENTS.md (Claude reads both)
  └─ .claude/ .......... Claude Code executable layer (skills/agents/hooks/commands)
  └─ .cursor/rules/ .... optional Cursor parity (Cursor also reads AGENTS.md)
```

### 1. Make `AGENTS.md` the canonical core

- Move the **tool-agnostic** content out of `CLAUDE.template.md` into a new
  `AGENTS.template.md` (→ `AGENTS.md` downstream via the #01 staging mechanism):
  architecture, commands, Swift Testing conventions, SwiftUI patterns, Tuist rules,
  CI overview.
- `AGENTS.md` is the **single source of truth**. Skills (#04–#06) and other tools'
  configs reference it; they do not duplicate it.

### 2. `CLAUDE.md` becomes a thin pointer

- Reduce `CLAUDE.template.md` to Claude-specific notes plus an import of the shared
  core. Claude Code supports `@path` imports:

  ```markdown
  # CLAUDE.md
  See @AGENTS.md for project conventions, commands, and architecture.

  ## Claude Code specifics
  This project ships skills, subagents, and slash commands under `.claude/`.
  Prefer them over re-deriving conventions. (See README "AI-assisted development".)
  ```

- This eliminates the drift risk where `CLAUDE.md` and a skill state the same rule
  differently.

### 3. Apply the same dual-audience staging (#01)

- Developer's `AGENTS.md` (template-repo meta) vs end-user `AGENTS.template.md`
  promoted by `setup.sh`. Same `*.template` promotion and token replacement.

### 4. Optional per-tool executable parity

The floor (`AGENTS.md`) works everywhere. Tool-specific *executable* features are
optional add-ons, decided per the scope checkbox below:

- **Cursor** — reads `AGENTS.md` natively; optional `.cursor/rules/*.mdc` and Cursor
  commands could mirror a subset of the `.claude/` skills. (The vendored
  `SyntaxKit/.cursor/rules/` is an existing precedent for the format.)
- **Codex** — reads `AGENTS.md`; primarily declarative, fewer executable primitives.
- **Claude Code** — the full `.claude/` layer (#02–#11).

## Scope decision — DECIDED: L0 (AGENTS.md + portable SKILL.md)

- [x] **L0 — `AGENTS.md` + portable `SKILL.md` only.** Ship the shared `AGENTS.md`
      core plus skills authored as portable `SKILL.md` folders (#01c). This already
      covers Claude Code, Xcode 27, Codex, and Cursor via shared formats — single
      source of truth, no per-tool maintenance. **This is the chosen default.**
- [ ] *(deferred)* **L1 — Cursor `.cursor/rules/`** — only if real Cursor usage
      warrants it; if added, make it a thin pointer to `AGENTS.md`, not a restatement
      (precedent: `SyntaxKit/.cursor/rules/`). Optional follow-up, not in scope now.
- [ ] *(deferred)* **L2 — Codex/other tool-specific config** — marginal; Codex is
      `AGENTS.md`-driven. Not planned.

## Acceptance criteria

- [ ] `AGENTS.template.md` exists and holds the tool-agnostic conventions; it is
      promoted to `AGENTS.md` and token-replaced by `setup.sh` (via #01).
- [ ] `CLAUDE.template.md` is reduced to Claude-specifics + an `@AGENTS.md` import;
      no convention is stated in two places.
- [ ] A non-Claude assistant opening a generated repo finds the conventions in
      `AGENTS.md`.
- [x] Per-tool parity scope decided: **L0** (AGENTS.md + portable SKILL.md);
      Cursor/Codex parity deferred as optional follow-ups.

## References

- [AGENTS.md standard](https://agents.md) (Codex, Cursor, Aider, and others).
- `CLAUDE.template.md` (current home of the tool-agnostic conventions).
- [Claude memory / imports](https://code.claude.com/docs/en/memory.md).
- Existing precedent: `SyntaxKit/.cursor/rules/`, `SyntaxKit/.claude/`.
