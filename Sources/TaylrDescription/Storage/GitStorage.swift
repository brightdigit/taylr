//
//  GitStorage.swift
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

/// Files kept in a Git repository.
public struct GitStorage: Storage {
  /// The repository's URL.
  public var url: String
  /// The storage as ``StorageSerialization/git(url:)``.
  public var serialization: StorageSerialization { .git(url: url) }
  /// Creates the storage.
  /// - Parameter url: The repository's URL.
  public init(url: String) { self.url = url }
}

extension Storage where Self == GitStorage {
  /// A Git repository, by its URL.
  /// - Parameter url: The repository's URL.
  /// - Returns: The storage.
  public static func git(_ url: String) -> GitStorage {
    GitStorage(url: url)
  }
}
