//
//  Dependency.swift
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

/// A package dependency: a third-party package as in SwiftPM's `Package.swift`, or one of the
/// app's own packages.
///
/// Write third-party dependencies as in SwiftPM: `.package(url:from:)`, `.package(url:exact:)`,
/// `.package(url:branch:)` and `.package(path:)`. A ``Package`` or a package name in
/// `dependencies:` becomes ``local(_:)``. See ``DependencyConvertible``.
public indirect enum Dependency: Sendable, Codable, Equatable {
  /// `.package(url:from:)`: a package from a URL, from `from` up to the next major version.
  case upToNextMajor(url: String, from: String)

  /// `.package(url:exact:)`: a package from a URL, at exactly `version`.
  case exact(url: String, version: String)

  /// `.package(url:branch:)`: a package from a URL, on the branch `name`.
  case branch(url: String, name: String)

  /// `.package(path:)`: a package on disk.
  case path(String)

  /// One of the app's own packages. taylr links its library for you.
  case local(Package)
}
