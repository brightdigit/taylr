//
//  App.swift
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

/// An app: the manifest of a Swift app made with taylr.
///
/// An app needs a name, a profile and its platforms; everything else has a default. Give the
/// packages with `packages:`, or just the server with `server:`, which is short for
/// `packages: .withServer(server)`. The two are mutually exclusive: passing both doesn't compile.
public struct App: Sendable, Codable, Equatable {
  /// The app's name. It must be a valid Swift name.
  public var name: String

  /// The profile the app uses.
  public var profile: Profile

  /// The platforms and their minimum versions. The app gets a target for each.
  public var platforms: [Platform]

  /// The app's bundle ID, or `nil` for the profile's `bundleIDPrefix` and the name.
  public var bundleID: String?

  /// The app group, or `nil` for `group.` followed by the bundle ID.
  public var appGroupID: String?

  /// The app's web links, or `nil` for none: add them before you submit to the App Store.
  public var urls: URLs?

  /// The app's local packages and how they depend on each other.
  public var packages: Packages

  /// The App Store tools, or `nil` for none.
  public var appStoreConnect: AppStoreConnect?

  /// How App Store screenshots are captured, or `nil` for none.
  ///
  /// Screenshots need fastlane, so the initializers store `nil` here when ``appStoreConnect`` is
  /// `nil`, whatever was passed.
  public var screenshots: Screenshots?

  /// Where the app ships.
  public var distribution: [Distribution]

  /// The press kit images made from the app icon, or `nil` for none.
  public var pressKit: PressKit?

  /// The app's languages, as App Store locale codes. The first is the development language.
  public var localizations: [String]

  /// Whether CI also builds the app's packages on Linux, Windows, Android and Wasm.
  public var crossPlatform: Bool

  /// What generates the Xcode project.
  public var generator: Generator

  /// The taylr version the app was created with.
  public var taylrVersion: String

  /// The GitHub repository, or `nil` for none.
  public var github: GitHub?

  /// How CI runs, or `nil` for no CI.
  public var ci: CI?

  /// The Swift language version, or `nil` for the Swift that comes with the selected Xcode.
  public var swiftVersion: String?

  /// Also test the next Swift's nightly build.
  public var includeNightly: Bool

  /// Whether to add dev containers in `.devcontainer/`.
  public var devcontainer: Bool

  /// The lint tools.
  public var lint: [LintTool]

  /// The file header template, or `nil` for none.
  public var header: Header?

  /// The license.
  public var license: License

  /// Whether to store images with Git LFS (`.gitattributes`).
  public var gitLFS: Bool

  /// The AI coding agents to set up.
  public var agents: [Agent]

  /// Creates an app.
  ///
  /// - Parameters:
  ///   - name: The app's name.
  ///   - profile: The profile the app uses.
  ///   - platforms: The platforms and their minimum versions.
  ///   - bundleID: The app's bundle ID. Defaults to `nil`: the profile's `bundleIDPrefix`, then
  ///     the name.
  ///   - appGroupID: The app group. Defaults to `nil`: `group.` followed by the bundle ID.
  ///   - urls: The app's web links. Defaults to `nil`.
  ///   - packages: The app's packages. Defaults to ``Packages/appOnly``.
  ///   - appStoreConnect: The App Store tools. Defaults to ``AppStoreConnect/fastlane``.
  ///   - screenshots: How screenshots are captured. Defaults to ``Screenshots/fastlaneSnapshot``.
  ///   - distribution: Where the app ships. Defaults to `[.appStore]`.
  ///   - pressKit: The press kit. Defaults to ``PressKit/uv``.
  ///   - localizations: The app's languages. Defaults to `["en-US"]`.
  ///   - crossPlatform: Also build the packages on Linux, Windows, Android and Wasm. Defaults
  ///     to `true`.
  ///   - generator: What generates the Xcode project. Defaults to ``Generator/tuist``.
  ///   - taylrVersion: The taylr version the app was created with. Defaults to `"1.0.0"`.
  ///   - github: The GitHub repository. Defaults to `nil`.
  ///   - ci: CI. Defaults to GitHub Actions with every workflow.
  ///   - swiftVersion: The Swift language version. Defaults to `nil`: the Swift that comes with
  ///     the selected Xcode.
  ///   - includeNightly: Also test the next Swift's nightly build. Defaults to `false`.
  ///   - devcontainer: Add dev containers. Defaults to `true`.
  ///   - lint: The lint tools. Defaults to `[.swiftLint, .swiftFormat]`.
  ///   - header: The file header template. Defaults to `.file("Scripts/header.mustache")`.
  ///   - license: The license. Defaults to ``License/proprietary``.
  ///   - gitLFS: Store images with Git LFS. Defaults to `true`.
  ///   - agents: The AI coding agents to set up. Defaults to `[.claudeCode]`.
  public init(
    name: String,
    profile: Profile,
    platforms: [Platform],
    bundleID: String? = nil,
    appGroupID: String? = nil,
    urls: URLs? = nil,
    packages: Packages = .appOnly,
    appStoreConnect: AppStoreConnect? = .fastlane,
    screenshots: Screenshots? = .fastlaneSnapshot,
    distribution: [Distribution] = [.appStore],
    pressKit: PressKit? = .uv,
    localizations: [String] = ["en-US"],
    crossPlatform: Bool = true,
    generator: Generator = .tuist,
    taylrVersion: String = "1.0.0",
    github: GitHub? = nil,
    ci: CI? = .githubActions(),
    swiftVersion: String? = nil,
    includeNightly: Bool = false,
    devcontainer: Bool = true,
    lint: [LintTool] = [.swiftLint, .swiftFormat],
    header: Header? = .file("Scripts/header.mustache"),
    license: License = .proprietary,
    gitLFS: Bool = true,
    agents: [Agent] = [.claudeCode]
  ) {
    self.name = name
    self.profile = profile
    self.platforms = platforms
    self.bundleID = bundleID
    self.appGroupID = appGroupID
    self.urls = urls
    self.packages = packages
    self.appStoreConnect = appStoreConnect
    self.screenshots = appStoreConnect == nil ? nil : screenshots
    self.distribution = distribution
    self.pressKit = pressKit
    self.localizations = localizations
    self.crossPlatform = crossPlatform
    self.generator = generator
    self.taylrVersion = taylrVersion
    self.github = github
    self.ci = ci
    self.swiftVersion = swiftVersion
    self.includeNightly = includeNightly
    self.devcontainer = devcontainer
    self.lint = lint
    self.header = header
    self.license = license
    self.gitLFS = gitLFS
    self.agents = agents
  }

  /// The app's bundle ID.
  ///
  /// - Parameter prefix: The profile's bundle ID prefix, such as `com.acmecorp`.
  /// - Returns: ``bundleID`` when it is set, otherwise the prefix and the name:
  ///   `com.acmecorp.Acme`.
  public func resolvedBundleID(prefix: String) -> String {
    bundleID ?? "\(prefix).\(name)"
  }

  /// The app's app group.
  ///
  /// - Parameter prefix: The profile's bundle ID prefix, such as `com.acmecorp`.
  /// - Returns: ``appGroupID`` when it is set, otherwise `group.` followed by the bundle ID
  ///   (see ``resolvedBundleID(prefix:)``): `group.com.acmecorp.Acme`.
  public func resolvedAppGroupID(prefix: String) -> String {
    appGroupID ?? "group.\(resolvedBundleID(prefix: prefix))"
  }
}
