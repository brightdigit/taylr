//
//  PackageLayoutSerialization.swift
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

/// How a ``PackageLayout`` is stored and encoded: one case per layout.
public enum PackageLayoutSerialization: Sendable, Codable, Equatable {
  /// `<App>App`, which depends on `<App>Kit`.
  case appOnly
  /// `<App>App` and `server`, which both depend on `<App>Kit`.
  case withServer(server: Package)
  /// A layout spelled out in the manifest.
  case custom(client: Package, server: Package?, others: [Package])

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
  /// - Throws: A ``Packages/GraphError`` for a graph that can't be built.
  public func resolvedPackages(appName: String) throws(Packages.GraphError) -> [Package] {
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
        server.dependencies.append(kit.serialization)
      }
      var graph = PackageGraph(appName: appName, client: app, server: server, others: [])
      return try graph.resolve()
    case .custom(let client, let server, let others):
      var graph = PackageGraph(appName: appName, client: client, server: server, others: others)
      return try graph.resolve()
    }
  }
}
