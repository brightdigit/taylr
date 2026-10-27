//
//  Package.swift
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

/// A Swift package: a project on its own, or one of an app's packages.
///
/// A package's products and targets stay in `Package.swift`. The manifest records what taylr set
/// up, and the dependencies taylr writes into `Package.swift`. Wherever a `Package` is expected,
/// a string works too: `"AcmeKit"` is `Package(name: "AcmeKit")`.
///
/// `Package` here is taylr's type, not SwiftPM's. To tell them apart, write
/// `TaylrDescription.Package`.
public struct Package: Sendable, Codable, Equatable, ExpressibleByStringLiteral {
  /// The package's name. It must be a valid Swift name.
  public var name: String

  /// Minimum platform versions, as in the `platforms` of `Package.swift`. Empty means SwiftPM's
  /// own minimums.
  public var platforms: [Platform]

  /// The Swift language version, or `nil` for the Swift that comes with the selected Xcode.
  /// Inside an app: the app's.
  public var swiftVersion: String?

  /// The packages this one uses: third-party packages, and inside an app, the app's other
  /// packages (``DependencySerialization/local(package:)``).
  public var dependencies: [DependencySerialization]

  /// The taylr version the package was created with. Ignored inside an app.
  public var taylrVersion: String

  /// Also test the next Swift's nightly build.
  public var includeNightly: Bool

  /// The GitHub repository, or `nil` for none.
  public var github: GitHub?

  /// How CI runs, or `nil` for no CI.
  public var ci: CISerialization?  // swiftlint:disable:this identifier_name

  /// Whether to add dev containers in `.devcontainer/`.
  public var devcontainer: Bool

  /// The lint tools.
  public var lint: [LintTool]

  /// The file header template, or `nil` for none.
  public var header: HeaderSerialization?

  /// The license.
  public var license: License

  /// Whether to store images with Git LFS (`.gitattributes`).
  public var gitLFS: Bool

  /// The AI coding agents to set up.
  public var agents: [Agent]

  /// Creates a Swift package.
  ///
  /// - Parameters:
  ///   - name: The package's name.
  ///   - platforms: Minimum platform versions. Defaults to none: SwiftPM's minimums.
  ///   - swiftVersion: The Swift language version. Defaults to `nil`: the Swift that comes with
  ///     the selected Xcode.
  ///   - dependencies: The packages this one uses: ``Dependency`` values such as
  ///     `.package(url:from:)`, plus ``Package`` values and package names, which become
  ///     ``DependencySerialization/local(package:)``. Defaults to none.
  ///   - taylrVersion: The taylr version the package was created with. Defaults to `"1.0.0"`.
  ///   - includeNightly: Also test the next Swift's nightly build. Defaults to `false`.
  ///   - github: The GitHub repository. Defaults to `nil`.
  ///   - ci: CI. Defaults to GitHub Actions with the `.ci`, `.cleanup` and `.claude` workflows.
  ///   - devcontainer: Add dev containers. Defaults to `true`.
  ///   - lint: The lint tools. Defaults to `[.swiftLint, .swiftFormat]`.
  ///   - header: The file header template. Defaults to `.file("Scripts/header.mustache")`.
  ///   - license: The license. Defaults to `.mit`.
  ///   - gitLFS: Store images with Git LFS. Defaults to `false`.
  ///   - agents: The AI coding agents to set up. Defaults to `[.claudeCode]`.
  public init(
    name: String,
    platforms: [Platform] = [],
    swiftVersion: String? = nil,
    dependencies: [any Dependency] = [],
    taylrVersion: String = "1.0.0",
    includeNightly: Bool = false,
    github: GitHub? = nil,
    // swiftlint:disable:next identifier_name
    ci: (any CI)? = .githubActions(workflows: [.ci, .cleanup, .claude]),
    devcontainer: Bool = true,
    lint: [LintTool] = [.swiftLint, .swiftFormat],
    header: (any Header)? = .file("Scripts/header.mustache"),
    license: License = .mit,
    gitLFS: Bool = false,
    agents: [Agent] = [.claudeCode]
  ) {
    self.name = name
    self.platforms = platforms
    self.swiftVersion = swiftVersion
    self.dependencies = dependencies.map { $0.serialization }
    self.taylrVersion = taylrVersion
    self.includeNightly = includeNightly
    self.github = github
    self.ci = ci?.serialization
    self.devcontainer = devcontainer
    self.lint = lint
    self.header = header?.serialization
    self.license = license
    self.gitLFS = gitLFS
    self.agents = agents
  }

  /// Creates a package with the given name and every other setting at its default.
  /// - Parameter value: The package's name.
  public init(stringLiteral value: String) {
    self.init(name: value)
  }
}
