//
//  Settings+App.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

extension Settings {
  /// Full settings object for a UI test target.
  public static var uitestSettings: Self {
    .settings(
      base: .uitestBase,
      configurations: [.uitestDebug, .uitestRelease]
    )
  }

  /// Full settings object for a signed app target.
  public static func appSettings(bundleId: String) -> Self {
    .settings(
      base: .appBase,
      configurations: [
        .appDebug(bundleId: bundleId),
        .appRelease(bundleId: bundleId),
      ]
    )
  }
}
