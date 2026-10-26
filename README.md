# taylr

[![SwiftPM](https://img.shields.io/badge/SPM-macOS%20%7C%20Linux-success?logo=swift)](https://swift.org)
[![Swift](https://img.shields.io/badge/swift-6.4-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/github/license/brightdigit/taylr)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/taylr/ci.yml?label=actions&logo=github&branch=main)](https://github.com/brightdigit/taylr/actions)

A Swift CLI that creates a complete, ready-to-ship Swift app or Swift package from a few answers, then runs its everyday build, test, lint, sign and release commands.

> [!WARNING]
> taylr is in development. This repository holds the skeleton (Phase 0 of [the implementation plan](.claude/PLAN.md)); the commands documented at [taylr.sh](https://taylr.sh) do not exist yet.

## Table of Contents

- [Overview](#overview)
- [Repository layout](#repository-layout)
- [Requirements](#requirements)
- [Development](#development)
- [Documentation](#documentation)
- [License](#license)

## Overview

taylr has three command groups:

| Group | Acts on | Purpose |
| --- | --- | --- |
| `taylr profile` | `~/.taylr/` and the macOS Keychain | Organization, Apple team, App Store Connect access, certificates storage, GitHub org and CI secrets, saved once and reused |
| `taylr project` | One app (a Tuist project) | Create, generate, build, test, lint, clean, register, certs, add-device, beta, metadata, privacy, screenshots, validate |
| `taylr package` | One Swift package | Create, build, test, lint, clean, validate |

Every project records its answers in a compiler-checked `Manifest.swift` (module `TaylrDescription`), and `validate` checks that the manifest and the generated files still agree. See [.claude/SPEC.md](.claude/SPEC.md) for the full specification.

## Repository layout

The root package holds the CLI. Every other package lives under `Packages/` as a complete package of its own, depended on by path, so each can later move to its own repository with `git subrepo`.

| Package | Purpose |
| --- | --- |
| `TaylrDescription` (root) | The manifest API; the only module `Manifest.swift` imports |
| `TaylrKit` (root) | Profiles, defaults, manifest loading, `validate`, Keychain and tool wrappers |
| `taylr` (root) | The executable: command groups, prompts and output |
| [`ScaffoldKit`](Packages/ScaffoldKit) | Writes a project from a resolved configuration |
| [`GitHubActionsKit`](Packages/GitHubActionsKit) | GitHub Actions workflow models |
| [`LintKit`](Packages/LintKit) | Lint tool protocol, SwiftLint, swift-format and file headers |
| [`MiseKit`](Packages/MiseKit) | `.mise.toml` models |
| [`DevContainerKit`](Packages/DevContainerKit) | `devcontainer.json` models |
| [`XcodePilot`](Packages/XcodePilot) | Drives Xcode through its scripting dictionary (macOS) |
| [`SyntaxKit`](Packages/SyntaxKit) | Swift code generation; vendored from [brightdigit/SyntaxKit](https://github.com/brightdigit/SyntaxKit) with `git subrepo` |

`Packages/SyntaxKit` tracks SyntaxKit's `taylr` branch. Never edit it by hand: send changes upstream with `git subrepo push Packages/SyntaxKit` and bring them back with `git subrepo pull Packages/SyntaxKit` ([git-subrepo](https://github.com/ingydotnet/git-subrepo)).

## Requirements

- Swift 6.4; the toolchain is pinned in `.swift-version`
- macOS 26 to run taylr; the root package and every package also build and test on Linux
- [mise](https://mise.jdx.dev) for the pinned swift-format and SwiftLint

## Development

```bash
mise install   # pinned swift-format and SwiftLint
make build     # swift build
make test      # swift test (Swift Testing)
make lint      # header, swift-format and SwiftLint fixes, then a strict lint
```

The same targets work inside each `Packages/<Name>`. CI (`.github/workflows/ci.yml`) builds and tests the root and every package on macOS and Linux, and lints everything in strict mode.

Agents and contributors: read [AGENTS.md](AGENTS.md) first for the package boundaries, rules and test conventions.

## Documentation

- [taylr.sh](https://taylr.sh): user documentation, the authority for behavior
- [.claude/SPEC.md](.claude/SPEC.md): the 1.0 specification
- [.claude/PLAN.md](.claude/PLAN.md): the implementation plan, phase by phase

## License

taylr is available under the MIT license. See [LICENSE](LICENSE) for details.
