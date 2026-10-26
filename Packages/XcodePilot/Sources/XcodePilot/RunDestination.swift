//
//  RunDestination.swift
//  XcodePilot
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

/// The destination to run a scheme on, matched against what `xcodebuild` reports.
///
/// The first non-`nil` of ``arch``, ``operatingSystem`` and ``name`` decides the
/// match, together with ``platform``.
public struct RunDestination: Sendable {
  internal let arch: String?
  internal let platform: String
  internal let name: String?
  internal let operatingSystem: String?

  /// Creates a run destination.
  ///
  /// - Parameters:
  ///   - arch: The architecture, such as `arm64`.
  ///   - platform: The platform, such as `macOS` or `iOS Simulator`.
  ///   - name: The device name, such as `iPhone 17 Pro`.
  ///   - operatingSystem: The OS version, such as `26.0`.
  public init(
    arch: String? = nil,
    platform: String,
    name: String? = nil,
    operatingSystem: String? = nil
  ) {
    self.arch = arch
    self.platform = platform
    self.name = name
    self.operatingSystem = operatingSystem
  }

  /// Finds the first destination on the same platform that matches this one.
  internal func firstMatch(in destinations: [Destination]) -> Destination? {
    destinations.first { candidate in
      candidate.platform == platform && matches(candidate)
    }
  }

  private func matches(_ candidate: Destination) -> Bool {
    if let arch {
      return arch == candidate.arch
    }
    if let operatingSystem {
      return operatingSystem == candidate.operatingSystem
    }
    if let name {
      return name == candidate.name
    }
    return arch == candidate.arch
      && operatingSystem == candidate.operatingSystem
      && name == candidate.name
  }
}
