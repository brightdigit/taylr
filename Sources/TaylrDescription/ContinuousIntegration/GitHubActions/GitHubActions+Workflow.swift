//
//  GitHubActions+Workflow.swift
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

extension GitHubActions {
  /// A workflow in `.github/workflows/`.
  public enum Workflow: String, Sendable, Codable, Equatable, CaseIterable {
    /// Builds, lints and tests pull requests and `main`. In an app, uploads `main` to TestFlight.
    case ci  // swiftlint:disable:this identifier_name
    /// Uploads the App Store listing when run from the Actions tab. Apps with fastlane only.
    case appStoreMetadata
    /// Checks every week that the App Store session hasn't expired. Apps with fastlane only.
    case appStoreSession
    /// Deletes old GitHub Actions caches, and a pull request's caches when it closes.
    case cleanup
    /// Answers `@claude` in issues and pull requests, and reviews pull requests.
    case claude

    private static let fileNames: [Workflow: [String]] = [
      .ci: ["integration.yml"],
      .appStoreMetadata: ["app-store-metadata.yml"],
      .appStoreSession: ["asc-session.yml"],
      .cleanup: ["cleanup-caches.yml", "cleanup-pr-caches.yml"],
      .claude: ["claude.yml", "claude-code-review.yml"],
    ]

    /// The file names this workflow writes into `.github/workflows/`, the same in an app and a
    /// package.
    public var fileNames: [String] {
      guard let names = Self.fileNames[self] else {
        assertionFailure("No file names for \(self)")
        return []
      }
      return names
    }
  }
}
