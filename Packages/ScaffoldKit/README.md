# ScaffoldKit

[![SwiftPM](https://img.shields.io/badge/SPM-macOS%20%7C%20Linux-success?logo=swift)](https://swift.org)
[![Swift](https://img.shields.io/badge/swift-6.4-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Writes a complete taylr app or package from a resolved `ProjectConfig`: SyntaxKit generators, model assembly, fixed resources and one `Scaffold.write(config, to:)` entry point. It never touches git, GitHub, the Keychain or the network.

> [!NOTE]
> ScaffoldKit is in development as part of [taylr](https://github.com/brightdigit/taylr) and lives in `taylr/Packages/ScaffoldKit` until it moves to its own repository. Right now it holds only a placeholder; real types arrive in a later phase of taylr's implementation plan.

## Requirements

- Swift 6.4 (pinned in `.swift-version`)
- macOS or Linux

## Dependencies

- [`SyntaxKit`](../SyntaxKit) (local path)
- [`GitHubActionsKit`](../GitHubActionsKit) (local path)
- [`LintKit`](../LintKit) (local path)
- [`MiseKit`](../MiseKit) (local path)
- [`DevContainerKit`](../DevContainerKit) (local path)

## Development

```bash
mise install   # pinned swift-format and SwiftLint
make build     # swift build
make test      # swift test (Swift Testing)
make lint      # swift-format + SwiftLint, strict
```

This package builds, tests and lints on its own: it carries its own `Package.swift`, lint configuration and license, and reaches sibling packages only through `.package(path: "../<Sibling>")`.

## License

ScaffoldKit is available under the MIT license. See [LICENSE](LICENSE) for details.
