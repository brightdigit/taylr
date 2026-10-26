// swift-tools-version: 6.2

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "GitHubActionsKit",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "GitHubActionsKit", targets: ["GitHubActionsKit"])
  ],
  targets: [
    .target(
      name: "GitHubActionsKit",
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "GitHubActionsKitTests",
      dependencies: ["GitHubActionsKit"],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
