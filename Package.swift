// swift-tools-version: 6.4

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
    .library(name: "TaylrKit", targets: ["TaylrKit"]),
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
    // Vendored with git subrepo from brightdigit/ConfigKeyKit (main); extend it there.
    .package(path: "Packages/ConfigKeyKit"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0"),
    // Kept within SyntaxKit's 0.x range so both resolve together in taylr.
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.4.0"),
    .package(
      url: "https://github.com/apple/swift-configuration.git",
      from: "1.3.0",
      traits: ["JSON", "CommandLineArguments", "YAML"]
    ),
    // Pinned exactly, as the spec asks for the prompt library.
    .package(url: "https://github.com/tuist/Noora.git", exact: "0.57.6"),
    // Only for `swift package generate-documentation`; no target links it, so
    // packages that depend on taylr never resolve it.
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
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
        .product(name: "XcodePilot", package: "XcodePilot"),
        .product(name: "Yams", package: "Yams"),
        .product(name: "Subprocess", package: "swift-subprocess"),
        .product(name: "Configuration", package: "swift-configuration"),
        .product(name: "ConfigKeyKit", package: "ConfigKeyKit"),
      ],
      swiftSettings: swiftSettings
    ),
    .executableTarget(
      name: "taylr",
      dependencies: [
        "TaylrKit",
        .product(name: "Configuration", package: "swift-configuration"),
        .product(name: "ConfigKeyKit", package: "ConfigKeyKit"),
        .product(name: "Noora", package: "Noora"),
      ],
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
