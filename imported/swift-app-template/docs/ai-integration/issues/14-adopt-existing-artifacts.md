# Adopt / reference existing AI artifacts (don't reinvent)

**Labels:** `ai-integration`, `research`, `dependencies`
**Depends on:** #01, #01c
**Informs:** #04, #05, #06, #11

## Summary

A build-vs-adopt-vs-reference register so the template **wires in or links** good
existing artifacts instead of authoring its own. Applies the "earn the custom
code" principle to the whole bundle. Findings from the prior-art survey below.

## ADOPT (wire in directly)

- **`swift-lsp` official plugin** (Anthropic, `claude-plugins-official`,
  Apache-2.0). Connects Claude to Apple's `sourcekit-lsp` for `.swift` diagnostics
  and navigation. Cheap, first-party, language-level. → Reference it from the
  plugin/marketplace work (#11) or document the one-line install.
- **Tuist `llms.txt`** (`https://docs.tuist.dev/llms.txt`, official, live). A
  curated AI context source for Tuist. → The Tuist skill (#06) should point at it
  and cover only project-*authoring* guidance it lacks (the llms.txt + hosted MCP
  are Cloud-analytics-focused, not manifest authoring).

## REFERENCE (link in docs, user opts in)

- **Xcode 27 built-in Agent Skills + `xcrun mcpbridge`** — the framework layer.
  Point at them; never duplicate (see #01c, #13).
- **Official plugins** `code-review`, `security-guidance` (official security-review,
  May 2026), `commit-commands` — overlap our make-target commands; link, don't
  bundle. (`security-guidance` also complements `swift-reviewer` #08 and pairs with
  Apple's `audit-xcode-security-settings`.)
- **MCP servers** XcodeBuildMCP, ios-simulator-mcp (MIT, active) — see #13.
- **`twostraws/Swift-Agent-Skills`** (MIT, Paul Hudson) — a curated **index of
  ~31 individually-authored skills**, not a bundle. It *links* to each skill's own
  repo; each has its own author and license. The list's policy requires
  permissive licenses (MIT/Apache-2/BSD/ISC/Unlicense — no GPL/LGPL), so listed
  skills are generally vendor-compatible **if you verify the individual repo**. The
  list carries an explicit "listing is not an endorsement — read it and trust the
  author before installing" safety note, so treat as **reference + per-skill
  evaluation**, not a blanket adopt.

  Skills in the index that touch our areas (evaluate individually):
  - **Overlap Apple's built-ins (prefer Apple, #01c):** SwiftUI Pro / UI Patterns /
    Design Principles, Swift Testing Pro / Expert (×3), App Intents, Accessibility
    (×3). Apple's `swiftui-specialist` / `test-modernizer` supersede most of these.
  - **Complement our house skills (#04/#05/#08):** Swift Concurrency Expert (×3) —
    relevant to our Swift 6.2 strict-concurrency reviewer; Swift Architecture;
    Swift Security Expert + iOS Code Audit — reference for `swift-reviewer` (#08).
  - **Distribution-adjacent (#03):** App Store Connect CLI (Rudrank Riyam), App
    Store Changelog / ASO / Review — complement, **not** a replacement for Fastlane
    (Match/lanes), which remains a gap.
  - **Overlap #13:** iOS Simulator Skill (Conor Luddy) — alternative to the
    simulator MCP.

  → Recommend: **link the index** as the discovery hub; do not auto-vendor. If we
  later vendor any single skill, verify its repo's license and pin a commit.

## BUILD our own (nothing adoptable exists — confirms the plan)

The survey (incl. the twostraws index) found **no** quality reusable artifact for
these, so the template's own skills/commands are justified:

- **Tuist *authoring*** skill (#06) — llms.txt covers reference, not house manifest
  patterns. (Not in the twostraws index.)
- **Fastlane** (#03 commands) — no official skill/MCP/llms.txt; community MCPs are
  pre-1.0 single-author. twostraws has App-Store-Connect-CLI/ASO/Changelog skills
  but **nothing for Fastlane Match/lanes** — our gap holds.
- **SwiftLint / swift-format** (#10 hook) — no official ruleset/llms.txt. (The
  twostraws "Swift FormatStyle" skill is the Foundation `FormatStyle` API, **not**
  swift-format — don't conflate.)
- **SwiftPM workflow** and **mise usage** — no official skill; not in the index;
  `mise` llms.txt PR was closed unmerged (recheck later).

## License caution (do NOT vendor)

- `dpearson2699/swift-ios-skills` (84 skills) — **PolyForm Perimeter 1.0.0**,
  source-available but **not** redistributable inside an open template. Reference
  only.
- `superagents-lab/xcode27-skills` — **no license**; don't reuse.
- General rule: only **vendor** MIT/Apache artifacts; everything else is a link.

## Acceptance criteria

- [ ] `swift-lsp` and Tuist `llms.txt` are wired in (or documented as one-step
      installs); #06 references the llms.txt.
- [ ] A "Related AI tooling" docs section links the REFERENCE-tier items with their
      licenses (#12).
- [ ] No source-available/unlicensed community skill is vendored into the template.
- [ ] The BUILD list is reconciled against #03/#06/#10 so we're not duplicating an
      artifact that exists.

## References (verify live; metadata is point-in-time)

- [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) ·
  [swift-lsp](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/swift-lsp)
- [Tuist llms.txt](https://docs.tuist.dev/llms.txt) ·
  [Tuist MCP](https://tuist.dev/en/docs/guides/features/agentic-coding/mcp)
- [twostraws/Swift-Agent-Skills](https://github.com/twostraws/Swift-Agent-Skills) ·
  [dpearson2699/swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) (PolyForm)
