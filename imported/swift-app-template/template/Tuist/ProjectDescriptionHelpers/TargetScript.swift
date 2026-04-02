//
//  TargetScript.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

extension TargetScript {
  /// Creates a post-build linting script with the specified lint mode.
  /// - Parameter lintMode: The lint mode to use.
  /// - Returns: A target script that runs linting after build.
  public static func lintingScript(withLintMode lintMode: String) -> Self {
    .post(
      script: """
        export LINT_MODE=\(lintMode)
        "${SRCROOT}/Scripts/lint.sh"
        """,
      name: "SwiftLint & SwiftFormat",
      basedOnDependencyAnalysis: false
    )
  }
}
