# ADR 0001 — Scaffold delivery mechanism & how we "run skills"

- **Status:** Proposed
- **Date:** 2026-07-07
- **Deciders:** Leo Dion (owner)
- **Type:** Architecture / product-direction spike (decision doc, no code)

---

## 1. Context & the question

Swift App Template is today a GitHub **"Use this template"** repository. Its entire
generation surface is one script, `Scripts/setup.sh` (536 lines of bash):

1. collects ~15 config values (app name, Team ID, platform, …),
2. find-replaces ~21 `{{TEMPLATE_*}}` tokens across an explicit file list plus globbed
   `Package.swift` / Tuist / fastlane metadata,
3. renames `Packages/{{TEMPLATE_APP_NAME}}Kit|App|Server` directories,
4. activates CI (`.github/app.workflow.yml → workflows/app.yml`),
5. keeps or removes the Hummingbird + OpenAPI server package,
6. builds and runs `Packages/TemplateGenerator` (a Swift executable, built on the vendored
   `SyntaxKit` SwiftSyntax DSL) to emit the Swift skeletons, then
7. `rm -rf`s `TemplateGenerator`, `SyntaxKit`, `_reference`, `.claude`, and `docs`.

It is a **mutate-in-place-then-self-delete** flow: it cannot be re-run, and it keeps no
record of what it generated.

The owner is questioning whether to keep investing in the template, or pivot to a
distributable Swift CLI "with the ability to run skills." Five doubts were raised, all of
them in play:

- **dual-audience friction** — one repo serves both the maintainer and the generated app,
  requiring `*.template` file promotion, a `validate-template.yml` guard against accidental
  token replacement, and git-history scrubbing of `_reference/`, `.claude/`, `docs/` before
  publishing;
- **distribution / versioning** — a fork from a template cannot receive upstream updates;
- **the "AI-era" narrative** — the story should feel like a tool that runs composable skills;
- **maintenance burden** — 536 lines of bash + tokenized files everywhere are fragile and
  hard to test;
- **ease of install / use**.

The desired CLI role was stated as "all 3" layers: (1) deterministic scaffolding, (2) an
in-app deterministic task-runner, and (3) an LLM agent runtime.

### Priority update that reframes the weights

The Swift Craft **workshop is done.** Current priorities, in order: the **Beer City Code
50-minute talk**, **YouTube video(s)**, **blog posts**, and real-world adoption across the
128+ BrightDigit repos. This supersedes the "the workshop is the primary goal" statement in
`docs/automation-guide/CLAUDE.md`. It removes the case that used to dominate every trade-off
here — the hands-on, follow-along, zero-install, "attendees read every generated file" room.
A talk, a video, and a blog post are **demonstrations**, not live clone-alongs, which
changes what "good" looks like.

---

## 2. The reframe (the key insight)

**"Template vs CLI" and "the ability to run skills" are two orthogonal decisions.**
Conflating them is the trap this ADR exists to avoid.

1. **Running skills is already a solved distribution problem.** The plan is to ship
   skills/subagents/commands/hooks as a **Claude Code plugin distributed via a
   marketplace** — a versioned, installable, updatable unit that already works across every
   repo, *independent of how the scaffold is delivered*. A bespoke Swift skill **runtime**
   (the requested "Layer 3") would largely re-implement what Claude Code and Xcode 27
   (`xcrun agent skills`) already execute natively over the same `SKILL.md` files (real
   examples live in `_reference/Bitness/.claude/skills/` and
   `_reference/AtLeast/.claude/skills/`).

2. **Scaffold delivery is where a CLI has a real, unique edge:** an idempotent, re-runnable
   `init` + `upgrade` backed by a `.swiftapp/manifest.json` that records resolved config and
   per-file `sha256`, so it can detect user edits, apply versioned migrations, and never
   clobber. `setup.sh` is destructive and self-deleting; it **structurally cannot** offer
   this.

3. **With the workshop gone, demo/narrative + adoption now favor the CLI.** For a talk,
   YouTube, and blog posts, `sat init … && sat upgrade` is a tighter, stronger beat than
   "clone this repo and read 536 lines of bash," and it carries the "AI era" story better.
   The template's remaining honest advantages shrink to **GitHub discoverability** (the "Use
   this template" front door) and **transparency / zero-install** for cautious adopters —
   real, but no longer load-bearing now that nobody has to follow along live. The macOS
   Developer ID signing + notarization tax on a shipped binary remains a genuine cost, and is
   a little ironic for a project that teaches code signing.

