//
//  ServerFramework.swift
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

/// The framework a server package is built on, and how it routes requests.
///
/// Pass one as the `framework` of ``Package/server(name:platforms:dependencies:framework:)``.
public enum ServerFramework: Sendable, Codable, Equatable {
  /// A [Hummingbird](https://hummingbird.codes) server.
  /// - Parameter routing: How routes are written. Defaults to ``Routing-swift.enum/builtIn``.
  case hummingbird(routing: Routing = .builtIn)

  /// How a server's routes are written.
  public enum Routing: String, Sendable, Codable, Equatable {
    /// You write the routes with the framework's own router.
    case builtIn

    /// The API is described in `openapi.yaml` and its code is generated.
    case openAPI
  }
}
