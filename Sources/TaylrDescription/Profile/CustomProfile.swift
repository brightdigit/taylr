//
//  CustomProfile.swift
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

/// A profile spelled out in the manifest, so the app doesn't depend on anyone's `~/.taylr/`.
///
/// Spell it `.organization("Client X Inc", …)`.
public struct CustomProfile: ProfileSource, Codable, Equatable {
  /// The organization's name, used in bundle IDs, the license and file headers.
  public var organization: String
  /// The start of the app's bundle ID, or `nil` to derive it from ``organization``.
  public var bundleIDPrefix: String?
  /// The Apple team, or `nil` to leave it to the user's `config.yml`.
  public var apple: AppleTeam?
  /// Where the code-signing certificates are kept.
  public var signing: Signing?
  /// The GitHub organization and how CI secrets are shared, or `nil` for the user's own account.
  public var github: GitHubOrganization?
  /// Where the secrets come from.
  public var secrets: SecretsSerialization

  /// The profile as ``ProfileSerialization/custom(profile:)``.
  public var serialization: ProfileSerialization { .custom(profile: self) }

  /// The bundle ID prefix the profile resolves to.
  ///
  /// This is the ``bundleIDPrefix`` as written, or `com.` and the organization's name lowercased
  /// with everything but letters and digits removed.
  public var resolvedBundleIDPrefix: String {
    if let bundleIDPrefix {
      return bundleIDPrefix
    }
    let name = organization.lowercased().filter { $0.isLetter || $0.isNumber }
    return "com.\(name)"
  }

  /// Spells a profile out in the manifest.
  ///
  /// - Parameters:
  ///   - organization: The organization's name, used in bundle IDs, the license and file headers.
  ///   - bundleIDPrefix: The start of the app's bundle ID. When `nil`, it is `com.` and the
  ///     organization's name, lowercased, without spaces or punctuation.
  ///   - apple: The Apple team. `nil` leaves it to the user's `config.yml`.
  ///   - signing: Where the code-signing certificates are kept.
  ///   - github: The GitHub organization and how CI secrets are shared. `nil` means the user's own
  ///     account.
  ///   - secrets: Where the secrets come from. Defaults to `.team()`, with no team.
  public init(
    organization: String,
    bundleIDPrefix: String? = nil,
    apple: AppleTeam? = nil,
    signing: Signing? = nil,
    github: GitHubOrganization? = nil,
    secrets: any Secrets = .team()
  ) {
    self.organization = organization
    self.bundleIDPrefix = bundleIDPrefix
    self.apple = apple
    self.signing = signing
    self.github = github
    self.secrets = secrets.serialization
  }
}

extension ProfileSource where Self == CustomProfile {
  /// Spells a profile out in the manifest, for an organization.
  ///
  /// - Parameters:
  ///   - name: The organization's name, used in bundle IDs, the license and file headers.
  ///   - bundleIDPrefix: The start of the app's bundle ID. When `nil`, it is `com.` and the
  ///     organization's name, lowercased, without spaces or punctuation.
  ///   - apple: The Apple team. `nil` leaves it to the user's `config.yml`.
  ///   - signing: Where the code-signing certificates are kept.
  ///   - github: The GitHub organization and how CI secrets are shared. `nil` means the user's own
  ///     account.
  ///   - secrets: Where the secrets come from. Defaults to `.team()`, with no team.
  /// - Returns: The profile.
  public static func organization(
    _ name: String,
    bundleIDPrefix: String? = nil,
    apple: AppleTeam? = nil,
    signing: Signing? = nil,
    github: GitHubOrganization? = nil,
    secrets: any Secrets = .team()
  ) -> CustomProfile {
    CustomProfile(
      organization: name,
      bundleIDPrefix: bundleIDPrefix,
      apple: apple,
      signing: signing,
      github: github,
      secrets: secrets
    )
  }
}
