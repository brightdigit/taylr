//
//  CustomProfile+Signing.swift
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

extension CustomProfile {
  /// Where a custom profile's code-signing certificates are kept.
  public struct Signing: Sendable, Codable, Equatable {
    /// A place to keep code-signing certificates, such as `.git(…)` or `.s3(bucket:region:)`.
    public protocol Storage: ManifestValue where Serialization == StorageSerialization {}

    /// How a ``Storage`` is stored and encoded: one case per place.
    public enum StorageSerialization: Sendable, Codable, Equatable {
      /// A Git repository, by its URL.
      case git(url: String)
      /// An Amazon S3 bucket.
      case s3(bucket: String, region: String)  // swiftlint:disable:this identifier_name
      /// A Google Cloud Storage bucket.
      case googleCloudStorage(bucket: String)
      /// A GitLab project's secure files.
      case gitlabSecureFiles(project: String)
    }

    /// Where the certificates are kept.
    public let storage: StorageSerialization

    /// Creates the signing settings of a custom profile.
    ///
    /// - Parameter storage: Where the certificates are kept.
    public init(storage: any Storage) {
      self.storage = storage.serialization
    }
  }
}
