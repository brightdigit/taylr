//
//  ProfileSecrets.swift
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

/// Secrets from the named profile of that name.
public struct ProfileSecrets: Secrets {
  /// The named profile.
  public var name: String
  /// The secrets as ``SecretsSerialization/profile(name:)``.
  public var serialization: SecretsSerialization { .profile(name: name) }
  /// Creates the secrets source.
  /// - Parameter name: The named profile.
  public init(name: String) { self.name = name }
}

extension Secrets where Self == ProfileSecrets {
  /// The named profile of that name.
  /// - Parameter name: The named profile, such as `"client-x"`.
  /// - Returns: The secrets source.
  public static func profile(_ name: String) -> ProfileSecrets {
    ProfileSecrets(name: name)
  }
}
