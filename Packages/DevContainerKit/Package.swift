// swift-tools-version: 6.2

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "DevContainerKit",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .library(name: "DevContainerKit", targets: ["DevContainerKit"])
  ],
  targets: [
    .target(
      name: "DevContainerKit",
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "DevContainerKitTests",
      dependencies: ["DevContainerKit"],
      swiftSettings: swiftSettings
    ),
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
