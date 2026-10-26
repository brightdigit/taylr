//
//  Destination.swift
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

import Foundation

/// One run destination as `xcodebuild -showdestinations` prints it.
internal struct Destination: CustomStringConvertible, Equatable {
  /// The text every destination line in `-showdestinations` output contains.
  internal static let destinationPrefix = "{ platform:"

  internal let platform: String
  internal let arch: String?
  internal let id: String?
  internal let name: String
  internal let operatingSystem: String?
  internal let variant: String?

  /// The destination specifier `xcodebuild` and Xcode's `debug` command accept.
  internal var description: String {
    var components: [String] = ["platform:\(platform)"]

    if let arch {
      components.append("arch:\(arch)")
    }

    if let variant {
      components.append("variant:\(variant)")
    }

    if let id {
      components.append("id:\(id)")
    }

    if let operatingSystem {
      components.append("OS:\(operatingSystem)")
    }

    components.append("name:\(name)")

    return components.joined(separator: ", ")
  }

  internal init(
    platform: String,
    arch: String? = nil,
    id: String? = nil,
    name: String,
    operatingSystem: String? = nil,
    variant: String? = nil
  ) {
    self.platform = platform
    self.arch = arch
    self.id = id
    self.name = name
    self.operatingSystem = operatingSystem
    self.variant = variant
  }

  /// Parses one line of `-showdestinations` output, or fails when the line is
  /// not a destination or has no platform or name.
  ///
  /// - Parameter line: A line such as `{ platform:macOS, arch:arm64, name:My Mac }`.
  internal init?(line: String) {
    guard line.contains(Self.destinationPrefix) else {
      return nil
    }

    let fields = Self.fields(in: line)

    guard let platform = fields["platform"], let name = fields["name"] else {
      return nil
    }

    self.init(
      platform: platform,
      arch: fields["arch"],
      id: fields["id"],
      name: name,
      operatingSystem: fields["OS"],
      variant: fields["variant"]
    )
  }

  /// Parses every destination in the output of `xcodebuild -showdestinations`.
  ///
  /// Lines that are not destinations are skipped. Ineligible destinations are
  /// included, since they share the same format.
  ///
  /// - Parameter output: The complete standard output of `xcodebuild`.
  /// - Returns: The destinations in the order `xcodebuild` printed them.
  internal static func parseFrom(output: String) -> [Destination] {
    output.components(separatedBy: .newlines).compactMap(Destination.init(line:))
  }

  /// Splits a `{ key:value, key:value }` line into its fields.
  ///
  /// Only the first colon separates a key from its value, so values such as
  /// `dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder` stay whole.
  private static func fields(in line: String) -> [String: String] {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    guard trimmed.hasPrefix("{"), trimmed.hasSuffix("}") else {
      return [:]
    }

    var fields: [String: String] = [:]
    for component in components(of: trimmed.dropFirst().dropLast()) {
      let pair = component.split(separator: ":", maxSplits: 1)
      guard pair.count == 2 else {
        continue
      }
      let key = pair[0].trimmingCharacters(in: .whitespaces)
      fields[key] = pair[1].trimmingCharacters(in: .whitespaces)
    }
    return fields
  }

  /// Splits on commas outside square brackets, so a value such as
  /// `Designed for [iPad,iPhone]` stays whole.
  private static func components(of body: Substring) -> [Substring] {
    var components: [Substring] = []
    var depth = 0
    var start = body.startIndex

    for index in body.indices {
      switch body[index] {
      case "[":
        depth += 1
      case "]":
        depth -= 1
      case "," where depth == 0:
        components.append(body[start..<index])
        start = body.index(after: index)
      default:
        break
      }
    }

    components.append(body[start...])
    return components
  }
}