**Therefore:** decide the two questions separately. Ship skills the way the ecosystem
already ships them (a plugin), and judge the scaffold-delivery mechanism on its own merits —
where a CLI's justification is *upgrade + install UX and demo value*, not "running skills."

---

## 3. Options considered

| # | Option | What it is |
|---|---|---|
| A | **Template-as-is** | Keep `setup.sh` + the delete-after-use `TemplateGenerator`. Status quo. |
| B | **Template + `ScaffoldKit`** | Extract the codegen + token logic into a reusable, tested Swift library; the template still *delivers*, but `setup.sh` shrinks to a thin driver. |
| C | **Thin cloning CLI** | A `brew`-installed CLI (`sat new`) that clones the canonical template and runs setup. Template stays the source of truth. (The `create-*` / `cargo generate` model.) |
| D | **Full CLI** (recommended end-state) | `sat` built on `ScaffoldKit`, generating apps from embedded resources with **no template to clone**, headlined by manifest-backed `init` + `upgrade`. Template retained only as an optional thin discoverability front-door. |
| E | **copier-hybrid** | Keep the template *directory*, replace bash with a `copier.yml`; get `copier update` (3-way-merge upstream updates) off the shelf, no Swift CLI. |

---

## 4. Rubric & scored comparison

Each option scored **1–5** per dimension, then multiplied by the dimension weight. Weights
reflect the post-workshop priorities (demo/narrative first; small maintainer team; skills
delivered by the plugin regardless).

| Dimension | Weight | A | B | C | D | E |
|---|---:|:-:|:-:|:-:|:-:|:-:|
| Demo / narrative fit (talk, video, blog) | 3× | 2 | 2 | 3 | **5** | 3 |
| Adoption / real-world reuse (128+ repos) | 2× | 3 | 3 | 4 | **5** | 4 |
| Install / onboarding friction (higher = less) | 2× | **5** | **5** | 3 | 3 | 3 |
| Upgradeability | 2× | 1 | 2 | 2 | **5** | **5** |
| Maintainability / testability | 2× | 2 | 4 | 4 | 4 | 3 |
| Transparency | 1× | **5** | **5** | **5** | 3 | **5** |
| Discoverability | 2× | **5** | **5** | 4 | 3 | **5** |
| AI / skills integration (score the *plugin*) | 2× | 3 | 3 | 3 | 4 | 3 |
| Effort-to-build (higher = less) | 2× | **5** | 4 | 3 | 2 | 3 |
| **Weighted total (of 90)** | | **59** | **63** | **60** | **70** | **66** |

**Reading the scores:**

- **D (Full CLI) wins at 70/90** — it dominates the two heaviest signals (demo/narrative,
  adoption) and owns upgradeability, at the honest cost of install friction, transparency,
  discoverability, and effort.
- **E (copier-hybrid) is a close second at 66** — deliberately *not* buried. If upgradeability
  were the *only* driver, `copier update` buys it off the shelf with far less code than a
  Swift CLI. It loses to D on demo/narrative (a Python tool over Swift content is a story
  mismatch for a Swift talk) and adoption, not on capability.
- **B (Template + `ScaffoldKit`) at 63** is the highest-scoring option reachable *cheaply and
  now*, and — crucially — it is a **prerequisite for D**, not a competitor to it.
