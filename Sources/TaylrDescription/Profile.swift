//
//  Profile.swift
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

/// The Apple, signing, GitHub and secrets settings an app is built with.
///
/// Name a profile kept in `~/.taylr/profiles/` with ``named(_:)``, or spell one out with
/// ``init(organization:bundleIDPrefix:apple:signing:github:secrets:)`` so the app doesn't depend
/// on anyone's `~/.taylr/`.
public enum Profile: Sendable, Codable, Equatable {
  /// A profile named in `~/.taylr/profiles/`.
  case named(String)

  /// A profile spelled out in the manifest.
  ///
  /// Prefer ``init(organization:bundleIDPrefix:apple:signing:github:secrets:)``, which reads the
  /// same way as the reference.
  case inline(  // swiftlint:disable:this enum_case_associated_values_count
    organization: String,
    bundleIDPrefix: String?,
    apple: Apple?,
    signing: Signing?,
    github: GitHubOrganization?,
    secrets: Secrets
  )

  /// The Apple team of an inline profile.
  public struct Apple: Sendable, Codable, Equatable {
    /// The Apple Developer Team ID. Needed to sign.
    public let teamID: String?
    /// The Apple ID for App Store Connect. Usually left out, so each person's own comes from
    /// their `config.yml`.
    public let appleID: String?
    /// The App Store Connect team ID, if the Apple ID belongs to more than one team.
    public let ascTeamID: String?

    /// Creates the Apple team of an inline profile.
    ///
    /// - Parameters:
    ///   - teamID: The Apple Developer Team ID.
    ///   - appleID: The Apple ID for App Store Connect.
    ///   - ascTeamID: The App Store Connect team ID.
    public init(teamID: String? = nil, appleID: String? = nil, ascTeamID: String? = nil) {
      self.teamID = teamID
      self.appleID = appleID
      self.ascTeamID = ascTeamID
    }
  }

  /// Where an inline profile's code-signing certificates are kept.
  public struct Signing: Sendable, Codable, Equatable {
    /// A place to keep code-signing certificates.
    public enum Storage: Sendable, Codable, Equatable {
      /// A Git repository, by its URL.
      case git(String)
      /// An Amazon S3 bucket.
      case s3(bucket: String, region: String)
      /// A Google Cloud Storage bucket.
      case googleCloudStorage(bucket: String)
      /// A GitLab project's secure files.
      case gitlabSecureFiles(project: String)
    }

    /// Where the certificates are kept.
    public let storage: Storage

    /// Creates the signing settings of an inline profile.
    ///
    /// - Parameter storage: Where the certificates are kept.
    public init(storage: Storage) {
      self.storage = storage
    }
  }

  /// The GitHub organization of an inline profile and how CI secrets are shared.
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

    /// Creates the GitHub settings of an inline profile.
    ///
    /// - Parameters:
    ///   - org: The GitHub organization.
    ///   - ciSecrets: How CI secrets are shared.
    public init(org: String? = nil, ciSecrets: CISecrets? = nil) {
      self.org = org
      self.ciSecrets = ciSecrets
    }
  }

  /// Where an inline profile's secrets come from.
  ///
  /// Secrets are never in the manifest. They stay in the user's Keychain, filed under one of
  /// their named profiles.
  public enum Secrets: Sendable, Codable, Equatable {
    /// The named profile with the same `apple.teamID`, or, with a team ID, the named profile for
    /// that team.
    case team(String? = nil)
    /// The named profile of that name.
    case profile(String)
    /// Environment variables only. Nothing is read from the Keychain.
    case environment
  }

  /// The bundle ID prefix an inline profile resolves to.
  ///
  /// This is the `bundleIDPrefix` as written, or `com.` and the organization's name lowercased
  /// with everything but letters and digits removed. It is `nil` for a ``named(_:)`` profile,
  /// whose prefix lives in the profile file.
  public var resolvedBundleIDPrefix: String? {
    guard case .inline(let organization, let bundleIDPrefix, _, _, _, _) = self else {
      return nil
    }
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
  ///   - secrets: Where the secrets come from. Defaults to ``Secrets/team(_:)`` with no team.
  public init(
    organization: String,
    bundleIDPrefix: String? = nil,
    apple: Apple? = nil,
    signing: Signing? = nil,
    github: GitHubOrganization? = nil,
    secrets: Secrets = .team()
  ) {
    self = .inline(
      organization: organization,
      bundleIDPrefix: bundleIDPrefix,
      apple: apple,
      signing: signing,
      github: github,
      secrets: secrets
    )
  }
}
