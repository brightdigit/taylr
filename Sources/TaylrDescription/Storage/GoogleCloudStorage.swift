//
//  GoogleCloudStorage.swift
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

/// Files kept in a Google Cloud Storage bucket.
public struct GoogleCloudStorage: Storage {
  /// The bucket.
  public var bucket: String
  /// The storage as ``StorageSerialization/googleCloudStorage(bucket:)``.
  public var serialization: StorageSerialization { .googleCloudStorage(bucket: bucket) }
  /// Creates the storage.
  /// - Parameter bucket: The bucket.
  public init(bucket: String) { self.bucket = bucket }
}

extension Storage where Self == GoogleCloudStorage {
  /// A Google Cloud Storage bucket.
  /// - Parameter bucket: The bucket.
  /// - Returns: The storage.
  public static func googleCloudStorage(bucket: String) -> GoogleCloudStorage {
    GoogleCloudStorage(bucket: bucket)
  }
}
