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
  dependencies: [
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0"),
    // Kept within SyntaxKit's 0.x range so both resolve together in taylr.
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.4.0"),
  ],
  targets: [
    .target(
      name: "LintKit",
      dependencies: [
        .product(name: "Yams", package: "Yams"),
        .product(name: "Subprocess", package: "swift-subprocess"),
      ],
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
