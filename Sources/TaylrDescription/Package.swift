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
  ///
  /// `nil` only for a server created with ``server(name:platforms:dependencies:framework:)``
  /// without a name: it becomes `<App>Server` once the app's name is known.
  public var name: String?

  /// Minimum platform versions, as in the `platforms` of `Package.swift`. Empty means SwiftPM's
  /// own minimums.
  public var platforms: [Platform]

  /// The Swift language version, or `nil` for the Swift that comes with the selected Xcode.
  /// Inside an app: the app's.
  public var swiftVersion: String?

  /// The packages this one uses: third-party packages, and inside an app, the app's other
  /// packages (``Dependency/local(_:)``).
  public var dependencies: [Dependency]

  /// The taylr version the package was created with. Ignored inside an app.
  public var taylrVersion: String

  /// Also test the next Swift's nightly build.
  public var includeNightly: Bool

  /// The GitHub repository, or `nil` for none.
  public var github: GitHub?

  /// How CI runs, or `nil` for no CI.
  public var ci: CI?

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

  /// The server framework, or `nil` for a package that isn't a server.
  ///
  /// Only ``Package/server(name:platforms:dependencies:framework:)`` sets it.
  public internal(set) var framework: ServerFramework?

  /// Creates a Swift package.
  ///
  /// - Parameters:
  ///   - name: The package's name.
  ///   - platforms: Minimum platform versions. Defaults to none: SwiftPM's minimums.
  ///   - swiftVersion: The Swift language version. Defaults to `nil`: the Swift that comes with
  ///     the selected Xcode.
  ///   - dependencies: The packages this one uses: ``Dependency`` values such as
  ///     `.package(url:from:)`, plus ``Package`` values and package names, which become
  ///     ``Dependency/local(_:)``. Defaults to none.
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
    dependencies: [any DependencyConvertible] = [],
    taylrVersion: String = "1.0.0",
    includeNightly: Bool = false,
    github: GitHub? = nil,
    ci: CI? = .githubActions(workflows: [.ci, .cleanup, .claude]),
    devcontainer: Bool = true,
    lint: [LintTool] = [.swiftLint, .swiftFormat],
    header: Header? = .file("Scripts/header.mustache"),
    license: License = .mit,
    gitLFS: Bool = false,
    agents: [Agent] = [.claudeCode]
  ) {
    self.name = name
    self.platforms = platforms
    self.swiftVersion = swiftVersion
    self.dependencies = dependencies.map(\.dependency)
    self.taylrVersion = taylrVersion
    self.includeNightly = includeNightly
    self.github = github
    self.ci = ci
    self.devcontainer = devcontainer
    self.lint = lint
    self.header = header
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

extension Package {
  /// Creates the server package: a package with a server framework.
  ///
  /// Every other setting takes the same default as a plain package.
  ///
  /// - Parameters:
  ///   - name: The package's name. Defaults to `nil`: `<App>Server`, once the app's name is known.
  ///     Until then the package's ``name`` is `nil`.
  ///   - platforms: Minimum platform versions. Like every Swift package, it also builds on Linux,
  ///     where it's deployed. Defaults to `[.macOS()]`.
  ///   - dependencies: The packages the server uses. Defaults to none.
  ///   - framework: The server framework and its routing. Defaults to `.hummingbird()`, with the
  ///     built-in router.
  /// - Returns: The server package.
  public static func server(
    name: String? = nil,
    platforms: [Platform] = [.macOS()],
    dependencies: [any DependencyConvertible] = [],
    framework: ServerFramework = .hummingbird()
  ) -> Package {
    var package = Package(name: name ?? "", platforms: platforms, dependencies: dependencies)
    package.name = name
    package.framework = framework
    return package
  }
}
