// swift-tools-version: 6.4

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "MiseKit",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "MiseKit", targets: ["MiseKit"])
  ],
  targets: [
    .target(
      name: "MiseKit",
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "MiseKitTests",
      dependencies: ["MiseKit"],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
