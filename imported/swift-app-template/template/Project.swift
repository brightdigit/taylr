//
//  Project.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

// swiftlint:disable:next no_global_declarations
internal let project = Project(
  name: AppConstants.name,
  // Non-full-stack (default): only Kit package is referenced here; App target is included
  // within Kit's Package.swift. Full-stack mode: setup.sh adds
  // .local(path: "./Packages/{{TEMPLATE_APP_NAME}}App") and removes App from Kit's package.
  packages: [
    .local(path: "./Packages/{{TEMPLATE_APP_NAME}}Kit")
  ],
  targets: [
    // Main app target
    .target(
      name: AppConstants.name,
      destinations: {{TEMPLATE_DESTINATIONS}},
      product: .app,
      bundleId: AppConstants.bundleID,
      deploymentTargets: {{TEMPLATE_DEPLOYMENT_TARGET}},
      infoPlist: .extendingDefault(
        with: [
          // Version info from xcconfig
          "CFBundleShortVersionString": "$(MARKETING_VERSION)",
          "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
          // Empty for a release build; see VersionInfo.displayVersion
          "BetaBaseBuild": "$(BETA_BASE_BUILD)",
          "CFBundleDisplayName": .string(AppConstants.name),
          "NSHumanReadableCopyright": .string(AppConstants.copyright),
          "LSApplicationCategoryType": .string(AppConstants.category),
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
          .string(AppConstants.appGroup)
        ])
      ]),
      // scripts: Environment.lintingSettings.scripts,
      dependencies: [
        .package(product: "{{TEMPLATE_APP_NAME}}Kit", type: .runtime),
        // Non-full-stack: App is compiled inside Kit's package (no separate
        // product needed here, but the product name still resolves).
        // Full-stack: setup.sh moves App to its own package.
        .package(product: "{{TEMPLATE_APP_NAME}}App", type: .runtime),
      ],
      settings: .appSettings(bundleId: AppConstants.bundleID)
    ),
    // UI tests drive the app for fastlane snapshot (make capture-ios). Unit tests
    // live in the Kit package (Packages/{{TEMPLATE_PACKAGE_NAME}}/Tests/).
    .target(
      name: "\(AppConstants.name)UITests",
      destinations: {{TEMPLATE_DESTINATIONS}},
      product: .uiTests,
      bundleId: "\(AppConstants.bundleID).uitests",
      deploymentTargets: {{TEMPLATE_DEPLOYMENT_TARGET}},
      infoPlist: .default,
      sources: ["UITests/**"],
      dependencies: [
        .target(name: AppConstants.name)
      ],
      settings: .uitestSettings
    ),
  ]
)
