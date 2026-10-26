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
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0"),
    // Kept within SyntaxKit's 0.x range so both resolve together in taylr.
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.4.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.0"),
    // Pinned exactly, as the spec asks for the prompt library.
    .package(url: "https://github.com/tuist/Noora.git", exact: "0.57.6"),
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
      ],
      swiftSettings: swiftSettings
    ),
    .executableTarget(
      name: "taylr",
      dependencies: [
        "TaylrKit",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
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
