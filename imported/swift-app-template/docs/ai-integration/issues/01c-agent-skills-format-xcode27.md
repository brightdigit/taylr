# Foundation: Agent Skills (`SKILL.md`) format + Xcode 27 alignment

**Labels:** `ai-integration`, `foundation`, `tooling-agnostic`, `xcode`
**Depends on:** #01, #01b
**Informs:** #04, #05, #06, #11, #12

## Why this changes the plan

Xcode 27 (WWDC 2026) ships an agentic coding assistant that **adopts Anthropic's
Agent Skills (`SKILL.md`) format** and bundles **seven built-in skills**, with MCP
and the Agent Client Protocol as open extension points. Two consequences reshape
this epic:

1. **`SKILL.md` is now the universal, portable skill unit.** The same
   `skills/<name>/SKILL.md` folder is read by Claude Code **and** Xcode 27's
   assistant (and is exportable across Codex/Cursor). It is the concrete artifact
   behind #01b's "tool-agnostic core" — stronger than a prose `AGENTS.md` because
   it's *executable* in multiple tools, not just declarative.
2. **Apple now owns framework-level guidance.** Don't author skills that duplicate
   Apple's built-ins — that invites drift (Apple versions them each cycle, e.g.
   `swiftui-whats-new-27`).

> Verification note: the `SKILL.md`/"Anthropic format" framing and the exact skill
> machine-names are confirmed via exported bundles and Swift-community write-ups,
> not verbatim Apple docs. Confirm `xcrun agent skills --help` and the Xcode 27
> release notes on a real machine before depending on exact flags/names.

## Xcode 27 built-in skills — the "do not duplicate" list

| Built-in skill | Owns |
|---|---|
| `swiftui-specialist` | idiomatic SwiftUI, data flow, deprecations |
| `swiftui-whats-new-27` | newest SwiftUI APIs this cycle |
| `uikit-app-modernization` | scene lifecycle / multi-window |
| `test-modernizer` | XCTest → Swift Testing migration |
| `c-bounds-safety` | C `-fbounds-safety` |
| `audit-xcode-security-settings` | hardening build settings |
| `device-interaction` | on-device/simulator verification (needs Xcode tooling) |

→ Our skills must cover only what Apple's **don't**: this template's *house
conventions* (Swift Testing suite structure/naming — #04), *two-package
architecture/placement* (#05), and the *tooling gaps* Apple ignores (Tuist
authoring, Fastlane, lint — #06/#03/#10).

## Proposed change

### 1. Author shipped skills as portable `SKILL.md` folders

Adopt the canonical layout so one folder serves every tool:

```
.claude.template/skills/<name>/
├── SKILL.md            # YAML frontmatter: name, description; markdown body
├── references/         # optional supporting docs loaded on demand
└── scripts/            # optional helper scripts
```

The `.claude/` location is what Claude Code auto-loads; the *format* is what makes
it portable. Frontmatter stays minimal (`name`, `description`) for cross-tool
compatibility — Claude-only fields (e.g. `disable-model-invocation`) are additive
and ignored by other tools.

### 2. Reference, don't reimplement, Apple's built-ins

- In `AGENTS.md`/docs, point users at Xcode 27's built-in skills for SwiftUI,
  UIKit, test migration, and security.
- Document the **export to the shared discovery directory** so any tool (Claude
  Code, Codex, Cursor) can pick Apple's skills up — they read the `~/.agents/`
  convention:

  ```
  xcrun agent skills export ~/.agents/skills
  # then refresh/relaunch the IDE; re-run after Xcode updates to refresh the export
  ```

  Note: `~/.agents/skills` is a **user/global**, machine-local directory the
  developer populates — distinct from the **project-committed** skills we ship in
  `.claude/skills`. They compose: project house-convention skills + exported Apple
  framework skills.
- **Portability split** (per SwiftLee): `swiftui-specialist`, `swiftui-whats-new-27`,
  and `test-modernizer` are pure-knowledge and work in any tool; whereas
  `audit-xcode-security-settings` and `device-interaction` need Xcode tooling
  (build settings / device control) and run best from inside Xcode or via its MCP
  bridge (#13). (`uikit-app-modernization`, `c-bounds-safety` unclassified — verify.)
- Our `SKILL.md` files explicitly scope themselves to house conventions and say
  "Apple's `swiftui-specialist` / `test-modernizer` own the framework basics."

### 3. State the platform reality in docs

Xcode 27 agentic features require **Apple Silicon + macOS 26.4+**; inline
completion is **on-device by default**, cloud/agentic work is **opt-in**. Note
this in the generated README so the AI workflow's prerequisites are clear (#12).

## Acceptance criteria

- [ ] Shipped skills use the portable `skills/<name>/SKILL.md` folder layout with
      minimal cross-tool frontmatter.
- [ ] No shipped skill duplicates an Xcode 27 built-in; each scopes itself to house
      conventions / tooling gaps and references Apple's where relevant.
- [ ] Docs explain importing Apple's skills (`xcrun agent skills export`) and the
      Apple-Silicon/macOS-26.4 + on-device-default reality.
- [ ] #04 and #05 are revised against the "do not duplicate" list (linked).

## References

- Apple Newsroom (Xcode 27 / intelligence frameworks), Xcode 27 release notes
  (verify), `developer.apple.com/documentation/xcode/extending-and-customizing-agents`.
- [Agent Skills format](https://agents.md) · [Skills docs](https://code.claude.com/docs/en/skills.md)
- SwiftLee: "Using Xcode 27's Agent Skills in Claude, Codex, and Cursor"
  (`https://www.avanderlee.com/ai-development/using-xcode-27s-agent-skills-in-claude-codex-and-cursor/`)
  — source for the `xcrun agent skills export ~/.agents/skills` command and the
  portable-vs-Xcode-dependent split.
