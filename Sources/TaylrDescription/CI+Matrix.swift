//
//  CI+Matrix.swift
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
  /// Builds to add to, or leave out of, what `.ci` builds on each kind of change.
  ///
  /// Something you include runs in that build and the bigger ones: included in `feature`, it also
  /// runs in `version` and `main`. Something you exclude is only left out of the build you name.
  public struct Matrix: Sendable, Codable, Equatable {
    /// The builds to include in, and exclude from, one of the standard builds.
    public struct Entries: Sendable, Codable, Equatable {
      /// Builds to add.
      public var include: [MatrixEntry]
      /// Builds to leave out.
      public var exclude: [MatrixEntry]

      /// Creates a set of entries. Both default to empty.
      ///
      /// - Parameters:
      ///   - include: Builds to add.
      ///   - exclude: Builds to leave out.
      public init(include: [MatrixEntry] = [], exclude: [MatrixEntry] = []) {
        self.include = include
        self.exclude = exclude
      }
    }

    /// Changes for a pull request into any other branch.
    public var feature: Entries
    /// Changes for a pull request into, or a push to, a version branch.
    public var version: Entries
    /// Changes for a pull request into, or a push to, `main`, or a run from the Actions tab.
    public var main: Entries

    /// Creates a matrix. Every build defaults to no changes.
    ///
    /// - Parameters:
    ///   - feature: Changes to the `feature` build.
    ///   - version: Changes to the `version` build.
    ///   - main: Changes to the `main` build.
    public init(
      feature: Entries = Entries(),
      version: Entries = Entries(),
      main: Entries = Entries()
    ) {
      self.feature = feature
      self.version = version
      self.main = main
    }

  }
}
