//
//  App+Server.swift
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

extension App {
  /// Creates an app with a server.
  ///
  /// This takes `server` where the other initializer takes `packages`, so passing both doesn't
  /// compile. The app's packages become
  /// ``PackageLayout/withServer(_:)``. Every other parameter is the same, with the same defaults.
  ///
  /// - Parameters:
  ///   - name: The app's name.
  ///   - profile: The profile the app uses.
  ///   - platforms: The platforms and their minimum versions.
  ///   - bundleID: The app's bundle ID. Defaults to `nil`.
  ///   - appGroupID: The app group. Defaults to `nil`.
  ///   - urls: The app's web links. Defaults to `nil`.
  ///   - server: The server package, made with
  ///     ``Package/server(name:platforms:dependencies:framework:)``.
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
  ///   - swiftVersion: The Swift language version. Defaults to `nil`.
  ///   - includeNightly: Also test the next Swift's nightly build. Defaults to `false`.
  ///   - devcontainer: Add dev containers. Defaults to `true`.
  ///   - lint: The lint tools. Defaults to `[.swiftLint, .swiftFormat]`.
  ///   - header: The file header template. Defaults to `.file("Scripts/header.mustache")`.
  ///   - license: The license. Defaults to ``License/proprietary``.
  ///   - gitLFS: Store images with Git LFS. Defaults to `true`.
  ///   - agents: The AI coding agents to set up. Defaults to `[.claudeCode]`.
  public init(
    name: String,
    profile: any ProfileSource,
    platforms: [Platform],
    bundleID: String? = nil,
    appGroupID: String? = nil,
    urls: URLs? = nil,
    server: Package,
    appStoreConnect: AppStoreConnect? = .fastlane,
    screenshots: Screenshots? = .fastlaneSnapshot,
    distribution: [Distribution] = [.appStore],
    pressKit: PressKit? = .uv,
    localizations: [String] = ["en-US"],
    crossPlatform: Bool = true,
    generator: Generator = .tuist,
    taylrVersion: String = "1.0.0",
    github: GitHub? = nil,
    // swiftlint:disable:next identifier_name
    ci: (any CI)? = .githubActions(),
    swiftVersion: String? = nil,
    includeNightly: Bool = false,
    devcontainer: Bool = true,
    lint: [LintTool] = [.swiftLint, .swiftFormat],
    header: (any Header)? = .file("Scripts/header.mustache"),
    license: License = .proprietary,
    gitLFS: Bool = true,
    agents: [Agent] = [.claudeCode]
  ) {
    self.init(
      name: name,
      profile: profile,
      platforms: platforms,
      bundleID: bundleID,
      appGroupID: appGroupID,
      urls: urls,
      packages: .withServer(server),
      appStoreConnect: appStoreConnect,
      screenshots: screenshots,
      distribution: distribution,
      pressKit: pressKit,
      localizations: localizations,
      crossPlatform: crossPlatform,
      generator: generator,
      taylrVersion: taylrVersion,
      github: github,
      ci: ci,
      swiftVersion: swiftVersion,
      includeNightly: includeNightly,
      devcontainer: devcontainer,
      lint: lint,
      header: header,
      license: license,
      gitLFS: gitLFS,
      agents: agents
    )
  }
}
