//
//  ManifestJSON.swift
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

public import Foundation

/// Reads and writes a manifest as JSON, the form `taylr` reads it in.
///
/// taylr loads a project's `Manifest.swift` by compiling it and running it. The file is only
/// `import TaylrDescription` and globals that end in `let manifest = App(...)` or
/// `let manifest = Package(...)`. taylr compiles it together with a driver `main.swift`:
///
/// ```swift
/// import TaylrDescription
///
/// try ManifestJSON.write(manifest)
/// ```
///
/// When the binary runs, it prints the manifest as JSON to standard output; taylr decodes that
/// with ``manifest(from:)``. Both directions use the same fixed settings: sorted keys, so equal
/// manifests print the same bytes.
///
/// ## JSON shape
///
/// Every enum with associated values encodes as an object with one key, the case name, whose
/// value is an object keyed by the case's labels: `{"file":{"path":"Scripts/header.mustache"}}`,
/// `{"reference":{"name":"default"}}`, `{"app":{"app":{…}}}`. Every associated value has a label,
/// so no `_0` key appears. A case without values encodes as an empty object, such as
/// `{"appOnly":{}}`, and a `String`-backed enum as its case name, such as `"swiftLint"`.
/// Protocol values, such as a ``Header`` or a ``ProfileSource``, are stored and encoded as their
/// serialization, such as ``HeaderSerialization``.
public enum ManifestJSON {
  /// The JSON for a manifest.
  /// - Parameter manifest: The manifest to encode.
  /// - Returns: The JSON, with sorted keys.
  /// - Throws: An `EncodingError` if the manifest can't be encoded.
  public static func data(for manifest: Manifest) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return try encoder.encode(manifest)
  }

  /// The manifest in some JSON.
  /// - Parameter data: JSON written by ``data(for:)`` or `write(_:)`.
  /// - Returns: The manifest.
  /// - Throws: A `DecodingError` if the data isn't a manifest.
  public static func manifest(from data: Data) throws -> Manifest {
    try JSONDecoder().decode(Manifest.self, from: data)
  }

  /// Prints a manifest as JSON to standard output, followed by a newline.
  /// - Parameter manifest: The manifest to print.
  /// - Throws: An `EncodingError` if the manifest can't be encoded.
  public static func write(_ manifest: Manifest) throws {
    var output = try data(for: manifest)
    output.append(0x0A)
    FileHandle.standardOutput.write(output)
  }

  /// Prints an app's manifest as JSON to standard output.
  ///
  /// This lets a driver call `write(manifest)` on `let manifest = App(...)` as it is.
  /// - Parameter app: The app to print.
  /// - Throws: An `EncodingError` if the app can't be encoded.
  public static func write(_ app: App) throws {
    try write(.app(app: app))
  }

  /// Prints a package's manifest as JSON to standard output.
  ///
  /// This lets a driver call `write(manifest)` on `let manifest = Package(...)` as it is.
  /// - Parameter package: The package to print.
  /// - Throws: An `EncodingError` if the package can't be encoded.
  public static func write(_ package: Package) throws {
    try write(.package(package: package))
  }
}
