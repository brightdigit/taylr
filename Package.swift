// swift-tools-version: 6.2

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "taylr",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "TaylrDescription", targets: ["TaylrDescription"]),
    .executable(name: "taylr", targets: ["taylr"]),
  ],
  dependencies: [
    // Local packages, each a complete package that can later move to its own
    // repository with `git subrepo` and a `url:` dependency here.
    .package(path: "Packages/ScaffoldKit"),
    .package(path: "Packages/GitHubActionsKit"),
    .package(path: "Packages/LintKit"),
    .package(path: "Packages/MiseKit"),
    .package(path: "Packages/DevContainerKit"),
    .package(path: "Packages/XcodePilot"),
  ],
  targets: [
    // The only module Manifest.swift imports: Foundation only, no dependencies.
    .target(
      name: "TaylrDescription",
      swiftSettings: swiftSettings
    ),
    .target(
      name: "TaylrKit",
      dependencies: [
        "TaylrDescription",
        .product(name: "ScaffoldKit", package: "ScaffoldKit"),
        .product(name: "GitHubActionsKit", package: "GitHubActionsKit"),
        .product(name: "LintKit", package: "LintKit"),
        .product(name: "MiseKit", package: "MiseKit"),
        .product(name: "DevContainerKit", package: "DevContainerKit"),
        // ScriptingBridge is macOS-only.
        .product(
          name: "XcodePilot",
          package: "XcodePilot",
          condition: .when(platforms: [.macOS])
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .executableTarget(
      name: "taylr",
      dependencies: ["TaylrKit"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "TaylrDescriptionTests",
      dependencies: ["TaylrDescription"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "TaylrKitTests",
      dependencies: ["TaylrKit"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "taylrTests",
      dependencies: ["taylr"],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
