# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

This is **{{TEMPLATE_APP_NAME}}**, a Swift application built for Apple platforms using the [Swift App Template](https://github.com/brightdigit/Swift-App-Template) infrastructure.

## Template Customization Guide

> **First 5 files to touch after `setup.sh`:**
> 1. `Packages/{{TEMPLATE_PACKAGE_NAME}}/Sources/{{TEMPLATE_PACKAGE_NAME}}/AppModel.swift` — replace skeleton with your domain model
> 2. `Packages/{{TEMPLATE_PACKAGE_NAME}}/Tests/{{TEMPLATE_PACKAGE_NAME}}Tests/AppModelTests.swift` — replace skeleton tests
> 3. `Packages/{{TEMPLATE_APP_NAME}}App/Sources/{{TEMPLATE_APP_NAME}}App/Views/PrimaryView.swift` — replace placeholder UI
> 4. `fastlane/metadata/en-US/name.txt` — your app's display name
> 5. `Resources/AppIcon.icon/` — replace with your real app icon

## Project Configuration

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
| **Platform** | {{TEMPLATE_FASTLANE_PLATFORM}} (fastlane), {{TEMPLATE_PRODUCE_PLATFORM}} (produce) |
| **Test Destination** | {{TEMPLATE_TEST_DESTINATION}} |
| **Build Artifact** | .{{TEMPLATE_BUILD_ARTIFACT_EXT}} |
| **Certificates Repo** | {{TEMPLATE_CERTS_REPO}} |

## Architecture

This project uses a **two-package architecture**:

```
Packages/
├── {{TEMPLATE_PACKAGE_NAME}}/          # Cross-platform business logic (SPM package)
│   ├── Sources/{{TEMPLATE_PACKAGE_NAME}}/
│   │   ├── AppModel.swift              # @Observable AppModel with actor pattern
│   │   └── UserDefaults.swift
│   └── Tests/{{TEMPLATE_PACKAGE_NAME}}Tests/
│       ├── AppModelTests.swift
│       └── TestHelpers/Platform.swift
└── {{TEMPLATE_APP_NAME}}App/           # SwiftUI app (depends on Kit) (SPM package)
    └── Sources/{{TEMPLATE_APP_NAME}}App/
        ├── {{TEMPLATE_APP_NAME}}App.swift   # @main entry point
        └── Views/
```

### Key Architectural Decisions

- **Tuist** manages Xcode project generation (`Project.swift`). Never edit `.xcodeproj` directly — it's generated and not committed to version control.
- **Two packages**: `{{TEMPLATE_PACKAGE_NAME}}` (pure Swift, cross-platform) and `{{TEMPLATE_APP_NAME}}App` (SwiftUI, Apple platforms only). Tests live in `{{TEMPLATE_PACKAGE_NAME}}`.
- **Swift 6.2** with `SWIFT_STRICT_CONCURRENCY = complete` — all concurrency violations are compiler errors.
- **Manual code signing** via Fastlane Match — certificates stored in `{{TEMPLATE_CERTS_REPO}}`.
- **`mise`** manages tool versions (tuist, swiftlint, swift-format, ruby, etc.) — see `.mise.toml`.

## Commands

```bash
# Generate Xcode project (auto-fix linting mode)
make generate
# or: mise exec -- tuist generate

# Generate with strict linting (matches CI)
make generate-strict
# or: TUIST_LINT_MODE=STRICT mise exec -- tuist generate

# Run linting (auto-fix in dev, strict in CI)
make lint
# or: ./Scripts/lint.sh
# CI strict mode: CI=true LINT_MODE=STRICT ./Scripts/lint.sh

# Test the Kit package (primary test target)
swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}

# Certificate management
make certs                     # sync all certificates (dev + App Store)
make certs-dev                 # development certificates only
make certs-appstore            # App Store certificates only
make certs-regenerate          # force regenerate all profiles (after adding capabilities)
make certs-regenerate-dev      # force regenerate development profiles
make certs-regenerate-appstore # force regenerate App Store profiles

# App Store submission
make beta                       # build and upload to TestFlight
make screenshots-all            # capture and frame App Store screenshots (iOS/tvOS/watchOS only)
fastlane upload_privacy_details # upload App Privacy nutrition labels
```

### Versioning

`Config/Version.xcconfig` is written only by `Scripts/update-version.sh`. A `BETA_BASE_BUILD`
line marks a beta build (displayed as `X.Y.Z beta N`, where N = build − base); removing it marks
a production release. CI manages this automatically — see the `production_release` input on the
app workflow.

```bash
./Scripts/update-version.sh 1.2.0      # set marketing version (build → 1), keeps beta state
./Scripts/update-version.sh --increment # bump build number, keeps beta state
./Scripts/update-version.sh --beta 12   # mark as beta counting from build 12
./Scripts/update-version.sh --release   # drop the beta line (production)
fastlane sync_build_number              # set build to latest TestFlight build + 1
```

## Swift Testing Conventions

All test code uses **Swift Testing only** (no XCTest).

### Suite Structure

- **< 10 tests**: single `@Suite struct` in one file
- **≥ 10 tests or multiple categories**: parent `enum` + per-category extension files

```swift
// AppModelTests.swift — parent enum carries "Tests" suffix; child structs do not
@Suite("App Model")
internal enum AppModelTests {}

// AppModelTests+Initialization.swift
extension AppModelTests {
  @Suite("Initialization")
  internal struct Initialization { ... }
}
```

File name mirrors the types: `AppModelTests+Initialization.swift`, never `AppModelTests+InitializationTests.swift`.

### Test Data and Assertions

```swift
private static let initialCount = 0

@Test("Initial count is zero")
internal func initialCount() {
  #expect(Self.initialCount == 0)  // always private static let, accessed via Self.
}
```

Use `#expect()` and `try #require()`. Never `XCTAssert*`.

### Platform-Conditional Tests

`TestHelpers/Platform.swift` provides a `Platform` enum. Apply via `.enabled(if: Platform.isMacOS)` on `@Suite` or `@Test` — prefer suite-level so the condition is declared once.

Example:

```swift
@Suite("macOS-specific features", .enabled(if: Platform.isMacOS))
internal struct MacOSFeatures {
  @Test("Menu bar integration")
  internal func menuBarIntegration() { ... }
}
```

### MARK Order in Test Files

```swift
// MARK: - Test Data Setup
// MARK: - Initialization Tests
// MARK: - Functional Tests
// MARK: - Error Handling Tests
// MARK: - Edge Cases
```

### Test File Organization

- **Small suites (< 10 tests):** Single file with one `@Suite struct`
- **Large suites (≥ 10 tests):** Parent enum in main file, categories in extension files

Example (large suite):

```
Tests/
├── AppModelTests.swift                    # Parent enum only
├── AppModelTests+Initialization.swift     # Initialization tests
├── AppModelTests+StateManagement.swift    # State management tests
└── AppModelTests+ErrorHandling.swift      # Error handling tests
```

### Test Naming Conventions

- **Suite names:** Descriptive phrases (e.g., "App Model", "User Preferences")
- **Test function names:** Lowercase, descriptive (e.g., `initialCountIsZero`, `savesPreferencesToDisk`)
- **Test descriptions:** Sentence case, readable (e.g., "Initial count is zero")

### Async Tests

Use `async` test functions when testing asynchronous code:

```swift
@Test("Fetches data from network")
internal func fetchesDataFromNetwork() async throws {
  let data = try await networkService.fetchData()
  #expect(data.isEmpty == false)
}
```

### Parameterized Tests

Use `@Test(arguments:)` for data-driven tests:

```swift
@Test("Validates email formats", arguments: [
  "user@example.com",
  "test+tag@domain.co.uk",
  "name.surname@subdomain.example.org"
])
internal func validatesEmailFormats(email: String) {
  #expect(EmailValidator.isValid(email))
}
```

## SwiftUI Patterns

Platform-specific view logic goes in a `private extension` of the view itself — not in a global `View` extension:

```swift
internal struct MyView: View {
  internal var body: some View {
    VStack(alignment: alignment) { ... }
  }
}

private extension MyView {
  var alignment: HorizontalAlignment {
    #if os(watchOS)
      .leading
    #else
      .center
    #endif
  }

  @ViewBuilder var iconView: some View {
    #if os(iOS)
      Image(systemName: "star.fill")
    #elseif os(macOS)
      Image(systemName: "star.circle.fill")
    #endif
  }
}
```

### View Organization

Properties first, then `init`, then computed properties, then methods:

```swift
internal struct ContentView: View {
  // MARK: - Properties
  @State private var counter: Int = 0
  private let title: String

  // MARK: - Initialization
  internal init(title: String) {
    self.title = title
  }

  // MARK: - Body
  internal var body: some View {
    VStack { ... }
  }

  // MARK: - Computed Properties
  private var formattedCounter: String {
    "\(counter)"
  }

  // MARK: - Methods
  private func incrementCounter() {
    counter += 1
  }
}
```

### Platform-Specific Modifiers

Use `#if` directives within private extensions:

```swift
private extension ContentView {
  @ViewBuilder var platformSpecificModifier: some View {
    #if os(macOS)
      body.frame(minWidth: 400, minHeight: 300)
    #elseif os(iOS)
      body.navigationBarTitleDisplayMode(.large)
    #endif
  }
}
```

## CI/CD Overview

`.github/workflows/app.yml` runs on every push and pull request:

1. **test-package-ubuntu** — Linux (Ubuntu, Swift 6.2), including WASM variants
2. **test-package-windows** — Windows 2022/2025
3. **test-package-android** — Android API 33/34
4. **test-package-macos** — macOS/iOS/tvOS/watchOS simulators
5. **build-app** — Tuist project generation + release build (depends on all test jobs)
6. **lint** — SwiftLint + swift-format strict mode
7. **fastlane** — TestFlight upload (main branch only, requires secrets)

### Linting Modes

- **Local (default):** Auto-fix mode — violations are automatically corrected
- **CI:** Strict mode — violations cause build failure

Match CI behavior locally:

```bash
make generate-strict
# or: TUIST_LINT_MODE=STRICT mise exec -- tuist generate
```

### GitHub Secrets Required

Configure these in repository settings:

- `CODECOV_TOKEN` — Code coverage reporting
- `MATCH_PASSWORD` — Decrypt Fastlane Match certificates
- `FASTLANE_KEYCHAIN_PASSWORD` — CI keychain password
- `APP_STORE_CONNECT_API_KEY_ID` — App Store Connect API key ID
- `APP_STORE_CONNECT_API_ISSUER_ID` — App Store Connect API issuer ID
- `APP_STORE_CONNECT_API_KEY_CONTENT` — App Store Connect API key (base64-encoded `.p8` file)
- `TUIST_CONFIG_TOKEN` — Tuist Cloud token (optional)

## Tuist Notes

- **Never edit `.xcodeproj` directly** — it's generated by Tuist and not committed to version control
- **Regenerate after dependency changes** — `make generate` or `mise exec -- tuist generate`
- **Lint modes:**
  - Default: auto-fix mode (`make generate`)
  - Strict: CI mode (`make generate-strict` or `TUIST_LINT_MODE=STRICT mise exec -- tuist generate`)
- **Project.swift is the source of truth** — all Xcode project configuration lives here

### Adding Dependencies

1. Edit `Project.swift` to add the dependency
2. Regenerate the project: `make generate`
3. Open the project: `open {{TEMPLATE_APP_NAME}}.xcodeproj`

### Modifying Build Settings

1. Edit `Project.swift` (search for `Settings.settings`)
2. Regenerate: `make generate`
3. Verify in Xcode

## Tool Version Management

All tools are managed by `mise` (declared in `.mise.toml`):

```bash
mise install        # Install all tools
mise list          # Show installed versions
mise exec -- tuist  # Run a tool from mise
```

Tools managed:
- **tuist** — Project generator
- **swiftlint** — Linting
- **swift-format** — Code formatting
- **ruby** — Fastlane runtime

Never install these tools globally — always use `mise exec` or the Makefile targets.

## Code Signing

This project uses **manual code signing** via Fastlane Match. Certificates and provisioning profiles are stored in:

```
{{TEMPLATE_CERTS_REPO}}
```

### Sync Certificates

```bash
make certs                     # All (development + App Store)
make certs-dev                 # Development only
make certs-appstore            # App Store only
make certs-regenerate          # Force regenerate all profiles (after adding capabilities)
make certs-regenerate-dev      # Force regenerate development profiles
make certs-regenerate-appstore # Force regenerate App Store profiles
```

### Match Password

The `MATCH_PASSWORD` environment variable (or GitHub secret) decrypts the certificates. Store this securely in:
- Local: `.env` file (not committed, see `.env.example`)
- CI: GitHub repository secret

## Actor-Based AppModel Pattern

The `AppModel.swift` follows the actor-based pattern from the template:

```swift
import Foundation
import Observation

@Observable
@MainActor
internal final class AppModel {
  // MARK: - Properties
  internal private(set) var isLoading: Bool = false

  // MARK: - Initialization
  internal init() {}

  // MARK: - Methods
  internal func performAction() async {
    isLoading = true
    defer { isLoading = false }

    // Async work here
    await Task.sleep(1_000_000_000)  // 1 second
  }
}
```

Key points:
- `@Observable` for SwiftUI integration
- `@MainActor` for UI-safe property access
- `private(set)` for read-only external access
- `async` methods for concurrent operations
- `defer` for cleanup logic

## File Organization

### Source Files

```swift
// MARK: - Imports
import Foundation
import SwiftUI

// MARK: - Type Definition
internal struct MyType {
  // MARK: - Properties
  // ...

  // MARK: - Initialization
  // ...

  // MARK: - Methods
  // ...
}

// MARK: - Extensions
extension MyType {
  // ...
}

// MARK: - Private Extensions
private extension MyType {
  // ...
}
```

### Test Files

```swift
// MARK: - Imports
import Testing
@testable import {{TEMPLATE_PACKAGE_NAME}}

// MARK: - Test Suite
@Suite("My Feature")
internal enum MyFeatureTests {}

// MARK: - Test Data Setup
extension MyFeatureTests {
  private static let sampleData = "test"
}

// MARK: - Initialization Tests
extension MyFeatureTests {
  @Test("Creates instance")
  internal func createsInstance() {
    #expect(MyType() != nil)
  }
}
```

## Platform-Specific Code

Use `#if os()` directives for platform-specific implementations:

```swift
#if os(macOS)
  import AppKit
  typealias PlatformColor = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  typealias PlatformColor = UIColor
#endif

internal func getPrimaryColor() -> PlatformColor {
  #if os(macOS)
    return .systemBlue
  #else
    return .systemBlue
  #endif
}
```

For test-only platform detection, use `TestHelpers/Platform.swift`:

```swift
internal enum Platform {
  internal static var isMacOS: Bool {
    #if os(macOS)
      true
    #else
      false
    #endif
  }

  internal static var isIOS: Bool {
    #if os(iOS)
      true
    #else
      false
    #endif
  }

  // ... etc for other platforms
}
```

## Common Workflows

### Adding a New Feature

1. Create feature code in `Packages/{{TEMPLATE_PACKAGE_NAME}}/Sources/{{TEMPLATE_PACKAGE_NAME}}/`
2. Add tests in `Packages/{{TEMPLATE_PACKAGE_NAME}}/Tests/{{TEMPLATE_PACKAGE_NAME}}Tests/`
3. Run tests: `swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}`
4. Add UI in `Packages/{{TEMPLATE_APP_NAME}}App/Sources/{{TEMPLATE_APP_NAME}}App/Views/`
5. Regenerate project: `make generate`
6. Test in Xcode: `open {{TEMPLATE_APP_NAME}}.xcodeproj`

### Fixing a Bug

1. Write a failing test in `{{TEMPLATE_PACKAGE_NAME}}Tests/`
2. Run tests to confirm failure: `swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}`
3. Implement fix in `{{TEMPLATE_PACKAGE_NAME}}/Sources/`
4. Run tests to confirm fix: `swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}`
5. Commit with conventional commit message: `fix: description of bug fix`

### Deploying to TestFlight

1. Ensure all tests pass: `swift test --package-path Packages/{{TEMPLATE_PACKAGE_NAME}}`
2. Ensure linting passes: `make generate-strict`
3. Commit and push to `main` branch
4. CI will automatically deploy to TestFlight (if secrets configured)

Or deploy manually:

```bash
make beta
```

## Principles & Governance

### Design-First / HIG
Follow Apple Human Interface Guidelines. New UI components require design review before implementation.

### Apple Platform-Native Architecture
Use platform conventions: SwiftUI lifecycle, NavigationStack, scene-based state. Avoid cross-platform UI abstraction layers.

### SwiftUI-First
All UI in SwiftUI. AppKit/UIKit only for functionality unavailable in SwiftUI, wrapped in a SwiftUI view.

### Test-First
Write Swift Testing specs before implementation. Kit-layer logic must have passing tests before merging.

### Observable State Management
Single `AppModel` (or composable sub-models) using `@Observable`. No manual Combine pipelines for UI binding.

### MVVM
Views are pure functions of state. Business logic lives in AppModel or actor-backed services, not in views.

### Build Reproducibility
All tool versions pinned in `.mise.toml`. CI and local builds use the same tool versions.

### Simplicity & YAGNI
No abstraction without two concrete use cases. Three similar lines of code is better than a premature abstraction.

### Amendment Procedure
Architectural changes require updating this file first. Submit a PR with the CLAUDE.md change before the implementation PR.

## Links

- **Marketing:** [{{TEMPLATE_MARKETING_URL}}]({{TEMPLATE_MARKETING_URL}})
- **Privacy Policy:** [{{TEMPLATE_PRIVACY_URL}}]({{TEMPLATE_PRIVACY_URL}})
- **Support:** [{{TEMPLATE_SUPPORT_URL}}]({{TEMPLATE_SUPPORT_URL}})

## Additional Resources

- **Swift Testing Documentation:** [https://developer.apple.com/documentation/testing](https://developer.apple.com/documentation/testing)
- **Tuist Documentation:** [https://docs.tuist.io](https://docs.tuist.io)
- **Fastlane Documentation:** [https://docs.fastlane.tools](https://docs.fastlane.tools)
- **mise Documentation:** [https://mise.jdx.dev](https://mise.jdx.dev)
