//
//  CI+MatrixEntry.swift
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

extension CI {
  /// One build in a ``Matrix``.
  ///
  /// `.xcode("26.4")` and `.xcode(path:)` are static functions over the `xcodeVersion` and
  /// `xcodePath` cases, because two enum cases can't share the name `xcode`.
  public enum MatrixEntry: Sendable, Codable, Equatable {
    /// A Swift version on Linux, such as `.swift("6.1")`.
    case swift(String)
    /// Ubuntu 24.04 or 22.04.
    case linux(Linux)
    /// WebAssembly.
    case wasm
    /// Embedded Swift for WebAssembly.
    case wasmEmbedded
    /// Windows Server.
    case windows(Windows)
    /// Android at an API level, such as `.android(api: 34)`.
    case android(api: Int)
    /// An Xcode version on GitHub's runners. Spelled `.xcode("26.4")`.
    case xcodeVersion(String)
    /// One of your `xcodes`, on your own Macs. Spelled `.xcode(path:)`.
    case xcodePath(String)

    /// An Ubuntu release.
    public enum Linux: String, Sendable, Codable, Equatable {
      /// Ubuntu 24.04.
      case noble
      /// Ubuntu 22.04.
      case jammy
    }

    /// A Windows Server release.
    public enum Windows: String, Sendable, Codable, Equatable {
      /// Windows Server 2022.
      case v2022
      /// Windows Server 2025.
      case v2025
    }

    /// An Xcode version on GitHub's runners.
    ///
    /// - Parameter version: The Xcode version, such as `"26.4"`.
    /// - Returns: The matrix entry.
    public static func xcode(_ version: String) -> MatrixEntry {
      .xcodeVersion(version)
    }

    /// One of your `xcodes`, on your own Macs.
    ///
    /// - Parameter path: The path of one of the runners' `xcodes`.
    /// - Returns: The matrix entry.
    public static func xcode(path: String) -> MatrixEntry {
      .xcodePath(path)
    }

  }
}
