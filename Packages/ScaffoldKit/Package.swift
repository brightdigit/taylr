// swift-tools-version: 6.2

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "ScaffoldKit",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "ScaffoldKit", targets: ["ScaffoldKit"])
  ],
  dependencies: [
    .package(path: "../SyntaxKit"),
    .package(path: "../GitHubActionsKit"),
    .package(path: "../LintKit"),
    .package(path: "../MiseKit"),
    .package(path: "../DevContainerKit"),
  ],
  targets: [
    .target(
      name: "ScaffoldKit",
      dependencies: [
        .product(name: "SyntaxKit", package: "SyntaxKit"),
        .product(name: "GitHubActionsKit", package: "GitHubActionsKit"),
        .product(name: "LintKit", package: "LintKit"),
        .product(name: "MiseKit", package: "MiseKit"),
        .product(name: "DevContainerKit", package: "DevContainerKit"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "ScaffoldKitTests",
      dependencies: ["ScaffoldKit"],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
