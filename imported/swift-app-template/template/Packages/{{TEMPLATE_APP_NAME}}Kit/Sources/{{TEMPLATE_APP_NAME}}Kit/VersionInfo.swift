//
//  VersionInfo.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import Foundation

/// Computes the user-facing version string from the raw bundle values.
///
/// The beta scheme is encoded by a single `BETA_BASE_BUILD` build setting whose
/// *presence* signifies a beta build and whose value is the base build number the
/// beta count is measured from:
///
/// - `betaBase` present (non-empty) ⇒ **beta**, displayed as
///   `"{marketing} beta {build − betaBase}"` (base 0, build 6 ⇒ `1.0.0 beta 6`).
/// - `betaBase` `nil` or empty ⇒ **release**, displayed as `"{marketing}"`.
///
/// When the `BETA_BASE_BUILD` setting is absent, Xcode expands `$(BETA_BASE_BUILD)`
/// in the Info.plist to an empty string, so "base empty ⇒ release" is the natural check.
public enum VersionInfo {
  /// Builds the display version string from raw bundle values.
  /// - Parameters:
  ///   - marketing: `CFBundleShortVersionString` (e.g. `"1.0.0"`).
  ///   - build: `CFBundleVersion` (e.g. `"6"`).
  ///   - betaBase: `BetaBaseBuild` — `nil`/empty for a release build.
  /// - Returns: `"1.0.0 beta 6"` for a beta, `"1.0.0"` for a release.
  public static func displayVersion(
    marketing: String,
    build: String,
    betaBase: String?
  ) -> String {
    guard
      let betaBase,
      case let trimmedBase = betaBase.trimmingCharacters(in: .whitespacesAndNewlines),
      !trimmedBase.isEmpty,
      let base = Int(trimmedBase),
      let buildNumber = Int(build.trimmingCharacters(in: .whitespacesAndNewlines))
    else {
      return marketing
    }
    return "\(marketing) beta \(buildNumber - base)"
  }
}