- **A (Template-as-is) at 59** is last: it scores well only on the now-lightly-weighted
  install/transparency/discoverability axes and on effort (it's already built).

The gap between D and E (70 vs 66) is real but not overwhelming, which is the honest result:
the CLI wins primarily because the talk/video/blog is the goal and upgrade is a *demoable*
differentiator — not because it "runs skills" (that's the plugin, where every option scores
about the same).

---

## 5. Prior art (fair-fight evidence)

- **Upgrade is the crux, and off-the-shelf beats bespoke.** `copier`
  (`.copier-answers.yml` + `copier update` 3-way merge) and `cruft` already provide
  re-appliable template updates *without writing a tool*. A hand-rolled Swift CLI would have
  to build 3-way-merge upgrade logic from scratch to match them. This is why E scores so well
  and why D's `upgrade` must be treated as real engineering, not a freebie.
- **Clone-and-diverge is the dominant norm** — `swift package init`, `create-next-app`,
  `cargo generate`, `dotnet new` all scaffold once and let the project diverge. Most
  successful scaffolders do **not** solve upgrade, which validates that upgradeability, while
  a genuine edge, is not table stakes.
- **Nobody ships a compiled, notarized binary *just* to scaffold.** CLI precedents are either
  toolchain-bundled (`rails new`, `dotnet new`, `swift package init`), run via a package
  runner with no install (`npx create-*`), or lightweight interpreted tools
  (cookiecutter / copier in Python). A standalone signed Swift binary is a heavier
  distribution choice than any precedent — the notarization cost in the rubric is not
  hypothetical.
- **Closest "installed tool + templates" analogues:** `dotnet new` (versioned NuGet template
  packages, rich `template.json` with symbols/conditionals/post-actions) and Tuist scaffold
  (Stencil templates + a manifest). Both show the shape D is reaching for.
- **Ongoing tasks (Rails generators) is the one place a CLI clearly wins** — but this repo's
  ongoing tasks (`make lint`, `make beta`, `/generate`, `/test`) are already delivered by the
  `Makefile` + Claude Code slash commands, i.e. by tools already inside the generated repo,
  not by the scaffolder. So Layer 2 is mostly *already solved* and is not a strong
  independent reason to build the CLI.

---

## 6. Recommendation

Lean into the CLI as the primary artifact and demo vehicle — but **factor the problem so
nothing is wasted.** Three phases, the first two low-regret regardless of the final verdict:

### Phase 0 — Keystone: extract `ScaffoldKit` (do this first, no matter what)

Stop deleting `TemplateGenerator`. Refactor it from an `.executableTarget` into a **library**
(`ScaffoldKit`) exposing the existing pure generators (`AppModelGenerator`,
`ContentViewGenerator`, `AppEntryGenerator`, `PrimaryViewGenerator`, `ServerCommandGenerator`,
`ServerEntryGenerator`, `AppModelTestsGenerator`) plus a Swift `TokenSubstitutor` / typed
`ProjectConfig` that ports the ~21-token substitution and derivation rules (`BUNDLE_ID`,
`APP_GROUP_ID`, platform → destinations) out of `setup.sh`. Pin `SyntaxKit` to a version tag
instead of a path dependency. This shrinks the bash, makes generation unit-testable, and is a
**prerequisite for every downstream option** (B, C, and D all consume it). It throws nothing
away — it inverts `TemplateGenerator` from "built then destroyed" to "linked library."

### Phase 1 — Ship the AI/skills layer as a Claude Code plugin + marketplace

Package the skills/subagents/commands/hooks as a **Claude Code plugin** and publish it via a
**marketplace**. This **is** "the ability to run skills," delivered by the mechanism Claude
Code / Xcode 27 / Codex already read. Same `skills/<name>/SKILL.md` artifacts, versioned and
updatable across repos, no custom runtime. This decouples the skills story from the
scaffold-delivery decision entirely and is the right way to demo the "AI era" narrative in the
talk.

> **Open question — where does the skills *source* live?** Shipping as a plugin is settled;
> the source home is not. The `SKILL.md` sources could live **in this repo** (co-located with
> the template/CLI, one place to maintain) or in a **dedicated skills repo** (its own release
> cadence, reused across the 128+ BrightDigit repos without dragging in the scaffold). The repo
> has no `.claude/skills/` yet, so nothing is committed either way. Resolve this before Phase 1
> lands.

### Phase 2 — Make the `sat` CLI the primary artifact, headlined by `init` + `upgrade`

> **`sat` is a provisional name — not yet decided.** It is used throughout this ADR only as a
> stand-in for the CLI; the actual command name is an open choice.

Build the CLI on `ScaffoldKit` (swift-argument-parser). Bootstrap new apps from **embedded
resources** (no template clone), writing final package names directly so the entire
`{{TEMPLATE_APP_NAME}}` directory-rename dance in `setup.sh` disappears. The headline — and the
Beer City Code demo beat — is the manifest-backed **idempotent `upgrade` with drift
detection**: `init` writes `.swiftapp/manifest.json` (`satVersion`, resolved config,
`skillsApplied`, `generatedFiles[].sha256`); `upgrade` diffs on-disk hashes to detect user
edits, runs versioned skill migrations, and never clobbers. A "skill" in this tool is a
`SKILL.md` (frontmatter the LLM/editor reads) plus an inert `x-swift-app:` block (a handler
pointer: `builtin:` for deterministic codegen, `exec:` for scripts, none = agentic) that only
`sat` reads — one artifact, three consumers.

Keep the template repo as an **optional thin discoverability front-door** (a "Use this
template" that points at / wraps the CLI) and a transparent reference — but it is no longer the
anchor.

### On the requested Layer 3 (bespoke LLM agent runtime): **more feasible now — revisit sooner (still off the committed critical path)**

It remains the highest-effort layer and still largely duplicates what Claude Code itself does.
But it is **more feasible than first assumed**: the API layer no longer has to be hand-rolled.
A Swift Anthropic Messages client is already in progress as **`ClaudeKit`** (OpenAPI-generated,
in `brightdigit/SyntaxKit`, developed in tandem with this repo), and we are open to other
libraries — so Layer 3 would build on an existing client rather than a raw
Messages-API-over-`URLSession` loop. That materially lowers the build cost.

Even so, the "AI era" talk/video is still better told by **shipping skills as a plugin and
demoing Claude Code / Xcode 27 running them live** than by building a runtime to demo — so a
bespoke runtime is not required *for the talk*, and Layer 3 is not a reason to build the CLI.
Treat it as a **near-term experiment to revisit once `ClaudeKit` firms up**, kept off the
committed critical path rather than de-scoped.

---

## 7. What's reusable vs thrown away

**Survives a pivot (the real assets — ~90% of the value is delivery-mechanism-agnostic):**

- Scaffold *content*: `Packages/*`, `Project.swift`, `fastlane/`, `.github/workflows/`, lint
  config, Swift Testing conventions.
- The token model (~21 `{{TEMPLATE_*}}` tokens) and the derivation logic in `setup.sh` —
  portable to `ScaffoldKit`'s `ProjectConfig`.
- `TemplateGenerator` + `SyntaxKit` — already Swift; they become `ScaffoldKit`'s nucleus.
- The AI primitives (`_reference/*/.claude/skills/`, the issues plan) — ship as a plugin
  either way.

**Becomes moot (a maintenance *win*, not a loss):** the `*.template` dual-audience promotion
mechanism and `validate-template.yml` exist *only because* one repo serves two audiences at the
same paths. A CLI that generates from embedded resources sheds both.

**Genuinely lost if the template is de-emphasized:** GitHub "Use this template"
discoverability and zero-install. Mitigation: retain a thin front-door repo; do not delete it.

---

## 8. De-risking prototypes (future work, each its own time-box)

1. **`ScaffoldKit` extraction fidelity** — generate an app via `sat init` and via `setup.sh`,
   `diff -r`, then `tuist generate` + build both; they must match.
2. **Manifest-backed `upgrade`** — `init` → hand-edit a generated file → `upgrade`; verify no
   clobber of the edit and that a version migration is applied. *This is the differentiator; it
   is also the most novel, so prove it early.*
3. **Tri-consumer `SKILL.md`** — author one dual-mode skill with an `x-swift-app:` block; load
   it in Claude Code **and** Xcode 27 (`xcrun agent skills`) **and** run its handler via `sat`;
   confirm none of the three parsers break.
4. **Layer 3 spike (now feasible via `ClaudeKit`)** — a minimal `AgentRuntime` running one
   agentic skill through the in-progress `ClaudeKit` client (rather than a raw Messages-API
   loop), with prompt caching (`usage.cache_read_input_tokens > 0` on the second turn). Kept off
   the committed path, but worth an early time-box now that the client work is underway.

---

## 9. Decision & status

**Proposed.** Recommended path: **Phase 0 + Phase 1 unconditionally; Phase 2 (Full CLI, option
D) as the committed direction; Layer 3 off the committed path but a near-term experiment as
`ClaudeKit` firms up.** Awaiting owner acceptance to move Phase 0 (`ScaffoldKit` extraction)
into implementation.

**Open questions to resolve alongside acceptance:** (1) where the skills *source* lives — this
repo vs. a dedicated skills repo (see Phase 1); (2) the CLI's actual name (`sat` is a
placeholder throughout).
