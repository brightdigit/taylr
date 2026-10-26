# LintKit

[![SwiftPM](https://img.shields.io/badge/SPM-macOS%20%7C%20Linux-success?logo=swift)](https://swift.org)
[![Swift](https://img.shields.io/badge/swift-6.2%2B-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

A shared protocol for lint tools (an encodable configuration, a mise tool name, a fix/strict runner and a parser to a common `Diagnostic`), with one product per tool.

> [!NOTE]
> LintKit is in development as part of [taylr](https://github.com/brightdigit/taylr) and lives in `taylr/Packages/LintKit` until it moves to its own repository. Right now it holds only a placeholder; real types arrive in a later phase of taylr's implementation plan.

## Requirements

- Swift 6.2 or later (the toolchain is pinned in `.mise.toml`)
- macOS 26 or Linux

## Development

```bash
mise install   # pinned swift-format and SwiftLint
make build     # swift build
make test      # swift test (Swift Testing)
make lint      # swift-format + SwiftLint, strict
```

This package builds, tests and lints on its own: it carries its own `Package.swift`, lint configuration and license, and reaches sibling packages only through `.package(path: "../<Sibling>")`.

## License

LintKit is available under the MIT license. See [LICENSE](LICENSE) for details.
