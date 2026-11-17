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
  name: "{{TEMPLATE_APP_NAME}}Kit",
  defaultLocalization: "en",
  // Non-full-stack (default): Kit and App targets are merged in this single package.
  // Full-stack mode: setup.sh splits App into a separate Packages/{{TEMPLATE_APP_NAME}}App package.
  platforms: [
    .macOS(.v26),
    .iOS(.v26),
    .tvOS(.v26),
    .watchOS(.v26),
    .visionOS(.v26)
  ],
  products: [
    .library(
      name: "{{TEMPLATE_APP_NAME}}Kit",
      targets: ["{{TEMPLATE_APP_NAME}}Kit"]
    ),
    .library(
      name: "{{TEMPLATE_APP_NAME}}App",
      targets: ["{{TEMPLATE_APP_NAME}}App"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "{{TEMPLATE_APP_NAME}}Kit"
    ),
    .target(
      name: "{{TEMPLATE_APP_NAME}}App",
      dependencies: ["{{TEMPLATE_APP_NAME}}Kit"]
    ),
    .testTarget(
      name: "{{TEMPLATE_APP_NAME}}KitTests",
      dependencies: ["{{TEMPLATE_APP_NAME}}Kit"]
    ),
  ]
)
