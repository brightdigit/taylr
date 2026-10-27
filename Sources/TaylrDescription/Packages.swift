//
//  Packages.swift
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

/// The packages an app is made of, and what each one depends on.
///
/// Use ``appOnly`` or ``withServer(_:)``, or lay the packages out yourself with
/// ``init(client:server:others:)``: give the client and the server, and taylr finds the rest by
/// following their dependencies. Call ``resolvedPackages(appName:)`` for the whole graph.
public enum Packages: Sendable, Codable, Equatable {
  /// `<App>App`, which depends on `<App>Kit`.
  case appOnly

  /// `<App>App` and the server, which both depend on `<App>Kit`.
  ///
  /// A server without a name becomes `<App>Server`. Dependencies the server already lists are
  /// kept.
  /// - Parameter server: The server package, made with
  ///   ``Package/server(name:platforms:dependencies:framework:)``.
  case withServer(Package)

  /// A layout spelled out in the manifest.
  ///
  /// Prefer ``init(client:server:others:)``, which reads the same way as the reference.
  case custom(client: Package, server: Package?, others: [Package])

  /// What is wrong with a package graph.
  ///
  /// ``resolvedPackages(appName:)`` throws the first one it finds, in this order: the server and
  /// duplicate errors while it reads the packages, then ``cycle(path:)``,
  /// ``clientDependsOnServer(path:)`` and ``unusedOthersEntry(name:)``.
  public enum GraphError: Error, Sendable, Codable, Equatable {
    /// Packages depend on each other in a loop.
    /// - Parameter path: The names along the loop; the first and the last are the same.
    case cycle(path: [String])

    /// The client depends on the server, directly or through another package.
    /// - Parameter path: The names from the client to the server.
    case clientDependsOnServer(path: [String])

    /// More than one server package.
    /// - Parameter names: The server in the server slot, then the other one.
    case multipleServers(names: [String])

    /// A `Package.server` anywhere but the server slot: a dependency, an `others` entry or the
    /// client.
    /// - Parameter name: The server package's name.
    case serverOutsideServerSlot(name: String)

    /// Two declarations of the same package name with different settings.
    /// - Parameter name: The package's name.
    case duplicateNameDifferentSettings(name: String)

    /// An `others` entry that is already part of the graph, because the client, the server or
    /// another package depends on it. It can be removed from `others`.
    /// - Parameter name: The package's name.
    case unusedOthersEntry(name: String)
  }

  /// Creates a layout from the client and the server; the packages they depend on follow.
  ///
  /// - Parameters:
  ///   - client: The app package: the one the app targets link.
  ///   - server: The server package. Defaults to `nil`: no server.
  ///   - others: Packages nothing depends on yet, so taylr can't find them by following
  ///     dependencies. Defaults to none.
  public init(client: Package, server: Package? = nil, others: [Package] = []) {
    self = .custom(client: client, server: server, others: others)
  }

  /// Every package of the app, with its dependencies.
  ///
  /// Packages are found breadth-first: the client and the packages it depends on, level by level,
  /// then the server and what is new in its dependencies, then `others`. Each package appears
  /// once. A name and a ``Package`` with that name are the same package; when one of them has
  /// settings and the other is only a name, the one with settings is kept.
  ///
  /// - Parameter appName: The app's name, such as `"Acme"`. It names the presets `AcmeApp`,
  ///   `AcmeKit` and `AcmeServer`.
  /// - Returns: The packages, client first.
  /// - Throws: A ``GraphError`` for a graph that can't be built.
  public func resolvedPackages(appName: String) throws(GraphError) -> [Package] {
    let kit = Package(name: "\(appName)Kit")
    let app = Package(name: "\(appName)App", dependencies: [kit])
    switch self {
    case .appOnly:
      var graph = PackageGraph(appName: appName, client: app, server: nil, others: [])
      return try graph.resolve()
    case .withServer(var server):
      let usesKit = server.dependencies.contains { dependency in
        guard case .local(let package) = dependency else {
          return false
        }
        return package.name == kit.name
      }
      if !usesKit {
        server.dependencies.append(kit.dependency)
      }
      var graph = PackageGraph(appName: appName, client: app, server: server, others: [])
      return try graph.resolve()
    case .custom(let client, let server, let others):
      var graph = PackageGraph(appName: appName, client: client, server: server, others: others)
      return try graph.resolve()
    }
  }
}
