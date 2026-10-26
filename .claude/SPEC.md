# taylr 1.0 Specification

Oct 24, 2026 · @Leo Dion

## Overview

taylr 1.0 is a Swift CLI that creates a complete, ready-to-ship Swift app or Swift package from a few answers, then runs its everyday build, test, lint, sign and release commands. This spec is derived from the published docs at [taylr.sh](https://taylr.sh) (repo [brightdigit/taylr.sh](https://github.com/brightdigit/taylr.sh)), which are the authority for user-facing behavior, plus the repo's internal `PLAN.md` for build decisions. Where the two disagree, the docs win.

taylr has three command groups:

| Group | Acts on | Purpose |
| --- | --- | --- |
| `taylr profile` | `~/.taylr/` and the macOS Keychain | Organization, Apple team, App Store Connect access, certificates storage, GitHub org and CI secrets, saved once and reused |
| `taylr project` | One app (a Tuist project) | Create, generate, build, test, lint, clean, register, certs, add-device, beta, metadata, privacy, screenshots, validate |
| `taylr package` | One Swift package | Create, build, test, lint, clean, validate |

Every project records its answers in a compiler-checked `Manifest.swift` (module `TaylrDescription`), and `validate` checks that the manifest and the generated files still agree. The source of truth for a project's settings is the manifest, not the profile it was created from.

taylr supersedes [Swoop](https://github.com/brightdigit/Swoop), the October 2024 experiment at the same idea (a dev-loop orchestrator for Bitness on XcodeGen and Mint). Its `XcodePilot` package carries over; the rest is retired.

## Goals and non-goals

**Goals for 1.0**

- One `taylr project create` yields an app that builds, tests, lints and uploads to TestFlight from CI on day one, for any mix of iOS, macOS, tvOS, watchOS and visionOS.
- One `taylr package create` yields a Swift package with Swift Testing, linting, dev containers and cross-platform CI (macOS, Linux, Windows, Android, Wasm).
- Answer once, reuse everywhere: a profile holds the team-level answers; `create` only asks about the project.
- Every generated file is the user's; nothing is hidden behind the tool, and every command has a `make` target teammates can run without taylr.
- Secrets live only in the macOS Keychain and in GitHub secrets, never in a file or a project.
- `Manifest.swift` is the single source of truth for a project's settings; `validate` catches drift and runs in CI without `~/.taylr/`.
- Every project is ready for AI coding agents: `AGENTS.md`, `.agents/`, and Claude Code files by default.

**Non-goals for 1.0**

- `project upgrade` or rewriting workflows after `ci` changes (the user edits `.github/workflows/`; `validate` reports drift).
- Generators other than Tuist, App Store tools other than fastlane, CI providers other than GitHub Actions, server frameworks other than Hummingbird, agents other than Claude Code.
- Developer ID / direct distribution; `distribution` is `[.appStore]` only.
- Executable, macro or plugin package targets from `package create` (one library target).
- Commands that toggle manifest options after creation.
- Codecov, private SPM dependency actions and other extras in the reference template.

## Core concepts

**Profile.** The details that belong to a team, not a project: organization, bundle ID prefix, Apple team (`teamID`, `appleID`, `ascTeamID`), certificates storage, GitHub org, how CI secrets are shared, a file header template, and project defaults. One profile per team the user builds for. Stored as `~/.taylr/profiles/**/*.yml`; the profile's name is its `name:` key, never the file name; duplicate names are an error naming both files. The first profile added becomes the default. Only `organization` and `name` are required; a command that needs a missing key stops before doing anything and prints the exact YAML to add.

**Project defaults.** A `projects:` map of answers `create` preselects or uses with `--no-interactive`. It can live in `~/.taylr/config.yml` (all profiles) and in a profile (that profile only). Resolution order, first hit wins:

1. A command argument or an interactive answer.
2. `projects:` in the project's profile.
3. `projects:` in `config.yml`.
4. taylr's built-in default.

`config.yml` also holds `defaultProfile` and a `profiles:` map of values any profile inherits (every profile key except `organization`), read live on every run.

**Manifest.** `Manifest.swift` at the project root builds one `App` or `Package` value from `TaylrDescription`. `create` writes only values that differ from the default, except `github.repository` (always) and `ci.runners` when GitHub-hosted. The manifest, not the profile, is what later commands read; editing a profile never changes an existing project.

**Secrets.** App Store Connect API key, certificates (match) password, match deploy key or storage key, and the App Store session (`FASTLANE_SESSION`) live in the macOS Keychain, filed under a named profile, and are copied to GitHub as the profile's `github.ciSecrets` says (`organization`, `repository`, `skip`). An app manifest's profile may be `.named("x")` or inline; an inline profile's `secrets` field resolves which Keychain profile to use (`.team()`, `.team(id)`, `.profile(name)`, `.environment`). Any command that uses secrets takes `--profile` to override for one run.

**Git layout.** `worktrees` (default): `<Name>/.bare/` holds the repository, `<Name>/.git` is a file pointing at it, and `<Name>/main/` is the first worktree, where the project lives. `single`: `<Name>/` is an ordinary clone. Chosen per project with `--git-layout` or `git.layout` in project defaults.

**Two project kinds.** An app is a Tuist project with local packages under `Packages/`, signing, fastlane and TestFlight CI. A package is a plain SwiftPM package with tests, lint and CI; it has no profile, bundle ID, URLs, server, App Store tools, press kit or localizations.

## Architecture

```text
taylr CLI (profile, project, package) — prompts (Noora) or --no-interactive; resolves profiles, defaults, Keychain
   │                         │                          │
   ▼                         ▼                          ▼
ScaffoldKit            TaylrDescription           Command runner (TaylrKit)
ProjectConfig,         App / Package types;       wraps make targets; tuist,
SyntaxKit generators,  Manifest.swift is          fastlane match, mise; gh
model assembly         compile + run + decode
   │                         │                          │
   ▼                         ▼                          ▼
Generated project      ~/.taylr + Keychain        GitHub
Manifest.swift,        config.yml, profiles/,     repo via gh, org/repo
Makefile, workflows,   secrets only in Keychain   secrets, deploy key,
Packages/, fastlane/   (never read by CI)         Actions runs validate
```

The CLI gathers answers, ScaffoldKit writes the project, TaylrDescription reads it back, and the command runner wraps the `make` targets the project already has. `~/.taylr/` and the Keychain are read only by the CLI on the developer's Mac; CI gets what it needs from GitHub secrets and never needs `~/.taylr/`.

**Build order** (per ADR-0001, the architecture decision record docs/decisions/0001-scaffold-delivery-and-skills.md in the taylr source repo, still Proposed, which chose a ScaffoldKit library + Claude Code plugin + CLI over the template + copier runner-up; summarized in taylr.sh's internal `PLAN.md`): ScaffoldKit as a library first, then the Claude Code plugin and marketplace (independent of the CLI), then the CLI's `profile`, `project` and `package` groups on top of ScaffoldKit with resources embedded.

**Design decisions carried from `PLAN.md`:**

- Prompts use Noora, pinned to an exact version, modeled on `tuist init`. All answers form one `Codable` struct; the prompter sits behind a protocol for tests; a hidden `--answers <base64 JSON>` option takes the whole struct.
- `Manifest.swift` is written as Swift source and read back by compile + run + decode to JSON, cached, as Tuist does for `Project.swift`.
- `TaylrDescription.Package` is `ExpressibleByStringLiteral`; packages are identified by name, so `"AcmeKit"` and a constant named `AcmeKit` are the same package.
- Detection (GitHub org via `gh`, Apple team via Xcode's `IDEProvisioningTeamByIdentifier` prefs) only suggests; the user always confirms, and `profile add` must complete without it.
- `setup.sh` and the `{{TEMPLATE_*}}` token model are not used. Swift-App-Template, cross-checked against AtLeast (app) and MistKit (package), is the reference for *content* only: `Project.swift`, `Packages/*`, `fastlane/`, workflows, lint config and conventions are ported into ScaffoldKit's embedded resources, with the `PLAN.md` bug list fixed on the way in. ScaffoldKit writes final names from `ProjectConfig` directly; `make` targets are kept and wrapped by the renamed commands. ADR-0001 is superseded by this choice: its option D is the only one left, and the template repo becomes a presentation resource.
- Every command has a `make` target with the same behavior so teammates without taylr can run it.

**Generation strategy.** Anything whose content varies with the answers is modeled in Swift and encoded; anything fixed is a verbatim resource. No `{{TOKEN}}` substitution anywhere except the user-facing text templates in the last row.

| File kind | Strategy | Status |
| --- | --- | --- |
| Swift sources, `Package.swift`, `Project.swift`, `Manifest.swift`, tests | SyntaxKit generators | Decided |
| GitHub workflows (`app.yml`, `package.yml`, metadata, session, cleanup, claude) | Swift `Workflow` model → YAML encoder; `ci.matrix`, runners and `validate` rule 9 all read the same model | Decided |
| `.swiftlint.yml`, `.swift-format`, `.periphery.yml`, `openapi.yaml`, `app_privacy_details.json`, `devcontainer.json` | Codable models → YAML/JSON | Decided |
| `.mise.toml` | Codable model → TOML; varies with Ruby, uv, lint tools, openapi-generator, Swift versions | Decided |
| `Fastfile`, `Matchfile`, `Gemfile` | Fixed Ruby resources; per-answer values go through a generated `Appfile` and `.env`; the `Fastfile` loops over platforms | To confirm |
| `Makefile` | Fixed resource; targets shell out to `taylr` or `Scripts/` | To confirm |
| `Dockerfile` | Fixed resource per server kind; package name and port substituted | To confirm |
| `Scripts/*.sh` (`header.sh`, `lint.sh`, `update-version.sh`, `generate-icons.sh`) | Fixed resources with no tokens, reading config taylr wrote; candidates to retire in 1.x once `taylr` owns the behavior | To confirm |
| `header.mustache`, `LICENSE`, `README.md`, `CHANGELOG.md`, `AGENTS.md` | Text templates with a few substituted values (`{{year}}`, `{{organization}}`); the user edits these afterwards | Decided |

Consequences: ScaffoldKit's tests are encode → decode → equal for every YAML/TOML/JSON model plus a golden-file snapshot per option combination; `validate` for workflows decodes the on-disk YAML into `Workflow` and compares it to what the manifest would generate.

**Packages.** Three constraints shape the split: `Manifest.swift` is compiled and run on the user's Mac, so what it imports must be tiny and dependency-free; ScaffoldKit is its own repo, reusable without taylr; `validate` runs in CI with no interactive code. Every YAML, JSON and TOML config file taylr writes gets its own Codable model package, so the same types generate the file and decode it back for `validate`.

| Package | Repo | Depends on | Holds |
| --- | --- | --- | --- |
| `TaylrDescription` | `brightdigit/taylr` | nothing | `App`, `Package`, `Packages`, `Profile`, `CI`, `License` and the rest of the manifest API, all `Codable`. The only module `Manifest.swift` imports. Published to `/api` with DocC. |
| `TaylrKit` | `brightdigit/taylr` | TaylrDescription, ScaffoldKit, GitHubActionsKit, LintKit, XcodePilot, Subprocess, Yams, swift-configuration, ConfigKeyKit | Profiles and `config.yml`, defaults resolution, manifest loading (compile + run + decode, cached), the `validate` rules, Keychain, and the `gh`, `tuist`, `fastlane`, `mise` and `git` wrappers. No terminal UI. |
| `taylr` | `brightdigit/taylr` | TaylrKit, swift-configuration, ConfigKeyKit (vendored subrepo, by path), Noora | The three command groups, prompts, output and `--json`. Thin. |
| `ScaffoldKit` | `Packages/ScaffoldKit`, later own repo | SyntaxKit (vendored subrepo, by path), the model packages below | `ProjectConfig` (the resolved answers, including create-time-only ones: Swift version, git layout, GitHub visibility, path), the SyntaxKit generators for app skeleton, `Manifest.swift`, `Project.swift`, `Package.swift` and the String Catalog, the fixed resources, and one `Scaffold.write(config, to:)` entry point. Does not know about TaylrDescription; TaylrKit maps manifest to config. |
| `GitHubActionsKit` | `Packages/GitHubActionsKit`, later own repo | Yams | Workflow, jobs, steps, triggers, matrix, runners. Used by ScaffoldKit to write and TaylrKit to check. |
| `LintKit` | `Packages/LintKit`, later own repo | Yams, Subprocess | One package, one product per tool. `LintKit`: the shared protocol (a tool has an encodable config, a mise tool name, a fix/strict runner, and a parser from its output to a common `Diagnostic`). `SwiftLintKit`: the `.swiftlint.yml` model and runner. `SwiftFormatKit`: the `.swift-format` (JSON) model and runner. `HeaderKit`: the file-header writer from `header.mustache`, which runs at lint time on existing projects. `PeripheryKit` joins later with no change to callers. `taylr lint`, `generate --strict` and CI all go through the protocol. |
| `MiseKit` | `Packages/MiseKit`, later own repo | a TOML encoder | `.mise.toml` tools, tasks and env |
| `DevContainerKit` | `Packages/DevContainerKit`, later own repo | Foundation | `devcontainer.json`; a config model in the Dev Container spec, unrelated to the Docker API, so not part of DockerKit |
| `XcodePilot` | `Packages/XcodePilot`, copied from Swoop; later own repo | ScriptingBridge | Xcode's scripting dictionary as `@objc` Swift protocols, no generated headers: open a workspace, wait for a scheme, resolve a run destination, build, debug, test. 1.0 uses it only so `generate` opens the workspace and waits for the scheme to load. Needs a bump from Swift 6.0 experimental flags and macOS 13. |

**Boundary.** The model packages describe file formats; ScaffoldKit describes a taylr project in terms of them (`ProjectConfig`, the SyntaxKit generators, pure assembly functions such as `workflows(for:)` and `miseConfig(for:)`, the layout and fixed resources, and `Scaffold.write(config, to:)`); TaylrKit decides what the config should be and checks the result. `create`: `taylr` collects answers → TaylrKit resolves them into a `ProjectConfig` and creates the GitHub repo and git layout → `ScaffoldKit.write` produces every file → TaylrKit commits and pushes. `validate`: TaylrKit loads the manifest, asks ScaffoldKit for the expected values, decodes the on-disk files with the model packages and compares. ScaffoldKit never touches git, GitHub, the Keychain or the network; TaylrKit never writes a project file directly.

Process execution uses Apple's `swift-subprocess`; Swoop's `ProcessExtensions` is retired. `openapi.yaml` uses the existing `OpenAPIKit` package rather than a model of our own. Periphery is not supported in 1.0, so there is no `PeripheryKit` and the `.periphery` lint option comes out of the docs until it is real.

**Containers.** The server's `Dockerfile` is for Linux deployment and builds under Docker and [apple/container](https://github.com/apple/container) alike; `.devcontainer/` stays on Docker and Codespaces because Dev Containers need the Docker API. A future `taylr project run --server` on the developer's Mac should use Apple's `containerization` package (one lightweight VM per container, no Docker Desktop) rather than Swoop's Engine-API `DockerKit`, which survives only as a Linux or Docker Desktop fallback if that path is ever wanted.

**Repos.**

| Repo | Status | Holds |
| --- | --- | --- |
| `brightdigit/taylr` | new | The only repo created now. Root package: TaylrDescription, TaylrKit, taylr, tests, DocC. `Packages/` holds every future package as a complete local package, plus SyntaxKit as a git subrepo of brightdigit/SyntaxKit tracking its taylr branch (own `Package.swift`, README, LICENSE, tests, lint config), depended on by path, so each can later be split out with `git subrepo` and switched to a tagged URL. A release workflow publishes a universal macOS binary and a Linux binary, since generated projects' CI runs `taylr project validate` on GitHub-hosted runners via `mise use spm:brightdigit/taylr`. |
| `brightdigit/ScaffoldKit` | later; starts as \`taylr/Packages/ScaffoldKit\` | Generators, config, resources; own tests and releases |
| `brightdigit/GitHubActionsKit`, `LintKit`, `MiseKit`, `DevContainerKit` | later; start as \`taylr/Packages/\<Name>\` | One Codable model package per config format, each with encode-decode round-trip tests |
| `brightdigit/XcodePilot` | later; copied from Swoop into \`taylr/Packages/XcodePilot\` now | Xcode scripting bridge |
| `brightdigit/SyntaxKit` | exists | Vendored into taylr as Packages/SyntaxKit with git subrepo, tracking SyntaxKit's taylr branch; ScaffoldKit depends on it by path. Changes flow back with git subrepo push. |
| `brightdigit/claude-plugins` | exists | The marketplace with `taylr@brightdigit`, versioned separately |
| `brightdigit/homebrew-tap` | exists or new | The `taylr` formula with mise and `gh` as dependencies, bumped by taylr's release workflow |
| `brightdigit/taylr.sh` | exists | The site; `deploy.yml` gains DocC injection from taylr's published archive |
| `brightdigit/Swift-App-Template` | retiring | Presentation resource: the ADR, talk material, README pointing at taylr |
| `brightdigit/Swoop` | retired | Superseded by taylr; XcodePilot extracted |

Rules that keep the later split cheap: a package under `Packages/` depends on siblings only through `.package(path: "../<Sibling>")` and never on the root; each carries its own tests, lint config and license so nothing is shared through the parent; the root `Package.swift` is the only place that knows they are local. Splitting one out is `git subrepo init Packages/<Name> -r <url>`, `git subrepo push`, then a `url:` + tag dependency in the root.

## Commands: `taylr profile`

Every `secrets` subcommand acts on the default profile unless `--profile` names another.

| Command | Does | Arguments |
| --- | --- | --- |
| `profile add [name]` | Creates `~/.taylr/profiles/<name>/profile.yml` and `header.mustache`; first profile becomes default. Checks mise, `gh` sign-in and `admin:org` scope first and offers to install or sign in. Asks organization (required), bundle ID prefix, team ID, Apple ID, ASC team ID, certificates repo (create / existing / later), GitHub org, runners (by visibility / self-hosted / GitHub-hosted), API key (now / later), CI secrets mode (organization / per repo / skip). Values already in `config.yml` `profiles:` are suggested and kept there, not copied. Detected values (Xcode team, `gh` org) are always confirmed. | `--no-interactive` (needs `--organization`; installs nothing; stops and prints the command if a passed value needs a missing tool), `--organization`, `--bundle-id-prefix`, `--team-id`, `--apple-id`, `--asc-team-id`, `--certs-repo`, `--github-org`, `--github-visibility`, `--ci-runners` |
| `profile list` | One line per profile: `*` marks default, organization, team ID, warnings. Warnings name the fixing command: App Store session expired or expiring, skipped answers a project now needs. | `--json` (never includes secrets) |
| `profile default [name]` | Sets `defaultProfile` in `config.yml`; without a name prints the current default. Existing projects are unaffected. | `name` |
| `profile remove <name>` | Deletes the profile folder and its Keychain items after confirmation. Secrets already on GitHub stay. Removing the default asks which remaining profile becomes default. | `name` (required), `--no-interactive` |
| `profile secrets share [mode]` | Sets `github.ciSecrets` to `organization`, `repository` or `skip` and copies every secret to GitHub accordingly. No mode: keep the current one and re-copy all secrets. `skip` prints the secret list and the commands to set them by hand. | `mode`, `--profile`, `--no-interactive` (fails if `gh` isn't signed in) |
| `profile secrets set <secret> [path]` | Saves one secret in the Keychain and copies it to GitHub per the share mode. `api-key` reads a `.p8` (key ID from the file name, asks issuer ID); `match-password` asks without echo; `match-deploy-key` reads a private key file; `match-storage-key` reads S3 keys, a GCS service-account JSON, or a GitLab token. | `secret` (required), `path` (required for `api-key`, `match-deploy-key`, GCS storage key), `--issuer-id` (required with `--no-interactive` for `api-key`), `--profile`, `--no-interactive` (`match-password` reads stdin) |
| `profile secrets renew-session` | Signs in to App Store Connect (2FA if needed), saves `FASTLANE_SESSION` in the Keychain and copies it to GitHub. Always interactive: no `--no-interactive`. | `--profile` |

**`profile add` certificates repo.** "Create" makes an empty private repo in the GitHub org, generates an SSH deploy key, adds the public half read-only with `gh repo deploy-key add` (needs admin), and keeps the private half in the Keychain. "Use existing" adds the deploy key to the named repo. Cloud storage (S3, GCS, GitLab secure files) is set by editing `signing.storage` in the profile file and adding the key with `secrets set match-storage-key`.

**`profile.yml` keys:** `name`, `organization` (both required), `bundleIDPrefix`, `apple.teamID`, `apple.appleID`, `apple.ascTeamID`, `signing.storage` (`git` | `s3{bucket,region}` | `googleCloudStorage{bucket}` | `gitlabSecureFiles{project}`), `github.org`, `github.ciSecrets`, `header` (path or `null`), `projects` (project defaults). Changing a profile affects only projects created afterwards.

## Commands: `taylr project`

All commands except `create` run inside the project and fail with a message outside one, or in a package (`generate` says a package has nothing to generate). Signing and release commands need `appStoreConnect: .fastlane` and stop with a message otherwise.

**`project create`** asks, in order: profile (only with more than one), name (defaults to the folder; must be a valid Swift identifier), platforms (multi-select, minimum 27), server (Hummingbird), OpenAPI (only with server), bundle ID (prefix + name, editable), web links (website URL → `/privacy`, `/support`, `/`; or Later), license (default `license.app` or proprietary), GitHub (create repo?), repository (`org/Name`, editable), git layout, then a summary and confirmation. If no profile exists it runs `profile add` first. It then: creates the GitHub repo; sets up the folder in the chosen git layout; writes the project with license and `Scripts/header.mustache`; records non-default answers in `Manifest.swift` (profile by name, `github.repository` always, GitHub-hosted runners); makes the first commit and pushes. Swift version is taken from `xcode-select -p`, never asked. Project defaults fill everything not asked: runners, workflows, lint, App Store tools, screenshots, press kit, localizations, Git LFS, dev containers, agents.

`create` arguments: `--no-interactive`, `--name`, `--platform <p>[@ver]` (repeatable), `--profile`, `--server`, `--openapi` (requires `--server`), `--swift-version`, `--bundle-id`, `--website-url`, `--privacy-url`/`--support-url`/`--marketing-url` (privacy and support needed together without `--website-url`), `--github`/`--no-github` (`--github-*` cannot combine with `--no-github`), `--github-repository owner/name`, `--github-visibility`, `--ci-runners` (cannot combine with `--no-ci`), `--no-ci`, `--license`, `--lint a,b,c`/`--no-lint`, `--header <path>`/`--no-header`, `--localization` (repeatable; first is development language), `--no-app-store-connect` (also drops screenshots), `--no-screenshots`, `--no-press-kit`, `--cross-platform`/`--no-cross-platform`, `--git-lfs`/`--no-git-lfs`, `--no-devcontainer`, `--include-nightly`, `--agent claude-code`/`--no-agents`, `--git-layout single|worktrees`, `--path`/`-p`.

| Command | Does | Arguments | `make` target |
| --- | --- | --- | --- |
| `generate` | Installs pinned tool versions from `.mise.toml` if missing, auto-fixes lint, generates `<Name>.xcworkspace` with Tuist, opens Xcode. | `--no-open`, `--strict` | `generate` |
| `build` | Debug build without Xcode. `--release` builds a signed App Store `.ipa` (or `.pkg` on macOS), fetching App Store certs first. | `--release`, `--profile` (with `--release`) | `build`, `release-build` |
| `test` | Runs Swift Testing tests for `<Name>App` and `<Name>Kit` on the Mac. | `--filter <pattern>` | `test` |
| `lint` | Runs the manifest's lint tools over packages and `Project.swift`, auto-fixing; writes the file header to every Swift file. First lint in a new year updates every header's year and says so. | `--strict` (fail instead of fix; a year-only header change is a warning) | `lint` |
| `clean` | Trashes `.build/`, DerivedData for this checkout, the generated Xcode project and other git-ignored files; keeps `.env` and `.claude/settings.local.json`. Uses `trash` when installed. | `--no-interactive` | `clean` |
| `register` | Registers bundle ID and app group with Apple and creates the app in App Store Connect; idempotent. Needs `apple.appleID`, `apple.teamID`, and `ascTeamID` if on several teams. | `--profile` | `setup-app setup-groups` |
| `certs` | Fetches and installs certificates and profiles via fastlane match from the profile's storage. | `--development`, `--app-store`, `--regenerate`, `--profile` | `certs` |
| `add-device <udid>` | Registers a device and refreshes development profiles. | `udid` (required), `--name` (asked if missing; UDID with `--no-interactive`), `--no-interactive`, `--profile` | `add-dev-device UDID=… NAME=…` |
| `beta` | Signed release build uploaded to TestFlight; build number = latest TestFlight build + 1. | `--profile` | `beta` |
| `metadata` | Uploads `fastlane/metadata/` listing (name, subtitle, description, keywords, URLs, age rating, screenshots). No build. | `--profile` | `sync-app-store` |
| `privacy` | Publishes `fastlane/app_privacy_details.json` via Apple ID session (`FASTLANE_SESSION`); tells the user to run `secrets renew-session` when expired. | `--profile` | `privacy-details` |
| `screenshots` | Runs `UITests/` in simulators, frames with bezels and titles, writes `fastlane/screenshots/`. iOS, tvOS, watchOS only; macOS by hand. Stops with a message without `screenshots: .fastlaneSnapshot`. | `--no-frame` | `capture-all` (`capture-ios` for `--no-frame`) |
| `validate` | Checks manifest and project agree; see Validation. Never changes a file; reads no profile. | `--json` | — |

`--profile` on a signing or release command uses that named profile's Keychain secrets for one run instead of the profile the manifest's `secrets` resolves to.

## Commands: `taylr package`

A package has no Xcode project, signing, fastlane or App Store, so there is nothing to generate or ship. All commands except `create` run inside the package.

**`package create`** asks: name, platforms, GitHub (create a private repo?), profile (only when creating a repo and more than one profile exists: it picks the GitHub org), git layout, license (default `license.package` or MIT), then a summary. A package needs no profile; without one the repo goes to the user's own account and `config.yml` project defaults apply. It ignores app-only defaults such as `server`. Steps: create the repo; set up the git layout; write the package with license and `Scripts/header.mustache`; record non-default answers in `Manifest.swift` (`github.repository` always, GitHub-hosted runners); first commit and push. 1.0 creates one library target with a Swift Testing test target.

`create` arguments: `--no-interactive`, `--name`, `--platform <p>[@ver]` (repeatable), `--swift-version`, `--github`/`--no-github`, `--github-repository`, `--github-visibility`, `--ci-runners`, `--no-ci`, `--license`, `--lint`/`--no-lint`, `--header`/`--no-header`, `--git-lfs`/`--no-git-lfs` (default off), `--no-devcontainer`, `--include-nightly`, `--agent`/`--no-agents`, `--profile`, `--git-layout`, `--path`/`-p`.

| Command | Does | Arguments | `make` target |
| --- | --- | --- | --- |
| `build` | `swift build`; `--release` adds `-c release`. | `--release` | `build` |
| `test` | `swift test` with Swift Testing. CI runs the same on every chosen platform plus Linux, Windows, Android and Wasm. | `--filter` | `test` |
| `lint` | Same as `project lint`, over the package. | `--strict` | `lint` |
| `clean` | Trashes `.build/`, DerivedData and git-ignored files; keeps `.env` and `.claude/settings.local.json`. | `--no-interactive` | `clean` |
| `validate` | Manifest compiles; name, platforms and minimums match `Package.swift`; each manifest dependency is in `Package.swift` (others ignored); a package name or `Package` in `dependencies` is an error; workflows, tools and files match; `CLAUDE.md` is a symlink to `AGENTS.md`. | `--json` | — |

## CLI conventions

- **Interactive by default.** Prompts show a summary before any side effect. `--no-interactive` never prompts: answers come from flags, then project defaults, then taylr's defaults; a missing required value (for example `--name`, or `--platform` without `platforms` in defaults, `--organization` for `profile add`, `--issuer-id` for `api-key`) exits non-zero before doing anything. `renew-session` has no non-interactive mode because it always signs in.
- **Fail before acting.** A command that needs a missing profile key, tool, secret or sign-in stops before any side effect and prints the exact fix: the YAML key and file to edit, the `taylr profile …` command, or the shell command to run. It never asks partway through.
- **`--profile`** on any command that uses Apple or GitHub access selects a named profile's Keychain secrets for one run. `validate` reads no profile and no secrets.
- **`--json`** on `validate` and `profile list` prints machine-readable results; secrets are never included.
- **Exit status** is non-zero on any failed check, missing requirement or refused precondition, and zero otherwise. `validate` never modifies files.
- **Make parity.** Every `project` and `package` command maps to a `make` target in the generated project with the same effect, named on each command's docs page. The CLI is a convenience over the project's own scripts, never the only way.
- **Platform and version syntax.** `--platform iOS@27.2`; platform names in any capitalization; minimum default 27.
- **Hidden `--answers <base64 JSON>`** takes the whole answers struct, for tests and template-fidelity checks.
- **Clean is reversible.** `clean` uses the `trash` command when present so removed files go to the Trash.
- **Output.** Checklists print `✓`/`✗` lines with aligned labels, as in the docs' `validate` and `profile list` samples.

## TaylrDescription API

`Manifest.swift` is `import TaylrDescription` plus one top-level `let manifest = App(...)` or `Package(...)`. All optional parameters have defaults; `create` omits anything at its default.

**`App`**

| Field | Type | Default |
| --- | --- | --- |
| `name` | `String` (valid Swift identifier) | required |
| `profile` | `.named(String)` or inline `Profile` | required |
| `platforms` | `[Platform]`: `.iOS()`, `.macOS(.v27)`, `.visionOS("27.2")`, `.tvOS`, `.watchOS` | required |
| `bundleID` | `String` | profile `bundleIDPrefix` + `.` + name |
| `appGroupID` | `String` | `group.` + bundle ID |
| `urls` | `.init(privacy:support:marketing:)` or `.base(url, privacy:, support:, marketing:)` with path defaults `/privacy`, `/support`, `/` | none |
| `packages` | `.appOnly`, `.withServer(Package)`, or `Packages(client:server:others:)` | `.appOnly` |
| `server` | `Package.server(...)`; shorthand for `packages: .withServer(server)` | none |
| `appStoreConnect` | `.fastlane` or `nil` | `.fastlane` |
| `screenshots` | `.fastlaneSnapshot` or `nil`; requires fastlane | `.fastlaneSnapshot` with fastlane |
| `distribution` | `[.appStore]` | `[.appStore]` |
| `pressKit` | `.uv` or `nil` | `.uv` |
| `localizations` | `[String]` App Store locale codes; first is development language | `["en-US"]` |
| `crossPlatform` | `Bool` | `true` |
| `generator` | `.tuist` | `.tuist` |
| `taylrVersion` | `String` | `"1.0.0"` |

Plus the shared settings below, with `license` defaulting to `.proprietary` and `gitLFS` to `true`.

**Inline `Profile`**: `organization` (required), `bundleIDPrefix`, `apple: .init(teamID:appleID:ascTeamID:)`, `signing: .init(storage:)` where storage is `.git(url)`, `.s3(bucket:region:)`, `.googleCloudStorage(bucket:)` or `.gitlabSecureFiles(project:)`, `github: .init(org:ciSecrets:)` with `ciSecrets` `.organization` | `.repository` | `.skip`, and `secrets`: `.team()` (default: the named profile with the same `apple.teamID`), `.team("ID")`, `.profile("name")`, or `.environment` (env vars named like the CI secrets, nothing from the Keychain). An inline profile has no `name`, `header` or `projects`. Keys it leaves out fall back to `profiles:` in the user's `config.yml`.

**`Package`** (standalone, or one of an app's packages): `name` (required), `platforms` (default: SwiftPM minimums), `swiftVersion` (default: selected Xcode's; inside an app, the app's), `dependencies`, `taylrVersion` (ignored inside an app), plus the shared settings (a package inside an app ignores them except `swiftVersion`). `license` defaults to `.mit`, `gitLFS` to `false`, workflows to `.ci`, `.cleanup`, `.claude`. `Package` is `ExpressibleByStringLiteral`: `"AcmeKit"` is `Package(name: "AcmeKit")`; two packages with the same name are the same package.

**`Package.server(name:platforms:dependencies:framework:)`**: defaults `"<App>Server"`, `[.macOS()]`, none, `.hummingbird(routing: .builtIn)`; `routing: .openAPI` describes the API in `openapi.yaml` and generates the server code. A server package has no library product, so nothing may depend on it.

**`Packages(client:server:others:)`**: `client` required; taylr finds the full graph by following `dependencies`; `others` lists packages nothing depends on yet.

**`dependencies`** accepts the app's own packages (a `Package` or its name; taylr creates one library per package and links it to the dependent target) and SwiftPM dependencies (`.package(url:from:)`, `exact:`, `branch:`, `.package(path:)`; taylr adds them to `Package.swift` `dependencies` only; the user links products to targets). In a standalone package, a package name or `Package` in `dependencies` is a `validate` error.

**Shared settings (apps and packages)**

| Field | Values | Default |
| --- | --- | --- |
| `github` | `.init(repository: "owner/name")` | none |
| `ci` | `.githubActions(runners:workflows:matrix:)` or `nil` | `.githubActions()` |
| `swiftVersion` | `String`; also the oldest Swift CI tests | selected Xcode's Swift |
| `includeNightly` | `Bool` | `false` |
| `devcontainer` | `Bool` | `true` |
| `lint` | `[.swiftLint, .swiftFormat, .periphery]`; `[]` = off | `[.swiftLint, .swiftFormat]` |
| `header` | `.file(path)` or `nil` | `.file("Scripts/header.mustache")` |
| `license` | `.proprietary`, `.mit`, `.apache2`, `.bsd2`, `.bsd3`, `.boost`, `.mpl2`, `.epl2`, `.gpl2`, `.gpl3`, `.lgpl21`, `.agpl3`, `.cc0`, `.unlicense` | `.proprietary` app / `.mit` package |
| `gitLFS` | `Bool` | `true` app / `false` package |
| `agents` | `[.claudeCode]` or `[]` | `[.claudeCode]` |

**`ci`**: `runners` is `.selfHosted(labels: ["self-hosted", "macOS"], xcodes: ["/Applications/Xcode.app"])` (default) or `.githubHosted`. `workflows` is a subset of `.ci`, `.appStoreMetadata`, `.appStoreSession`, `.cleanup`, `.claude` (default: all that apply; packages never get the two App Store ones). `matrix: .init(feature:version:main:)`, each `.init(include:exclude:)` with entries `.swift("6.1")`, `.linux(.noble | .jammy)`, `.wasm`, `.wasmEmbedded`, `.windows(.v2022 | .v2025)`, `.android(api:)`, `.xcode("26.4")` (GitHub-hosted, installed with setup-xcode), `.xcode(path:)` (must be one of `runners.xcodes`). An include applies to that build and every larger one; an exclude applies only to the build named.

## Generated project

**App layout.** `Project.swift` (Tuist, one app target per platform, all linking the client package and sharing one bundle ID), `Manifest.swift`, `Tuist/`, `Packages/<Name>App` (SwiftUI, inside `#if canImport(SwiftUI)` so it builds as an empty module elsewhere), `Packages/<Name>Kit` (no UI; builds on Linux, Windows, Android), `Packages/<Name>Server` + `Dockerfile` (with server), `Sources/` and `Resources/` (entry point, icon, privacy manifest), `Config/` (build settings, version numbers), `UITests/`, `fastlane/` (+ `Gemfile`, `Gemfile.lock`, `.env.example`), `Marketing/`, `Scripts/` (lint, header, icons, versioning), `.swiftlint.yml`, `.swift-format`, `.github/workflows/`, `.devcontainer/` (one folder per Swift version), `.agents/`, `.claude/`, `.gitattributes`, `AGENTS.md`, `CLAUDE.md` → `AGENTS.md` symlink, `LICENSE`, `Makefile`, `.mise.toml`, `README.md`, `CHANGELOG.md`. The Xcode workspace is generated, never committed.

**Package layout.** `Package.swift`, `Manifest.swift`, `Sources/<Name>/`, `Tests/<Name>Tests/`, `Scripts/`, lint configs, workflows, dev containers, agent files, `LICENSE`, `Makefile`, `.mise.toml`, `README.md`, `CHANGELOG.md`.

**Conditional files** (present only when the setting is on; `validate` checks both directions):

| Setting | Files |
| --- | --- |
| `appStoreConnect: .fastlane` | `fastlane/`, `Gemfile`, `.env.example`, Ruby in `.mise.toml` |
| `screenshots: .fastlaneSnapshot` | `UITests/` |
| `pressKit: .uv` | `Marketing/`, `Scripts/generate-icons.sh` (`make icons`: light, dark, tinted icons, 1024 App Store icon, favicons, Open Graph image), uv in `.mise.toml` |
| `lint` | `.swiftlint.yml`, `.swift-format`, `.periphery.yml`, each tool in `.mise.toml` |
| `header` | `Scripts/header.mustache`, `Scripts/header.sh` |
| `ci` | `.github/workflows/` |
| `devcontainer` | `.devcontainer/`, `devcontainer.json` on the newest Swift plus `swift-<ver>/` per older version and a nightly one with `includeNightly` |
| `gitLFS` | `.gitattributes` |
| `agents: [.claudeCode]` | `.claude/`, `CLAUDE.md`, `claude.yml`, `claude-code-review.yml` |
| `server` | `Packages/<Name>Server`, `Dockerfile`, `openapi.yaml` with `.openAPI`, swift-openapi-generator in `.mise.toml` |
| `localizations` | A String Catalog entry and Tuist known region per language, `fastlane/metadata/<locale>/` per language |

**Workflows.** `.ci` = `app.yml` (`package.yml`): builds, lints in strict mode, tests, runs `validate`, uploads `main` to TestFlight (apps). `.appStoreMetadata` = `app-store-metadata.yml`, manual. `.appStoreSession` = `asc-session.yml`, weekly session check. `.cleanup` = `cleanup-caches.yml`, `cleanup-pr-caches.yml`. `.claude` = `claude.yml`, `claude-code-review.yml`. macOS jobs run on the manifest's runners; Linux, Windows and Android always on GitHub-hosted runners.

**Build matrix.** `.ci` runs on non-draft pull requests, pushes to `main` and version branches (`1.2.0`), and manual dispatch. `feature` (PR into a non-main branch): newest Swift on Ubuntu 24.04 plus macOS per platform. `version` and `main`: every Swift version from `swiftVersion` to newest on Ubuntu 24.04 and 22.04, Wasm, Wasm Embedded, Windows, Android, macOS per platform, plus nightly with `includeNightly`. Every package builds on each; an app's packages too unless `crossPlatform: false`.

**File header.** `Scripts/header.mustache` with `{{file}}`, `{{project}}`, `{{organization}}`, `{{year}}`, `{{license}}`; every line `//` or `//  …`; plain variables, no Mustache sections. taylr's bundled header per license adds the SPDX identifier and the per-file notice that Apache, GPL, LGPL, AGPL, MPL and EPL ask for; CC0 and Unlicense headers carry no copyright line.

**License file.** Written by taylr from bundled GitHub license texts, filling year and organization; `COPYING` for GPL 3, `UNLICENSE` for Unlicense, else `LICENSE`. Never created via `gh repo create --license` (it would break the worktree bootstrap).

**Server.** Hummingbird, one `GET /status` endpoint, binds for Docker (not loopback), listens on 8080 with `--port` to override; `Dockerfile` builds it for Linux. With `.openAPI`, routes come from `openapi.yaml` via swift-openapi-generator.

**Tools.** `.mise.toml` pins Tuist, lint tools, swift-openapi-generator, Ruby and uv as needed; `mise install` after cloning. Swift 6 language mode with strict concurrency; tests use Swift Testing.

**Git bootstrap.** With GitHub: create the repo first, then clone. `single`: `git clone` forcing branch `main`. `worktrees`: `git clone --bare` into `<Name>/.bare/`, a `<Name>/.git` file containing `gitdir: ./.bare`, `remote.origin.fetch` set so branches fetch normally, `git lfs install` when LFS is on, then `git worktree add --orphan -b main main` (git ≥ 2.42). Without GitHub: `git init`, or `git init --bare .bare` plus the worktree.

## Validation rules

`validate` reads the manifest and the working tree only: no profile, no secrets, no network. Each check prints a `✓`/`✗` line; any `✗` exits non-zero; nothing is modified. CI runs it on every pull request.

| # | Check | App | Package |
| --- | --- | --- | --- |
| 1 | `Manifest.swift` compiles (typos and wrong types are compile errors) | yes | yes |
| 2 | Name matches `Project.swift` / `Package.swift` | — | yes |
| 3 | Bundle ID and app group match `Project.swift` and `fastlane/Appfile` | yes | — |
| 4 | Each platform has an app target whose deployment target is the manifest minimum; each package's `Package.swift` has its own manifest minimums | yes | yes (platforms + minimums) |
| 5 | Each manifest package exists in `Packages/`; every dependency is a declared package; no cycles; client never depends on the server (directly or transitively); at most one server; `Package.server` only in `server`; two packages with the same name but different settings is an error; a package in `others` that something depends on is reported | yes | — |
| 6 | Each manifest dependency is in the right `Package.swift` (own packages must also be linked to the target; third-party only in `dependencies`); extra dependencies in `Package.swift` are ignored | yes | yes (a package name or `Package` in `dependencies` is an error) |
| 7 | Server framework and routing match; `.openAPI` needs `openapi.yaml` | yes | — |
| 8 | Web links and localizations match `fastlane/metadata/` (one folder per locale) when `urls` is set | yes | — |
| 9 | Each manifest workflow is in `.github/workflows/`, no other taylr workflow is, macOS jobs run on the manifest's runners; user-written workflows ignored; `.claude` workflows need `.claudeCode`; `.xcode(path:)` is one of `runners.xcodes` | yes | yes |
| 10 | Files match settings both ways: fastlane, screenshots, press kit, each lint tool, license file, Git LFS, dev containers (one for the oldest Swift tested), header template exists and every line is a `//` comment | yes | yes |
| 10a | watchOS layout matches platforms: with iOS present the watch target is embedded in the iOS target with bundle ID \<bundleID>.watchkitapp and no separate watch lane; without iOS it is a standalone target with the app's bundle ID and its own release build | yes | — |
| 11 | `CLAUDE.md` is a symlink to `AGENTS.md`; the fix printed is `ln -sf AGENTS.md CLAUDE.md` | yes | yes |

## Storage and security

| What | Where |
| --- | --- |
| Default profile, `profiles:` fallbacks, `projects:` defaults | `~/.taylr/config.yml` |
| Organization, Apple team, certificates storage, GitHub settings, project defaults | `~/.taylr/profiles/**/*.yml` (any depth; `name:` identifies the profile) |
| File header template | `~/.taylr/profiles/<name>/header.mustache` |
| App Store Connect API key (`.p8` + key ID + issuer ID), match password, match deploy key, match storage key, `FASTLANE_SESSION` | macOS Keychain, filed under the profile name |
| The same secrets for CI | GitHub organization or repository secrets, per `github.ciSecrets` |

**GitHub secret names:** `APP_STORE_CONNECT_API_KEY_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_KEY` (base64 `.p8`), `MATCH_PASSWORD`, `MATCH_GIT_BASIC_AUTHORIZATION` (HTTPS certs repo), `MATCH_GIT_PRIVATE_KEY` (SSH certs repo on GitHub-hosted runners only), `MATCH_S3_ACCESS_KEY` + `MATCH_S3_SECRET_ACCESS_KEY`, `MATCH_GOOGLE_CLOUD_KEYS` (workflow writes it to a file and sets `MATCH_GOOGLE_CLOUD_KEYS_FILE`), `MATCH_GITLAB_PRIVATE_TOKEN` (mapped to `PRIVATE_TOKEN`), `FASTLANE_SESSION`, `CLAUDE_CODE_OAUTH_TOKEN` (set by `/install-github-app`, not by taylr). The same names are what `secrets: .environment` reads locally and what `.env.example` lists.

**Invariants**

- No secret ever appears in `Manifest.swift`, any generated file, `~/.taylr/*.yml`, or `--json` output.
- `profile.yml` keys that `config.yml` `profiles:` already supplies are not copied into the profile when accepted, so one edit updates every profile.
- Organization-mode secret sharing requires org admin; personal accounts use repository mode. `skip` prints the list above with the `gh secret set` commands.
- `profile remove` deletes Keychain items but leaves GitHub secrets alone and says so.
- Self-hosted runners use their own SSH access to the certs repo; `MATCH_GIT_PRIVATE_KEY` is only set for GitHub-hosted runners.
- `profile list` warns when `FASTLANE_SESSION` is expired or within days of expiring; `asc-session.yml` warns weekly in CI.

## Claude Code plugin and agent files

Every project gets `AGENTS.md` (layout, commands, conventions for any agent: Codex, Cursor, Gemini CLI, Xcode) and `.agents/` with `notes.md` (a running log of corrections) and `skills/` (Codex reads these; `.claude/skills` links to it). `agents: [.claudeCode]` adds the `CLAUDE.md` symlink, `.claude/` settings and the two `.claude` workflows (`@claude` mentions in issues and PRs; automatic PR review). `.claude/settings.json` lists the plugin under `extraKnownMarketplaces` and `enabledPlugins` so Claude Code offers to install it on first open. `AGENTS.md` derives from the template's `CLAUDE.template.md`; Windows checkouts need `core.symlinks` for `CLAUDE.md`.

The plugin is `taylr@brightdigit` in the `brightdigit/claude-plugins` marketplace, versioned separately from the CLI and updated with `/plugin update`:

| Kind | Contents |
| --- | --- |
| Slash commands | `/generate`, `/lint`, `/test`, `/beta`, `/certs` → the matching `taylr project` command |
| Skills (`SKILL.md`, also usable by Xcode's agent) | `swift-testing` (tests the project's way), `swift-feature` (a feature across Kit and App), `tuist-project` (targets and settings in `Project.swift`) |
| Agents | Write tests, review Swift changes, diagnose failed CI runs |

The plugin does not repeat skills Xcode already has built in.

**Naming.** Claude Code namespaces plugin commands by plugin name, so the commands are invoked as `/taylr:generate`, `/taylr:lint`, `/taylr:test`, `/taylr:beta` and `/taylr:certs`; the docs should show the prefixed form.

**Where AI earns its place.** The slash commands only save typing. The value is in multi-file changes that cut across the project's conventions, where the skills carry the structure the CLI can't: adding a feature across Kit, App and tests (`swift-feature`); adding a package to the graph in `Manifest.swift`, `Package.swift` and `Project.swift` together, then running `validate`; wiring an OpenAPI endpoint end to end (`openapi.yaml` → generated server code → Kit client → App view); adding a platform target or a localization with its metadata folder; writing the screenshot UI test for a new screen; and, since 1.0 has no `project upgrade`, applying a `ci` or `lint` manifest change to `.github/workflows/` and config files until `validate` passes. The agents cover the recurring chores: writing tests, reviewing Swift changes, and diagnosing a failed CI run from its logs.

## Acceptance criteria

- [ ] A freshly created app and package (every platform, with and without a server) pass `validate`, `tuist generate`, a local build and `test` with no manual edits. There is no `setup.sh` oracle: the template is a content reference, not a generator.
- [ ] `taylr project create` and `taylr package create` run end to end on a clean Mac with only Xcode, producing a project whose `.ci` workflow passes on first push (self-hosted and GitHub-hosted).
- [ ] `--no-interactive` with any missing required option exits non-zero and never prompts.
- [ ] No secret appears in the manifest, the generated project, `~/.taylr/`, or any `--json` output.
- [ ] `profile add` completes without Xcode detection (Linux, no Xcode, or a changed prefs format).
- [ ] `validate` passes on a freshly created app and package, fails with the documented message on each rule when the matching file or value is changed, and runs in CI without `~/.taylr/`.
- [ ] Every `project` and `package` command has a `make` target with the same effect, and the docs name it.
- [ ] Every argument on every docs page exists with the documented default and constraint (for example `--openapi` requires `--server`; `--github-*` conflicts with `--no-github`; `--ci-runners` conflicts with `--no-ci`).
- [ ] Worktree layout bootstraps on an empty GitHub repo with git ≥ 2.42, with and without LFS.
- [ ] A manifest typo (wrong type, unknown field) fails `validate` at compile; a misspelled package name fails rule 5 with the name printed.
- [ ] Year rollover: the first `lint` in a new year rewrites every header's year and reports it; `--strict` treats a year-only diff as a warning.
- [ ] Optional: a built-in agent runtime on ClaudeKit with prompt caching (ADR-0001 Layer 3, kept as an experiment).

## Open questions

Carried from `PLAN.md`, each with a proposed 1.0 resolution to confirm or overrule. The proposals favor shipping what the docs already promise and deferring the rest.

| Question | Proposed 1.0 resolution |
| --- | --- |
| Where `profile add` gets Apple data: API key first, Apple ID sign-in, or local detection? | Ask for IDs as the docs show, with detection as a suggestion only. Add an Apple ID sign-in path that lists teams for `ascTeamID` (the docs already describe it). Defer deriving team ID from the ASC API until verified. |
| Should `Package.server` be its own type so it can't sit in `client` or `dependencies`? | Keep one `Package` type with a `framework` field; `validate` rule 5 catches misuse. A distinct type would break `"AcmeKit"`-style literals in `dependencies`. |
| Can the presets' `AcmeApp` / `AcmeKit` names be changed without a custom `Packages`? | No for 1.0; a custom `Packages(client:server:)` is the documented way. |
| Is `dependencies` on a standalone `Package` with a package name an error or ignored? | Error, reported by `validate` (as documented). |
| Does `package create` ask what the package holds (library, executable, macro, plugin)? | No; 1.0 creates one library target. Listed as a non-goal. |
| watchOS bundle ID conventions (companion vs standalone)? | Decided by platforms. watchOS alone: a standalone watch app with the app's bundle ID and its own .ipa. watchOS with iOS: a companion, embedded in the iOS app target with bundle ID \<bundleID>.watchkitapp and shipped inside the iOS build. validate checks the layout matches (rule 10a). |
| Does `.vapor` exist in `TaylrDescription` 1.0? | No. Only `.hummingbird(routing:)` in 1.0; a later minor adds `.vapor`. |
| Git layout for existing projects (`project clone --git-layout`)? | Document the manual worktree steps (already in the project reference); no new command in 1.0. |
| Should profile `projects.ci.runners` accept custom labels and `xcodes`? | No for 1.0; only `github-hosted` / `self-hosted`. Labels and `xcodes` are set per project in the manifest. |
| Should taylr rewrite workflows when `ci` changes? | No; the user edits `.github/workflows/` and `validate` reports drift (documented). Belongs to a future `project upgrade`. |
| OpenAPI client without a server? | Never: OpenAPI describes a server's API, so `--openapi` requires `--server`. |
| Options passed without `--no-interactive`: pre-fill or error? | Pre-fill the prompt with the passed value as the preselected answer. |
| Reading secrets from environment variables when `profile add` runs on CI? | Out of scope; `profile add` is a developer-Mac command. CI uses GitHub secrets and `secrets: .environment`. |
| Does ADR-0001 get accepted; what does the template repo become? | Superseded. Only option D (full CLI from embedded resources) survives; setup.sh is not used, so the fidelity diff and the token-mapping table are dropped. Swift-App-Template is retired as a generator and becomes a resource for presentation attendees: the ADR, the talk material and a README pointing at taylr. |
| Where ScaffoldKit and the skill sources live; how non-Swift resources are embedded? | ScaffoldKit is its own repository, pulled into the taylr source repo as a subrepo (submodule), with resources via SwiftPM `resources:`; skills in `brightdigit/claude-plugins`. Open until the source repo layout is fixed. |
| Later: `project upgrade`, Developer ID distribution, alternative generators / App Store tools / CI providers / agents, toggle commands after create | Explicitly post-1.0. |

Sources: [taylr.sh docs](https://github.com/brightdigit/taylr.sh/tree/main/src/content/docs/docs) and [`PLAN.md`](https://github.com/brightdigit/taylr.sh/blob/main/PLAN.md), read on 2026-10-24.
