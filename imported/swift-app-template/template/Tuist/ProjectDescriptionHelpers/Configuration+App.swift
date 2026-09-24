//
//  Configuration+App.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

extension Configuration {
  // App.xcconfig chains Version.xcconfig (rewritten by Scripts/update-version.sh)
  // and any other xcconfig that must survive version bumps.
  private static let appXCConfig: Path = .relativeToRoot("Config/App.xcconfig")

  /// Debug configuration for UI test targets (app xcconfig only, no provisioning).
  public static var uitestDebug: Self {
    .debug(name: "Debug", xcconfig: appXCConfig)
  }

  /// Release configuration for UI test targets (app xcconfig only, no provisioning).
  public static var uitestRelease: Self {
    .release(name: "Release", xcconfig: appXCConfig)
  }

  /// Debug configuration with match provisioning for an app target.
  public static func appDebug(bundleId: String) -> Self {
    .debug(
      name: "Debug",
      settings: [
        "CODE_SIGN_IDENTITY": "Apple Development",
        "PROVISIONING_PROFILE_SPECIFIER": "match Development \(bundleId)",
      ],
      xcconfig: appXCConfig
    )
  }

  /// Release configuration with match provisioning for an app target.
  public static func appRelease(bundleId: String) -> Self {
    .release(
      name: "Release",
      settings: [
        "CODE_SIGN_IDENTITY": "Apple Distribution",
        "PROVISIONING_PROFILE_SPECIFIER": "match AppStore \(bundleId)",
      ],
      xcconfig: appXCConfig
    )
  }
}
