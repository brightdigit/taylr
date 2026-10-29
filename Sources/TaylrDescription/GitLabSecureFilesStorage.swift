//
//  GitLabSecureFilesStorage.swift
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

/// Files kept in a GitLab project's secure files.
public struct GitLabSecureFilesStorage: Storage {
  /// The project, such as `acme/certs`.
  public var project: String
  /// The storage as ``StorageSerialization/gitlabSecureFiles(project:)``.
  public var serialization: StorageSerialization { .gitlabSecureFiles(project: project) }
  /// Creates the storage.
  /// - Parameter project: The project.
  public init(project: String) { self.project = project }
}

extension Storage where Self == GitLabSecureFilesStorage {
  /// A GitLab project's secure files.
  /// - Parameter project: The project, such as `acme/certs`.
  /// - Returns: The storage.
  public static func gitlabSecureFiles(project: String) -> GitLabSecureFilesStorage {
    GitLabSecureFilesStorage(project: project)
  }
}
