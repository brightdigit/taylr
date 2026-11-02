//
//  ManifestValue.swift
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

/// A value in a manifest that taylr reads back from its serialization.
///
/// Each manifest concept, such as ``Header``, is a protocol that refines `ManifestValue` and fixes
/// ``Serialization`` to one enum, such as ``HeaderSerialization``. Concrete types, such as
/// ``FileHeader``, conform to the concept. Models store the serialization rather than the value,
/// so they stay `Codable` and `Equatable`, and taylr handles every case of the enum.
public protocol ManifestValue: Sendable {
  /// The form this value is stored, encoded and compared in.
  associatedtype Serialization: Codable, Equatable, Sendable

  /// This value as its serialization.
  var serialization: Serialization { get }
}

extension ManifestValue {
  /// Whether two values serialize equally, even when they are of different types.
  ///
  /// - Parameters:
  ///   - lhs: A value.
  ///   - rhs: A value of the same concept, of this type or another.
  /// - Returns: `true` when both values have the same serialization.
  public static func serializesEqually<Other: ManifestValue>(_ lhs: Self, _ rhs: Other) -> Bool
  where Other.Serialization == Serialization {
    lhs.serialization == rhs.serialization
  }
}
