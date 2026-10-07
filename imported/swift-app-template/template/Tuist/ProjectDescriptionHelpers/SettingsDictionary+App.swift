//
//  SettingsDictionary+App.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

extension SettingsDictionary {
  /// Base build settings shared by signed app targets.
  public static var appBase: SettingsDictionary {
    [
      "CODE_SIGN_STYLE": "Manual",  // Using fastlane match for certificate management
      "DEVELOPMENT_TEAM": "\(AppConstants.teamID)",
      "SWIFT_VERSION": "6.3",
      "SWIFT_STRICT_CONCURRENCY": "complete",
      "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
      "SWIFT_EMIT_LOC_STRINGS": "YES",  // Enable String Catalog symbol generation
      // Register app groups in provisioning profile
      "CODE_SIGN_INJECT_BASE_ENTITLEMENTS": "YES",
    ]
  }

  /// Base build settings shared by UI test targets (no code signing required).
  public static var uitestBase: SettingsDictionary {
    [
      "SWIFT_VERSION": "6.3",
      "SWIFT_STRICT_CONCURRENCY": "targeted",
    ]
  }
}
