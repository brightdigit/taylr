//
//  GitHubActions+Runners.swift
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
  /// Where the macOS jobs run. Linux, Windows and Android jobs always run on GitHub's runners.
  ///
  /// Write runners as ``selfHosted(labels:xcodes:)`` or ``githubHosted``.
  public protocol Runners: ManifestValue where Serialization == RunnersSerialization {}

  /// How ``Runners`` are stored and encoded: one case per kind of runner.
  public enum RunnersSerialization: Sendable, Codable, Equatable {
    /// Your own Macs, picked by their runner labels, with these Xcode apps installed.
    case selfHosted(labels: [String], xcodes: [String])
    /// GitHub's runners.
    case githubHosted
  }

  /// The macOS jobs run on your own Macs.
  public struct SelfHostedRunners: Runners {
    /// The runner labels.
    public var labels: [String]
    /// The Xcode apps installed on the Macs, by path.
    public var xcodes: [String]

    /// The runners as ``RunnersSerialization/selfHosted(labels:xcodes:)``.
    public var serialization: RunnersSerialization { .selfHosted(labels: labels, xcodes: xcodes) }

    /// Creates self-hosted runners.
    ///
    /// - Parameters:
    ///   - labels: The runner labels.
    ///   - xcodes: The Xcode apps installed on the Macs, by path.
    public init(labels: [String], xcodes: [String]) {
      self.labels = labels
      self.xcodes = xcodes
    }
  }

  /// The macOS jobs run on GitHub's runners.
  public struct GitHubHostedRunners: Runners {
    /// The runners as ``RunnersSerialization/githubHosted``.
    public var serialization: RunnersSerialization { .githubHosted }

    /// Creates GitHub-hosted runners.
    public init() {}
  }
}

extension GitHubActions.Runners where Self == GitHubActions.SelfHostedRunners {
  /// Run the macOS jobs on your own Macs, picked by their runner labels.
  ///
  /// - Parameters:
  ///   - labels: The runner labels. Defaults to `["self-hosted", "macOS"]`.
  ///   - xcodes: The Xcode apps installed on the Macs, by path. Defaults to
  ///     `["/Applications/Xcode.app"]`.
  /// - Returns: The runners.
  public static func selfHosted(
    labels: [String] = ["self-hosted", "macOS"],
    xcodes: [String] = ["/Applications/Xcode.app"]
  ) -> GitHubActions.SelfHostedRunners {
    GitHubActions.SelfHostedRunners(labels: labels, xcodes: xcodes)
  }
}

extension GitHubActions.Runners where Self == GitHubActions.GitHubHostedRunners {
  /// Run the macOS jobs on GitHub's runners, which are free for public repositories.
  public static var githubHosted: GitHubActions.GitHubHostedRunners {
    GitHubActions.GitHubHostedRunners()
  }
}
