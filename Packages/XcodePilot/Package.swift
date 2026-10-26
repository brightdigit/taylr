// swift-tools-version: 6.2

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "XcodePilot",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "XcodePilot", targets: ["XcodePilot"])
  ],
  dependencies: [
    // Kept within SyntaxKit's 0.x range so both resolve together in taylr.
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.4.0")
  ],
  targets: [
    .target(
      name: "XcodeScriptingBridge",
      swiftSettings: swiftSettings
    ),
    .target(
      name: "XcodePilot",
      dependencies: [
        "XcodeScriptingBridge",
        .product(name: "Subprocess", package: "swift-subprocess"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XcodePilotTests",
      dependencies: ["XcodePilot"],
      resources: [
        .copy("Fixtures")
      ],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
