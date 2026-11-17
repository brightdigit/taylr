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
  name: "{{TEMPLATE_APP_NAME}}App",
  defaultLocalization: "en",
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
