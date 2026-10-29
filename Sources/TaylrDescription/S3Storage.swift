//
//  S3Storage.swift
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

/// Files kept in an Amazon S3 bucket.
public struct S3Storage: Storage {
  /// The bucket.
  public var bucket: String
  /// The bucket's region, such as `us-east-1`.
  public var region: String
  /// The storage as ``StorageSerialization/s3(bucket:region:)``.
  public var serialization: StorageSerialization { .s3(bucket: bucket, region: region) }
  /// Creates the storage.
  /// - Parameters:
  ///   - bucket: The bucket.
  ///   - region: The bucket's region.
  public init(bucket: String, region: String) {
    self.bucket = bucket
    self.region = region
  }
}

extension Storage where Self == S3Storage {
  /// An Amazon S3 bucket.
  /// - Parameters:
  ///   - bucket: The bucket.
  ///   - region: The bucket's region, such as `us-east-1`.
  /// - Returns: The storage.
  public static func s3(bucket: String, region: String) -> S3Storage {
    S3Storage(bucket: bucket, region: region)
  }
}
