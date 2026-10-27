//
//  Platform.swift
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

/// An Apple platform an app or package supports, with its minimum version.
///
/// Build one with ``iOS(_:)``, ``macOS(_:)``, ``tvOS(_:)``, ``watchOS(_:)`` or
/// ``visionOS(_:)``. Leave the version out to get the default, 27.
public struct Platform: Sendable, Codable, Equatable {
  /// The platform's name, such as `"iOS"` or `"visionOS"`.
  public let name: String

  /// The platform's minimum version.
  public let minimumVersion: PlatformVersion

  private init(name: String, minimumVersion: PlatformVersion) {
    self.name = name
    self.minimumVersion = minimumVersion
  }

  /// iOS, at the given minimum version.
  ///
  /// - Parameter version: The minimum version. Defaults to 27.
  /// - Returns: The platform.
  public static func iOS(_ version: PlatformVersion = .v27) -> Platform {
    Platform(name: "iOS", minimumVersion: version)
  }

  /// macOS, at the given minimum version.
  ///
  /// - Parameter version: The minimum version. Defaults to 27.
  /// - Returns: The platform.
  public static func macOS(_ version: PlatformVersion = .v27) -> Platform {
    Platform(name: "macOS", minimumVersion: version)
  }

  /// tvOS, at the given minimum version.
  ///
  /// - Parameter version: The minimum version. Defaults to 27.
  /// - Returns: The platform.
  public static func tvOS(_ version: PlatformVersion = .v27) -> Platform {
    Platform(name: "tvOS", minimumVersion: version)
  }

  /// watchOS, at the given minimum version.
  ///
  /// - Parameter version: The minimum version. Defaults to 27.
  /// - Returns: The platform.
  public static func watchOS(_ version: PlatformVersion = .v27) -> Platform {
    Platform(name: "watchOS", minimumVersion: version)
  }

  /// visionOS, at the given minimum version.
  ///
  /// - Parameter version: The minimum version. Defaults to 27.
  /// - Returns: The platform.
  public static func visionOS(_ version: PlatformVersion = .v27) -> Platform {
    Platform(name: "visionOS", minimumVersion: version)
  }
}
