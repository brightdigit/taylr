//
//  GitHubActions+MatrixEntry.swift
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

extension GitHubActions {
  /// One build in a ``Matrix``, such as `.linux(.jammy)` or `.xcode("26.4")`.
  public protocol MatrixEntry: ManifestValue where Serialization == MatrixEntrySerialization {}

  /// How a ``MatrixEntry`` is stored and encoded: one case per kind of build.
  public enum MatrixEntrySerialization: Sendable, Codable, Equatable {
    /// A Swift version on Linux.
    case swift(version: String)
    /// An Ubuntu release.
    case linux(release: Linux)
    /// WebAssembly.
    case wasm
    /// Embedded Swift for WebAssembly.
    case wasmEmbedded
    /// A Windows Server release.
    case windows(release: Windows)
    /// Android at an API level.
    case android(api: Int)
    /// An Xcode version on GitHub's runners.
    case xcodeVersion(version: String)
    /// One of your `xcodes`, on your own Macs, by path.
    case xcodePath(path: String)
  }

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
}
