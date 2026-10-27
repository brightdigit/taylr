//
//  GitHubActions+MatrixEntries.swift
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
  /// A Swift version on Linux, such as `.swift("6.1")`.
  public struct SwiftEntry: MatrixEntry {
    /// The Swift version.
    public var version: String
    /// The entry as ``MatrixEntrySerialization/swift(version:)``.
    public var serialization: MatrixEntrySerialization { .swift(version: version) }
    /// Creates the entry.
    /// - Parameter version: The Swift version.
    public init(version: String) { self.version = version }
  }

  /// An Ubuntu release, such as `.linux(.jammy)`.
  public struct LinuxEntry: MatrixEntry {
    /// The Ubuntu release.
    public var release: Linux
    /// The entry as ``MatrixEntrySerialization/linux(release:)``.
    public var serialization: MatrixEntrySerialization { .linux(release: release) }
    /// Creates the entry.
    /// - Parameter release: The Ubuntu release.
    public init(release: Linux) { self.release = release }
  }

  /// WebAssembly, spelled `.wasm`.
  public struct WasmEntry: MatrixEntry {
    /// The entry as ``MatrixEntrySerialization/wasm``.
    public var serialization: MatrixEntrySerialization { .wasm }
    /// Creates the entry.
    public init() {}
  }

  /// Embedded Swift for WebAssembly, spelled `.wasmEmbedded`.
  public struct WasmEmbeddedEntry: MatrixEntry {
    /// The entry as ``MatrixEntrySerialization/wasmEmbedded``.
    public var serialization: MatrixEntrySerialization { .wasmEmbedded }
    /// Creates the entry.
    public init() {}
  }

  /// A Windows Server release, such as `.windows(.v2025)`.
  public struct WindowsEntry: MatrixEntry {
    /// The Windows Server release.
    public var release: Windows
    /// The entry as ``MatrixEntrySerialization/windows(release:)``.
    public var serialization: MatrixEntrySerialization { .windows(release: release) }
    /// Creates the entry.
    /// - Parameter release: The Windows Server release.
    public init(release: Windows) { self.release = release }
  }

  /// Android at an API level, such as `.android(api: 34)`.
  public struct AndroidEntry: MatrixEntry {
    /// The API level.
    public var api: Int
    /// The entry as ``MatrixEntrySerialization/android(api:)``.
    public var serialization: MatrixEntrySerialization { .android(api: api) }
    /// Creates the entry.
    /// - Parameter api: The API level.
    public init(api: Int) { self.api = api }
  }

  /// An Xcode version on GitHub's runners, such as `.xcode("26.4")`.
  public struct XcodeVersionEntry: MatrixEntry {
    /// The Xcode version.
    public var version: String
    /// The entry as ``MatrixEntrySerialization/xcodeVersion(version:)``.
    public var serialization: MatrixEntrySerialization { .xcodeVersion(version: version) }
    /// Creates the entry.
    /// - Parameter version: The Xcode version.
    public init(version: String) { self.version = version }
  }

  /// One of your `xcodes`, on your own Macs, such as `.xcode(path: "/Applications/Xcode.app")`.
  public struct XcodePathEntry: MatrixEntry {
    /// The path of one of the runners' `xcodes`.
    public var path: String
    /// The entry as ``MatrixEntrySerialization/xcodePath(path:)``.
    public var serialization: MatrixEntrySerialization { .xcodePath(path: path) }
    /// Creates the entry.
    /// - Parameter path: The path of one of the runners' `xcodes`.
    public init(path: String) { self.path = path }
  }
}
