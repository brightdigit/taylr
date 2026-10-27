//
//  LintTool.swift
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

/// A lint tool that taylr installs, configures and runs for a project.
///
/// Listing a tool in a manifest's `lint` array installs it and gives it a configuration file.
/// A tool left out of the array is not installed and has no configuration file.
public enum LintTool: String, CaseIterable, Sendable, Codable, Equatable {
  /// Style and conventions, with SwiftLint.
  case swiftLint
  /// Formatting, with Apple's swift-format.
  case swiftFormat
  /// Unused code, with Periphery.
  case periphery

  private static let configurationFiles: [LintTool: String] = [
    .swiftLint: ".swiftlint.yml",
    .swiftFormat: ".swift-format",
    .periphery: ".periphery.yml",
  ]

  /// The name of the file that configures the tool: `.swiftlint.yml`, `.swift-format` or
  /// `.periphery.yml`.
  public var configurationFile: String {
    guard let file = Self.configurationFiles[self] else {
      assertionFailure("No configuration file for \(self)")
      return ".\(rawValue)"
    }
    return file
  }
}
