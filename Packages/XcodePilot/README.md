# XcodePilot

[![SwiftPM](https://img.shields.io/badge/SPM-macOS%20%7C%20Linux-success?logo=swift)](https://swift.org)
[![Swift](https://img.shields.io/badge/swift-6.4-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Drives a running Xcode from Swift through Xcode's AppleScript scripting dictionary: open a workspace, wait for a scheme to load, resolve a run destination, then build, debug or test.

> [!NOTE]
> XcodePilot is in development as part of [taylr](https://github.com/brightdigit/taylr) and lives in `taylr/Packages/XcodePilot` until it moves to its own repository. It was copied from [Swoop](https://github.com/brightdigit/Swoop), which taylr supersedes. taylr 1.0 uses it only so `taylr project generate` can open the workspace and wait for the scheme to load.

## How it works: `@objc` protocols over ScriptingBridge

Apple's usual route to scripting an app from Swift or Objective-C is to run `sdef` and `sdp` over the app to generate an Objective-C header, then import that header through a bridging header. XcodePilot skips the generated header. The `XcodeScriptingBridge` target declares Xcode's scripting dictionary by hand as Swift protocols:

```swift
@objc package protocol XcodeWorkspaceDocument: XcodeDocument, SBObjectProtocol {
  @objc optional var schemes: SBElementArray { get }
  @objc optional var file: URL { get }
}

extension SBObject: XcodeWorkspaceDocument {}
```

Every requirement is `@objc optional`, so a protocol is only a description of messages Xcode understands: nothing is implemented in Swift. `SBApplication` and `SBObject` are declared to conform, and calls such as `document.schemes?.object(withName:)` become Objective-C messages that ScriptingBridge turns into Apple events sent to Xcode. If Xcode's dictionary drops a command, the optional call returns `nil` rather than crashing.

This keeps the package pure SwiftPM, with no generated files, no bridging header and no Objective-C target. The protocols are `package`-scoped, so callers only see the small Swift API in the `XcodePilot` target:

- `XcodeApp` connects to an Xcode by path and opens a workspace or project.
- `XcodeWorkspaceDocument.debug(scheme:runDestination:...)` waits for the scheme, resolves the destination and starts a debug session.
- `RunDestination` describes where to run by platform plus architecture, OS version or device name.

Run destinations come from `xcodebuild -showdestinations`, run with [swift-subprocess](https://github.com/swiftlang/swift-subprocess) and parsed by the internal `Destination` type, which is covered by tests against a sample of that output.

## Requirements

- macOS 26 with Xcode installed; the first call asks for permission to control Xcode (Automation in System Settings › Privacy & Security)
- Swift 6.4 (pinned in `.swift-version`)

ScriptingBridge exists only on macOS. On other platforms the Xcode-driving types compile out (`#if canImport(ScriptingBridge)`), which leaves the destination parser, so the package builds everywhere and its parser tests run on Linux too. taylr's CI builds and tests it on macOS and Linux.

## Development

```bash
mise install   # pinned swift-format and SwiftLint
make build     # swift build
make test      # swift test (Swift Testing)
make lint      # swift-format + SwiftLint, strict
```

## License

XcodePilot is available under the MIT license. See [LICENSE](LICENSE) for details.
