# Swift App Template

Production-ready infrastructure for building Swift apps across Apple platforms (macOS, iOS, tvOS, watchOS) — with Tuist project generation, Fastlane deployment, comprehensive CI/CD, and Claude Code integration.

## What's Included

This template provides battle-tested infrastructure extracted from real production apps:

- **🏗️ Tuist** — Declarative Xcode project generation with modular architecture
- **📦 Two-Package Architecture** — Cross-platform business logic (`*Kit`) + SwiftUI app (`*App`)
- **🚀 Fastlane** — Automated certificate management (Match) and TestFlight deployment
- **✅ CI/CD Across 7 Platforms** — GitHub Actions workflows for:
  - Ubuntu Linux (including WASM variants)
  - Windows (2022/2025)
  - Android (API 33/34)
  - macOS/iOS/tvOS/watchOS
- **🧪 Swift Testing** — Modern Swift Testing framework (no XCTest)
- **🔍 Linting** — SwiftLint + swift-format with auto-fix and strict CI modes
- **🤖 Claude Code Integration** — GitHub workflows for AI-assisted development
- **🔧 Tool Version Management** — mise handles all toolchain versions
- **📝 Comprehensive Documentation** — CLAUDE.md for AI agents, README for humans

## Quick Start

### 1. Use This Template

Click the **"Use this template"** button at the top of this repository, or clone it:

```bash
git clone https://github.com/brightdigit/Swift-App-Template.git MyAwesomeApp
cd MyAwesomeApp
```

### 2. Run Setup Script

The setup script will guide you through configuration:

```bash
./Scripts/setup.sh
```

You'll be prompted for:
- App name (e.g., `WeatherBar`)
- Apple Team ID (10-character alphanumeric)
- Apple ID email
- App Store Connect Team ID
- Organization name
- GitHub organization/username
- Certificate repository URL
- Swift package name (defaults to `{AppName}Kit`)
- Copyright year
- Marketing/privacy/support URLs
- Whether to include a server package (Hummingbird-based, optional)

### 3. Generate Xcode Project

```bash
mise install      # Install toolchain dependencies
mise exec -- tuist generate
```

### 4. Open in Xcode

```bash
open YourAppName.xcodeproj
```

## Automated Setup

For non-interactive setup (CI, scripting), pass all configuration via flags:

```bash
./Scripts/setup.sh \
  --app-name WeatherBar \
  --team-id ABC1234567 \
  --apple-id dev@example.com \
  --itc-team-id 123456789 \
  --org-name "Acme Corp" \
  --github-org acme \
  --certs-repo git@github.com:acme/WeatherBarCerts.git \
  --package-name WeatherBarKit \
  --year 2026 \
  --marketing-url https://weatherbar.app \
  --privacy-url https://weatherbar.app/privacy \
  --support-url https://weatherbar.app/support \
  <<< "y"
```

Add `--server --server-port 8080` for full-stack mode with Hummingbird server.

## What `setup.sh` Does

The setup script transforms this template into your configured project:

1. **Token Replacement** — Replaces all `{{TEMPLATE_*}}` placeholders with your values
2. **Directory Renaming** — Renames `Packages/{{TEMPLATE_APP_NAME}}Kit/` → `Packages/YourAppKit/`
3. **Swift File Generation** — Uses TemplateGenerator to create syntactically valid Swift files
4. **CI Activation** — Uncomments `.github/workflows/app.yml` to enable GitHub Actions
5. **Full-Stack Mode** — Keeps or removes server package based on your choice
6. **Cleanup** — Removes template-only files (`TemplateGenerator`, `_reference/`, `.claude/`)
7. **Documentation** — Renames `README.template.md` → `README.md` (with your values)
8. **Git Reset** — Removes template origin, stages changes for your first commit

## Repository Structure (After Setup)

