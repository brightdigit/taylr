# {{TEMPLATE_APP_NAME}}

Built with [Swift App Template](https://github.com/brightdigit/Swift-App-Template) — production-ready infrastructure for Swift apps.

## Overview

{{TEMPLATE_APP_NAME}} is a Swift application built for Apple platforms using modern tooling and best practices:

- **Tuist** for declarative Xcode project generation
- **Two-package architecture** — `{{TEMPLATE_PACKAGE_NAME}}` (business logic) + `{{TEMPLATE_APP_NAME}}App` (SwiftUI)
- **Swift 6.3** language mode with strict concurrency checking (CI toolchains on Swift 6.4)
- **Swift Testing** framework (XCTest only for UI/screenshot tests)
- **Fastlane** for certificate management and TestFlight deployment
- **Comprehensive CI/CD** across 7 platforms via GitHub Actions

## Requirements

- **macOS** 14.0+ (Sonoma or later)
- **Xcode** 26.4+ (Swift 6.3+)
- **mise** — Tool version manager ([installation](https://mise.jdx.dev/getting-started.html))
- **Apple Developer Account** — For code signing and App Store deployment

## Getting Started

### 1. Install Dependencies

All tool versions are managed by mise:

```bash
mise install
```

This installs:
- Tuist (project generator)
- SwiftLint (linting)
- swift-format (code formatting)
- Ruby (Fastlane runtime)
- uv (Python runner for `make icons`)

Then install fastlane:

```bash
bundle install
```

**Dev container:** `.devcontainer/devcontainer.json` (Swift 6.4) builds and tests the packages on Linux. Your `~/.ssh` is mounted read-only so private SwiftPM dependencies resolve.

### 2. Generate Xcode Project

```bash
mise exec -- tuist generate
```

Or use the Makefile shortcut:

```bash
make generate
```

This generates `{{TEMPLATE_APP_NAME}}.xcodeproj` from `Project.swift`.

⚠️ **Important:** The `.xcodeproj` file is generated and not committed to version control. Always use Tuist to regenerate after dependency changes.

### 3. Open in Xcode

```bash
open {{TEMPLATE_APP_NAME}}.xcodeproj
```

## Development Commands

All common workflows are available via `make`:

```bash
# Generate Xcode project (auto-fix linting mode)
make generate

# Generate with strict linting (matches CI behavior)
make generate-strict

# Run linting (SwiftLint + swift-format)
make lint

# Sync all certificates (development + distribution)
make certs

# Sync development certificates only
make certs-dev

# Build and upload to TestFlight
make beta
```

### Testing

The primary test target is the Kit package:

```bash
swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}
```

All tests use **Swift Testing** (not XCTest). See `CLAUDE.md` for testing conventions.

## Project Architecture

```
{{TEMPLATE_APP_NAME}}/
├── Packages/
│   ├── {{TEMPLATE_PACKAGE_NAME}}/              # Cross-platform business logic
│   │   ├── Sources/{{TEMPLATE_PACKAGE_NAME}}/
│   │   │   ├── AppModel.swift                  # @Observable model (actor pattern)
│   │   │   └── UserDefaults.swift
│   │   └── Tests/{{TEMPLATE_PACKAGE_NAME}}Tests/
│   │       ├── AppModelTests.swift
│   │       └── TestHelpers/Platform.swift
│   └── {{TEMPLATE_APP_NAME}}App/               # SwiftUI app (depends on Kit)
│       └── Sources/{{TEMPLATE_APP_NAME}}App/
│           ├── {{TEMPLATE_APP_NAME}}App.swift  # @main entry point
│           └── Views/
├── Project.swift                                # Tuist manifest
├── Scripts/
│   └── lint.sh                                  # Linting automation
├── fastlane/                                    # Certificate + deployment automation
├── .github/workflows/
│   ├── app.yml                                  # Main CI/CD pipeline
│   ├── claude.yml                               # Claude Code GitHub integration
│   └── claude-code-review.yml                   # Automatic PR reviews
└── .mise.toml                                   # Tool version manifest
```

### Package Responsibilities

| Package | Purpose | Platforms |
|---------|---------|-----------|
| `{{TEMPLATE_PACKAGE_NAME}}` | Business logic, models, data layer | All (Linux, Windows, Android, Apple) |
| `{{TEMPLATE_APP_NAME}}App` | SwiftUI views, app lifecycle | Apple platforms only |

The Kit package is **platform-agnostic** and tested on all platforms in CI. The App package depends on the Kit and adds SwiftUI + platform-specific UI.

## CI/CD Pipeline

`.github/workflows/app.yml` runs on every push and pull request:

| Job | Platform | Description |
|-----|----------|-------------|
| `build-ubuntu` | `swift:6.4` (noble/jammy) | Linux + WASM variants |
| `build-windows` | Windows 2025, Swift 6.4 | Windows compatibility (cross-platform PRs) |
| `build-android` | Android API 34, Swift 6.4 | Android cross-compilation (cross-platform PRs) |
| `build-macos` / `build-macos-platforms` | self-hosted macOS | SPM + Apple platform simulators |
| `lint` | Ubuntu | SwiftLint + swift-format (strict mode) |
| `fastlane` | self-hosted macOS | Release build; TestFlight upload + build-number commit on `main` |

Draft pull requests skip the workflow until they're marked ready for review.

### Other workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `app-store-metadata.yml` | manual | Sync App Store listing (metadata, screenshots, age rating, privacy label) without a build |
| `asc-session.yml` | weekly | Fail loudly when `FASTLANE_SESSION` expires |
| `cleanup-caches.yml` / `cleanup-pr-caches.yml` | branch delete / PR close | Delete stale Actions caches |
| `claude.yml` / `claude-code-review.yml` | `@claude` / non-draft PRs | Claude Code assistance and review |

### CI Linting vs Local Linting

- **Local (default):** Auto-fix mode — linting violations are automatically corrected
- **CI:** Strict mode — linting violations cause build failure

Match CI behavior locally:

```bash
make generate-strict
# or: TUIST_LINT_MODE=STRICT mise exec -- tuist generate
```

## GitHub Secrets (Required for CI/CD)

Configure these secrets in your repository settings for full CI/CD functionality:

| Secret Name | Purpose | How to Obtain |
|-------------|---------|---------------|
| `CODECOV_TOKEN` | Code coverage reporting | [codecov.io](https://codecov.io) |
| `MATCH_PASSWORD` | Decrypt Fastlane Match certificates | Choose a strong password |
| `FASTLANE_KEYCHAIN_PASSWORD` | CI keychain password | Choose a strong password |
| `APP_STORE_CONNECT_API_KEY_KEY_ID` | App Store Connect API | [Create API key](https://appstoreconnect.apple.com/access/api) |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | App Store Connect API issuer | From API key creation page |
| `APP_STORE_CONNECT_API_KEY_KEY` | App Store Connect API key file | Base64-encode your `.p8` file |
| `FASTLANE_SESSION` | App Privacy label upload (Apple ID session — the API key can't do it) | `bundle exec fastlane spaceauth -u {{TEMPLATE_APPLE_ID}}`; renew ~monthly |
| `TUIST_CONFIG_TOKEN` | Tuist Cloud token (optional) | [Tuist Cloud dashboard](https://cloud.tuist.io) |

### Base64-Encoding the API Key

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

Paste the clipboard contents into the `APP_STORE_CONNECT_API_KEY_KEY` secret.

## App Store Deployment

### Initial Setup

Before the first deployment, create the app in App Store Connect:

```bash
bundle exec fastlane produce \
  --app_identifier {{TEMPLATE_BUNDLE_ID}} \
  --app_name "{{TEMPLATE_APP_NAME}}" \
  --team_id {{TEMPLATE_TEAM_ID}} \
  --itc_team_id {{TEMPLATE_ITC_TEAM_ID}} \
  --platform {{TEMPLATE_PRODUCE_PLATFORM}}
```

This only needs to be done once.

### Deploy to TestFlight

```bash
make beta
```

Or manually:

```bash
bundle exec fastlane beta
```

This will:
1. Sync certificates via Fastlane Match
2. Build the release artifact ({{TEMPLATE_BUILD_ARTIFACT_EXT}})
3. Upload to TestFlight with the notes in `fastlane/changelog.txt`

Metadata is synced separately (`make sync-app-store` or the App Store Metadata workflow) so a locked App Store version can't fail a binary upload.

### Automatic Deployment

The `fastlane` job in `.github/workflows/app.yml` automatically deploys to TestFlight when:
- The commit is on the `main` branch
- All tests pass
- All required secrets are configured

After a successful upload, CI sets the build number to the latest TestFlight build + 1 and commits `Config/Version.xcconfig` back to `main` (`[ci skip]`).

### Beta vs Production Builds

Builds are betas while `Config/Version.xcconfig` contains a `BETA_BASE_BUILD` line (shown in-app as `1.0.0 beta N` via `VersionInfo.displayVersion`). To ship a production release, run the app workflow manually on `main` with **production_release** checked: CI drops the beta line, uploads, commits `chore: release build …`, then restores beta numbering for the next build.

## Configuration Summary

This project was configured with the following values:

| Setting | Value |
|---------|-------|
| **App Name** | {{TEMPLATE_APP_NAME}} |
| **Bundle ID** | {{TEMPLATE_BUNDLE_ID}} |
| **Team ID** | {{TEMPLATE_TEAM_ID}} |
| **App Group ID** | {{TEMPLATE_APP_GROUP_ID}} |
| **Apple ID** | {{TEMPLATE_APPLE_ID}} |
| **ITC Team ID** | {{TEMPLATE_ITC_TEAM_ID}} |
| **Organization** | {{TEMPLATE_ORG_NAME}} |
| **GitHub Org** | {{TEMPLATE_GITHUB_ORG}} |
| **Package Name** | {{TEMPLATE_PACKAGE_NAME}} |
| **Platform** | {{TEMPLATE_FASTLANE_PLATFORM}} |
| **Certificates Repo** | {{TEMPLATE_CERTS_REPO}} |

## Code Signing

This project uses **manual code signing** via Fastlane Match. Certificates and provisioning profiles are stored in a separate private repository:

```
{{TEMPLATE_CERTS_REPO}}
```

### Sync Certificates

```bash
make certs          # All certificates (development + distribution)
make certs-dev      # Development only
```

### Match Password

The `MATCH_PASSWORD` environment variable (or GitHub secret) decrypts the certificates. Store this securely — losing it means regenerating all certificates.

## Tool Version Management

All tool versions are declared in `.mise.toml` and automatically installed:

```bash
mise install        # Install all tools
mise list          # Show installed versions
mise exec -- tuist  # Run a tool from mise
```

Tools managed by mise:
- Tuist (project generator)
- SwiftLint (linting)
- swift-format (formatting)
- Ruby (Fastlane runtime)

## Linting

Linting runs automatically during `tuist generate` (auto-fix mode) and in CI (strict mode).

### Manual Linting

```bash
make lint
```

Or use the script directly:

```bash
./Scripts/lint.sh                     # Auto-fix mode
CI=true LINT_MODE=STRICT ./Scripts/lint.sh  # Strict mode (CI)
```

## Links

- **Marketing:** [{{TEMPLATE_MARKETING_URL}}]({{TEMPLATE_MARKETING_URL}})
- **Privacy Policy:** [{{TEMPLATE_PRIVACY_URL}}]({{TEMPLATE_PRIVACY_URL}})
- **Support:** [{{TEMPLATE_SUPPORT_URL}}]({{TEMPLATE_SUPPORT_URL}})

## Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Make your changes
3. Run tests: `swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}`
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}

See [LICENSE](LICENSE) for details.

---

**Built with [Swift App Template](https://github.com/brightdigit/Swift-App-Template)**
