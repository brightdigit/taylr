//
//  GitHubActions.MatrixEntry+Spellings.swift
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

extension GitHubActions.MatrixEntry where Self == GitHubActions.SwiftEntry {
  /// A Swift version on Linux.
  /// - Parameter version: The Swift version, such as `"6.1"`.
  /// - Returns: The matrix entry.
  public static func swift(_ version: String) -> GitHubActions.SwiftEntry {
    GitHubActions.SwiftEntry(version: version)
  }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.LinuxEntry {
  /// Ubuntu 24.04 or 22.04.
  /// - Parameter release: The Ubuntu release.
  /// - Returns: The matrix entry.
  public static func linux(_ release: GitHubActions.Linux) -> GitHubActions.LinuxEntry {
    GitHubActions.LinuxEntry(release: release)
  }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.WasmEntry {
  /// WebAssembly.
  public static var wasm: GitHubActions.WasmEntry { GitHubActions.WasmEntry() }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.WasmEmbeddedEntry {
  /// Embedded Swift for WebAssembly.
  public static var wasmEmbedded: GitHubActions.WasmEmbeddedEntry {
    GitHubActions.WasmEmbeddedEntry()
  }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.WindowsEntry {
  /// Windows Server.
  /// - Parameter release: The Windows Server release.
  /// - Returns: The matrix entry.
  public static func windows(_ release: GitHubActions.Windows) -> GitHubActions.WindowsEntry {
    GitHubActions.WindowsEntry(release: release)
  }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.AndroidEntry {
  /// Android at an API level.
  /// - Parameter api: The API level, such as `34`.
  /// - Returns: The matrix entry.
  public static func android(api: Int) -> GitHubActions.AndroidEntry {
    GitHubActions.AndroidEntry(api: api)
  }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.XcodeVersionEntry {
  /// An Xcode version on GitHub's runners.
  /// - Parameter version: The Xcode version, such as `"26.4"`.
  /// - Returns: The matrix entry.
  public static func xcode(_ version: String) -> GitHubActions.XcodeVersionEntry {
    GitHubActions.XcodeVersionEntry(version: version)
  }
}

extension GitHubActions.MatrixEntry where Self == GitHubActions.XcodePathEntry {
  /// One of your `xcodes`, on your own Macs.
  /// - Parameter path: The path of one of the runners' `xcodes`.
  /// - Returns: The matrix entry.
  public static func xcode(path: String) -> GitHubActions.XcodePathEntry {
    GitHubActions.XcodePathEntry(path: path)
  }
}
