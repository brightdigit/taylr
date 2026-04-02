// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "{{TEMPLATE_APP_NAME}}App",
  platforms: [.macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26), .visionOS(.v26)],
  products: [
    .library(name: "{{TEMPLATE_APP_NAME}}App", targets: ["{{TEMPLATE_APP_NAME}}App"]),
  ],
  dependencies: [
    .package(path: "../{{TEMPLATE_APP_NAME}}Kit"),
  ],
  targets: [
    .target(
      name: "{{TEMPLATE_APP_NAME}}App",
      dependencies: [.product(name: "{{TEMPLATE_APP_NAME}}Kit", package: "{{TEMPLATE_APP_NAME}}Kit")]
    ),
  ]
)
