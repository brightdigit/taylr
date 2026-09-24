// swift-tools-version: 6.3
//
//  Package.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import PackageDescription

// swiftlint:disable:next explicit_acl explicit_top_level_acl no_global_declarations
let package = Package(
  name: "{{TEMPLATE_APP_NAME}}Server",
  platforms: [.macOS(.v26)],
  dependencies: [
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-configuration.git", from: "1.0.0"),
    .package(path: "../{{TEMPLATE_APP_NAME}}Kit"),
  ],
  targets: [
    .executableTarget(
      name: "{{TEMPLATE_APP_NAME}}serverd",
      dependencies: [
        .target(name: "{{TEMPLATE_APP_NAME}}Server"),
      ]
    ),
    .target(
      name: "{{TEMPLATE_APP_NAME}}Server",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "{{TEMPLATE_APP_NAME}}Kit", package: "{{TEMPLATE_APP_NAME}}Kit"),
        .product(name: "Configuration", package: "swift-configuration"),
      ],
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
      ]
    ),
  ]
)
