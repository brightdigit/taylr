//
//  LintingSetting.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

/// Configuration for linting behavior in Tuist projects.
public struct LintingSetting {
  /// Whether strict linting mode is enabled.
  public let isStrict: Bool
  /// Whether linting is enabled at all.
  public let isEnabled: Bool

  /// The lint mode string ("STRICT" or empty).
  public var lintMode: String {
    isStrict ? "STRICT" : ""
  }

  /// The target scripts to include based on linting settings.
  public var scripts: [TargetScript] {
    self.isEnabled
      ? [.lintingScript(withLintMode: Environment.lintingSettings.lintMode)]
      : []
  }

  /// Initializes linting settings with explicit flags.
  /// - Parameters:
  ///   - isStrict: Whether to enable strict mode.
  ///   - isEnabled: Whether to enable linting.
  public init(isStrict: Bool, isEnabled: Bool) {
    self.isStrict = isStrict
    self.isEnabled = isEnabled
  }

  /// Initializes linting settings from a mode string.
  /// - Parameter lintMode: The lint mode ("STRICT", "NONE", or empty).
  public init(lintMode: String) {
    self.isEnabled = lintMode.lowercased() != "none"
    self.isStrict = lintMode.uppercased() == "STRICT"
  }
}
