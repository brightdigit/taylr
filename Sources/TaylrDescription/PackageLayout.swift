//
//  PackageLayout.swift
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
/// ``Packages/init(client:server:others:)``. Models store a ``PackageLayoutSerialization``; call
/// ``resolvedPackages(appName:)`` for the whole graph.
public protocol PackageLayout: ManifestValue where Serialization == PackageLayoutSerialization {}

extension PackageLayout {
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
    try serialization.resolvedPackages(appName: appName)
  }
}
