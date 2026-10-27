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

/// A layout of an app's packages spelled out in the manifest: the client, the server and any
/// others.
///
/// Give the client and the server, and taylr finds the rest by following their dependencies.
public struct Packages: PackageLayout, Codable, Equatable {
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

  /// The app package: the one the app targets link.
  public var client: Package
  /// The server package, or `nil` for none.
  public var server: Package?
  /// Packages nothing depends on yet.
  public var others: [Package]

  /// The layout as ``PackageLayoutSerialization/custom(client:server:others:)``.
  public var serialization: PackageLayoutSerialization {
    .custom(client: client, server: server, others: others)
  }

  /// Creates a layout from the client and the server; the packages they depend on follow.
  ///
  /// - Parameters:
  ///   - client: The app package: the one the app targets link.
  ///   - server: The server package. Defaults to `nil`: no server.
  ///   - others: Packages nothing depends on yet, so taylr can't find them by following
  ///     dependencies. Defaults to none.
  public init(client: Package, server: Package? = nil, others: [Package] = []) {
    self.client = client
    self.server = server
    self.others = others
  }

}
