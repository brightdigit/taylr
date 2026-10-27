//
//  PlatformVersion.swift
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

/// A minimum platform version, such as `.v27` or `"27.2"`.
///
/// Versions are normalized so that equal versions compare equal however they are written:
/// trailing `.0` components are dropped, so `"27"`, `"27.0"` and ``v27`` are the same version.
/// A version encodes as a single string, such as `"27"` or `"27.2"`.
public struct PlatformVersion: Sendable, Codable, Equatable, ExpressibleByStringLiteral {
  /// Version 27, the default minimum version of every platform.
  public static let v27: PlatformVersion = "27"

  /// The normalized version string, such as `"27"` or `"27.2"`.
  public let rawValue: String

  /// Creates a version from a string such as `"27.2"`.
  ///
  /// - Parameter value:The version, with dot-separated numeric components.
  public init(stringLiteral value: String) {
    var components = value.split(separator: ".", omittingEmptySubsequences: false)
    while components.count > 1, components.last == "0" {
      components.removeLast()
    }
    self.rawValue = components.joined(separator: ".")
  }

  /// Decodes a version from a single string.
  ///
  /// - Parameter decoder: The decoder to read from.
  /// - Throws: An error if the value is not a string.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(stringLiteral: try container.decode(String.self))
  }

  /// Encodes the version as a single string.
  ///
  /// - Parameter encoder: The encoder to write to.
  /// - Throws: An error if encoding fails.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
