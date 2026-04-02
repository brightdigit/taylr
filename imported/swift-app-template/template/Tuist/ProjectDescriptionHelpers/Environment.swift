//
//  Environment.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

extension Environment {
  /// Linting settings derived from environment variables.
  public static var lintingSettings: LintingSetting {
    let lintMode = Environment.tuistLintMode.getString(default: "")
    return .init(lintMode: lintMode)
  }
}
