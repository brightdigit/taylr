// swift-tools-version: 6.4

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
  dependencies: [
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0")
  ],
  targets: [
    .target(
      name: "GitHubActionsKit",
      dependencies: [
        .product(name: "Yams", package: "Yams")
      ],
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
