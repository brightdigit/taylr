//
//  CI.swift
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

/// How continuous integration runs for a project.
public enum CI: Sendable, Codable, Equatable {
  /// Run CI on GitHub Actions, writing the workflows into `.github/workflows/`.
  ///
  /// - Parameters:
  ///   - runners: Where the macOS jobs run. Defaults to `.selfHosted()`.
  ///   - workflows: The workflows to write. Defaults to all of them.
  ///   - matrix: Builds to add to, or leave out of, the standard builds. Defaults to none.
  case githubActions(
    runners: Runners = .selfHosted(),
    workflows: [Workflow] = Workflow.allCases,
    matrix: Matrix = Matrix()
  )

  /// Where the macOS jobs run. Linux, Windows and Android jobs always run on GitHub's runners.
  public enum Runners: Sendable, Codable, Equatable {
    /// Run the macOS jobs on your own Macs, picked by their runner labels.
    ///
    /// - Parameters:
    ///   - labels: The runner labels. Defaults to `["self-hosted", "macOS"]`.
    ///   - xcodes: The Xcode apps installed on the Macs, by path. Defaults to
    ///     `["/Applications/Xcode.app"]`.
    case selfHosted(
      labels: [String] = ["self-hosted", "macOS"],
      xcodes: [String] = ["/Applications/Xcode.app"]
    )

    /// Run the macOS jobs on GitHub's runners, which are free for public repositories.
    case githubHosted
  }

  /// A workflow in `.github/workflows/`.
  public enum Workflow: String, Sendable, Codable, Equatable, CaseIterable {
    /// Builds, lints and tests pull requests and `main`. In an app, uploads `main` to TestFlight.
    case ci
    /// Uploads the App Store listing when run from the Actions tab. Apps with fastlane only.
    case appStoreMetadata
    /// Checks every week that the App Store session hasn't expired. Apps with fastlane only.
    case appStoreSession
    /// Deletes old GitHub Actions caches, and a pull request's caches when it closes.
    case cleanup
    /// Answers `@claude` in issues and pull requests, and reviews pull requests.
    case claude

    /// The file names this workflow writes into `.github/workflows/`, the same in an app and a
    /// package.
    public var fileNames: [String] {
      switch self {
      case .ci: ["integration.yml"]
      case .appStoreMetadata: ["app-store-metadata.yml"]
      case .appStoreSession: ["asc-session.yml"]
      case .cleanup: ["cleanup-caches.yml", "cleanup-pr-caches.yml"]
      case .claude: ["claude.yml", "claude-code-review.yml"]
      }
    }
  }
}
