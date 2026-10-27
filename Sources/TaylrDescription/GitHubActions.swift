//
//  GitHubActions.swift
//  taylr
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

/// CI on GitHub Actions, writing the workflows into `.github/workflows/`.
public struct GitHubActions: CI, Codable, Equatable {
  /// Where the macOS jobs run.
  public var runners: RunnersSerialization
  /// The workflows to write.
  public var workflows: [Workflow]
  /// Builds to add to, or leave out of, the standard builds.
  public var matrix: Matrix

  /// The configuration as ``CISerialization/githubActions(configuration:)``.
  public var serialization: CISerialization { .githubActions(configuration: self) }

  /// Creates a GitHub Actions configuration.
  ///
  /// - Parameters:
  ///   - runners: Where the macOS jobs run. Defaults to `.selfHosted()`.
  ///   - workflows: The workflows to write. Defaults to all of them.
  ///   - matrix: Builds to add to, or leave out of, the standard builds. Defaults to none.
  public init(
    runners: any Runners = .selfHosted(),
    workflows: [Workflow] = Workflow.allCases,
    matrix: Matrix = Matrix()
  ) {
    self.runners = runners.serialization
    self.workflows = workflows
    self.matrix = matrix
  }
}

extension CI where Self == GitHubActions {
  /// Run CI on GitHub Actions, writing the workflows into `.github/workflows/`.
  ///
  /// - Parameters:
  ///   - runners: Where the macOS jobs run. Defaults to `.selfHosted()`.
  ///   - workflows: The workflows to write. Defaults to all of them.
  ///   - matrix: Builds to add to, or leave out of, the standard builds. Defaults to none.
  /// - Returns: The CI configuration.
  public static func githubActions(
    runners: any GitHubActions.Runners = .selfHosted(),
    workflows: [GitHubActions.Workflow] = GitHubActions.Workflow.allCases,
    matrix: GitHubActions.Matrix = GitHubActions.Matrix()
  ) -> GitHubActions {
    GitHubActions(runners: runners, workflows: workflows, matrix: matrix)
  }
}
