// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "TemplateGenerator",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(path: "../../SyntaxKit"),
  ],
  targets: [
    .executableTarget(
      name: "TemplateGenerator",
      dependencies: [
        .product(name: "SyntaxKit", package: "SyntaxKit"),
      ]
    ),
    .testTarget(
      name: "TemplateGeneratorTests",
      dependencies: [
        "TemplateGenerator",
        .product(name: "SyntaxKit", package: "SyntaxKit"),
      ]
    ),
  ]
)
