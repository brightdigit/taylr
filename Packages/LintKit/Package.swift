// swift-tools-version: 6.4

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "LintKit",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "LintKit", targets: ["LintKit"])
  ],
  targets: [
    .target(
      name: "LintKit",
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "LintKitTests",
      dependencies: ["LintKit"],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
