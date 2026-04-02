//
//  Project.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

internal let project = Project(
  name: "{{TEMPLATE_APP_NAME}}",
  // Non-full-stack (default): only Kit package is referenced here; App target is included
  // within Kit's Package.swift. Full-stack mode: setup.sh adds
  // .local(path: "./Packages/{{TEMPLATE_APP_NAME}}App") and removes App from Kit's package.
  packages: [
    .local(path: "./Packages/{{TEMPLATE_APP_NAME}}Kit")
  ],
  targets: [
    // Main app target
    .target(
      name: "{{TEMPLATE_APP_NAME}}",
      destinations: {{TEMPLATE_DESTINATIONS}},
      product: .app,
      bundleId: "{{TEMPLATE_BUNDLE_ID}}",
      deploymentTargets: {{TEMPLATE_DEPLOYMENT_TARGET}},
      infoPlist: .extendingDefault(
        with: [
          // Version info from xcconfig
          "CFBundleShortVersionString": "$(MARKETING_VERSION)",
          "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
          "NSHumanReadableCopyright": "Copyright © {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}",
          // Required for full-screen SwiftUI on iOS
          "UILaunchScreen": [:],
          // App uses only standard encryption (HTTPS)
          "ITSAppUsesNonExemptEncryption": false,
        ]
      ),
      sources: ["Sources/**"],
      resources: [
        "Resources/AppIcon.icon",
        "Resources/PrivacyInfo.xcprivacy",
      ],
      entitlements: .dictionary([
        "com.apple.security.application-groups": .array([
          .string("{{TEMPLATE_APP_GROUP_ID}}")
        ]),
      ]),
      // scripts: Environment.lintingSettings.scripts,
      dependencies: [
        .package(product: "{{TEMPLATE_APP_NAME}}Kit", type: .runtime),
        // Non-full-stack: App is compiled inside Kit's package (no separate product needed here,
        // but the product name still resolves). Full-stack: setup.sh moves App to its own package.
        .package(product: "{{TEMPLATE_APP_NAME}}App", type: .runtime),
      ],
      settings: .settings(
        base: [
          "CODE_SIGN_STYLE": "Manual",  // Using fastlane match for certificate management
          "DEVELOPMENT_TEAM": "{{TEMPLATE_TEAM_ID}}",
          "SWIFT_VERSION": "6.2",
          "SWIFT_STRICT_CONCURRENCY": "complete",
          "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
          "SWIFT_EMIT_LOC_STRINGS": "YES",  // Enable String Catalog symbol generation
          // Register app groups in provisioning profile
          "CODE_SIGN_INJECT_BASE_ENTITLEMENTS": "YES",
        ],
        configurations: [
          .debug(
            name: "Debug",
            settings: [
              "CODE_SIGN_IDENTITY": "Apple Development",
              "PROVISIONING_PROFILE_SPECIFIER":
                "match Development {{TEMPLATE_BUNDLE_ID}}",
            ],
            xcconfig: .relativeToRoot("Config/Version.xcconfig")
          ),
          .release(
            name: "Release",
            settings: [
              "CODE_SIGN_IDENTITY": "Apple Distribution",
              "PROVISIONING_PROFILE_SPECIFIER":
                "match AppStore {{TEMPLATE_BUNDLE_ID}}",
            ],
            xcconfig: .relativeToRoot("Config/Version.xcconfig")
          ),
        ]
      )
    )
    // Note: Tests are handled via Swift Package testing in Packages/{{TEMPLATE_APP_NAME}}Kit/Tests/
  ]
)