```
YourApp/
├── Packages/
│   ├── YourAppKit/                    # Cross-platform business logic (SPM)
│   │   ├── Sources/YourAppKit/
│   │   │   ├── AppModel.swift         # @Observable model with actor pattern
│   │   │   └── UserDefaults.swift
│   │   └── Tests/YourAppKitTests/
│   │       ├── AppModelTests.swift
│   │       └── TestHelpers/Platform.swift
│   ├── YourAppApp/                    # SwiftUI app (depends on Kit)
│   │   └── Sources/YourAppApp/
│   │       ├── YourAppApp.swift       # @main entry point
│   │       └── Views/
│   └── YourAppServer/                 # Optional: Hummingbird server (full-stack)
├── Project.swift                      # Tuist manifest
├── Scripts/
│   ├── setup.sh                       # This script (can be deleted after use)
│   └── lint.sh                        # SwiftLint + swift-format runner
├── fastlane/                          # Certificate + TestFlight automation
├── .github/workflows/
│   ├── app.yml                        # Main CI/CD workflow (7 platforms)
│   ├── claude.yml                     # Claude Code GitHub integration
│   └── claude-code-review.yml         # Automatic PR reviews
├── .mise.toml                         # Tool version manifest
├── Makefile                           # Common development commands
├── README.md                          # This file (will be replaced)
└── CLAUDE.md                          # AI agent guidelines (will be replaced)
```

The Xcode project (`.xcodeproj`) is generated by Tuist and is **not committed** to version control.

## Requirements

- **macOS** 14.0+ (Sonoma or later)
- **Xcode** 16.0+ (for Swift 6.2+)
- **mise** — Tool version manager ([installation](https://mise.jdx.dev/getting-started.html))
- **Apple Developer Account** — Required for code signing and TestFlight deployment
- **GitHub Account** — For CI/CD workflows

## Reference Projects

This template's infrastructure is extracted from:

| Project | Role | Location (Temporary) |
|---------|------|----------------------|
| **MonthBar** | Primary source — all infrastructure patterns | `_reference/MonthBar/` |
| **Bitness** | Full-stack reference — server package architecture | `_reference/Bitness/` |

⚠️ **Note:** The `_reference/` directory is removed by `setup.sh` and will be scrubbed from git history before public release.

## Development Commands (After Setup)

```bash
# Generate Xcode project (auto-fix linting mode)
make generate

# Generate with strict linting (matches CI)
make generate-strict

# Run linting
make lint

# Test the Kit package (primary test target)
swift test --package-path Packages/YourAppKit

# Certificate management
make certs          # Sync all certificates
make certs-dev      # Development certificates only

# TestFlight deployment
make beta           # Build and upload to TestFlight
```

## Architecture Decisions

Key patterns from the reference projects:

- **Manual Code Signing** — Uses Fastlane Match to store certificates in a separate private repository
- **Swift 6.2 Strict Concurrency** — `SWIFT_STRICT_CONCURRENCY = complete` for data race safety
- **Actor-Based AppModel** — `@Observable` model with `@MainActor` for SwiftUI integration
- **Platform-Conditional Tests** — Via `TestHelpers/Platform.swift` and `.enabled(if:)` traits
- **No XCTest** — Swift Testing only (modern, expressive, compiler-integrated)
- **Tuist-Generated Projects** — Never edit `.xcodeproj` directly; regenerate after changes

## CI/CD GitHub Secrets

Required secrets for full CI/CD functionality:

| Secret Name | Purpose |
|-------------|---------|
| `CODECOV_TOKEN` | Code coverage reporting |
| `MATCH_PASSWORD` | Decrypt Fastlane Match certificates |
| `FASTLANE_KEYCHAIN_PASSWORD` | CI keychain password |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect API issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | App Store Connect API key (base64-encoded) |
| `TUIST_CONFIG_TOKEN` | Tuist Cloud token (optional) |

## Full-Stack Mode (Optional)

If you chose to include the server package during setup:

- **Server Package:** `Packages/YourAppServer/`
- **Entry Point:** `Sources/yourappd/main.swift` (lowercase daemon name)
- **Framework:** Hummingbird 2.x with Swift OpenAPI Generator
- **Dockerfile:** Multi-stage build with Swift 6.2
- **Port:** Configured via `--server-port` flag (default: 8080)

Client-only mode removes the server package and Dockerfile entirely.

## Contributing to the Template

This repository itself (the template) is under active development. Contributions welcome!

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-improvement`)
3. Make your changes (test with `./Scripts/setup.sh` in a temporary directory)
4. Commit with conventional commits (`feat:`, `fix:`, `docs:`, etc.)
5. Push and open a pull request

## License

MIT License - Copyright (c) 2026

See [LICENSE](LICENSE) for details.

## Support

- **Issues:** [GitHub Issues](https://github.com/brightdigit/Swift-App-Template/issues)
- **Discussions:** [GitHub Discussions](https://github.com/brightdigit/Swift-App-Template/discussions)
- **Documentation:** See `CLAUDE.md` for comprehensive development guidelines

---

**Built with ❤️ for the Swift community**
