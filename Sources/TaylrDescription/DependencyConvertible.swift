//
//  DependencyConvertible.swift
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

/// A value that can appear in a package's `dependencies`: a ``Dependency``, a ``Package``, or a
/// string that names one of the app's packages.
///
/// Swift has no implicit conversion, so one array literal can only hold `models`,
/// `"AcmeUtilities"` and `.package(url:from:)` together if they share a protocol. This protocol is
/// that, and nothing more: it is not meant to be adopted by other types.
public protocol DependencyConvertible: Sendable {
  /// The dependency this value stands for. A ``Package`` and a string are `.local`.
  var dependency: Dependency { get }
}

extension Dependency: DependencyConvertible {
  /// A dependency is itself.
  public var dependency: Dependency { self }
}

extension Package: DependencyConvertible {
  /// A package is one of the app's own packages: `.local(self)`.
  public var dependency: Dependency { .local(self) }
}

extension String: DependencyConvertible {
  /// A string names one of the app's own packages: `.local(Package(name: self))`.
  public var dependency: Dependency { .local(Package(name: self)) }
}

extension DependencyConvertible where Self == Dependency {
  /// A package from a URL, at a version from `version` up to the next major version.
  /// - Parameters:
  ///   - url: The package's URL.
  ///   - version: The lowest version to use, such as `"1.1.0"`.
  /// - Returns: The dependency.
  public static func package(url: String, from version: String) -> Dependency {
    .upToNextMajor(url: url, from: version)
  }

  /// A package from a URL, at exactly one version.
  /// - Parameters:
  ///   - url: The package's URL.
  ///   - version: The version to use, such as `"1.6.1"`.
  /// - Returns: The dependency.
  public static func package(url: String, exact version: String) -> Dependency {
    .exact(url: url, version: version)
  }

  /// A package from a URL, on a branch.
  /// - Parameters:
  ///   - url: The package's URL.
  ///   - branch: The branch to track, such as `"main"`.
  /// - Returns: The dependency.
  public static func package(url: String, branch: String) -> Dependency {
    .branch(url: url, name: branch)
  }

  /// A package on disk.
  /// - Parameter path: The package's path, relative to the package that uses it.
  /// - Returns: The dependency.
  public static func package(path: String) -> Dependency {
    .path(path)
  }
}
