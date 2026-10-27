//
//  ServerLayout.swift
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

/// `<App>App` and a server, which both depend on `<App>Kit`: spelled `.withServer(_:)`.
///
/// A server without a name becomes `<App>Server`. Dependencies the server already lists are kept.
public struct ServerLayout: PackageLayout {
  /// The server package.
  public var server: Package

  /// The layout as ``PackageLayoutSerialization/withServer(server:)``.
  public var serialization: PackageLayoutSerialization { .withServer(server: server) }

  /// Creates the layout with a server.
  /// - Parameter server: The server package, made with
  ///   ``Package/server(name:platforms:dependencies:framework:)``.
  public init(server: Package) {
    self.server = server
  }
}

extension PackageLayout where Self == ServerLayout {
  /// `<App>App` and the server, which both depend on `<App>Kit`.
  /// - Parameter server: The server package, made with
  ///   ``Package/server(name:platforms:dependencies:framework:)``.
  /// - Returns: The layout.
  public static func withServer(_ server: Package) -> ServerLayout {
    ServerLayout(server: server)
  }
}
