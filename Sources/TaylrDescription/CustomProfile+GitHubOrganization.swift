//
//  CustomProfile+GitHubOrganization.swift
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
  /// The GitHub organization of a custom profile and how CI secrets are shared.
  public struct GitHubOrganization: Sendable, Codable, Equatable {
    /// How CI secrets are shared with GitHub.
    public enum CISecrets: String, Sendable, Codable, Equatable {
      /// Shared as organization secrets.
      case organization
      /// Shared as repository secrets.
      case repository
      /// Not shared.
      case skip
    }

    /// The GitHub organization. `nil` means the user's own account.
    public let org: String?
    /// How CI secrets are shared. `nil` means none.
    public let ciSecrets: CISecrets?

    /// Creates the GitHub settings of a custom profile.
    ///
    /// - Parameters:
    ///   - org: The GitHub organization.
    ///   - ciSecrets: How CI secrets are shared.
    public init(org: String? = nil, ciSecrets: CISecrets? = nil) {
      self.org = org
      self.ciSecrets = ciSecrets
    }
  }
}
