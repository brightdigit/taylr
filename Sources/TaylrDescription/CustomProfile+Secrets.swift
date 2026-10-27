//
//  CustomProfile+Secrets.swift
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
  /// Where a custom profile's secrets come from: `.team()`, `.profile(_:)` or `.environment`.
  ///
  /// Secrets are never in the manifest. They stay in the user's Keychain, filed under one of
  /// their named profiles.
  public protocol Secrets: ManifestValue where Serialization == SecretsSerialization {}

  /// How ``Secrets`` are stored and encoded: one case per source.
  public enum SecretsSerialization: Sendable, Codable, Equatable {
    /// The named profile with the same `apple.teamID`, or the named profile for `teamID`.
    case team(teamID: String?)
    /// The named profile of that name.
    case profile(name: String)
    /// Environment variables only. Nothing is read from the Keychain.
    case environment
  }

  /// Secrets from the named profile for a team.
  public struct TeamSecrets: Secrets {
    /// The team ID, or `nil` for the profile's own `apple.teamID`.
    public var teamID: String?
    /// The secrets as ``SecretsSerialization/team(teamID:)``.
    public var serialization: SecretsSerialization { .team(teamID: teamID) }
    /// Creates the secrets source.
    /// - Parameter teamID: The team ID, or `nil` for the profile's own `apple.teamID`.
    public init(teamID: String?) { self.teamID = teamID }
  }

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

  /// Secrets from environment variables only.
  public struct EnvironmentSecrets: Secrets {
    /// The secrets as ``SecretsSerialization/environment``.
    public var serialization: SecretsSerialization { .environment }
    /// Creates the secrets source.
    public init() {}
  }
}

extension CustomProfile.Secrets where Self == CustomProfile.TeamSecrets {
  /// The named profile with the same `apple.teamID`, or, with a team ID, the named profile for
  /// that team.
  /// - Parameter teamID: The team ID. Defaults to `nil`, the profile's own `apple.teamID`.
  /// - Returns: The secrets source.
  public static func team(_ teamID: String? = nil) -> CustomProfile.TeamSecrets {
    CustomProfile.TeamSecrets(teamID: teamID)
  }
}

extension CustomProfile.Secrets where Self == CustomProfile.ProfileSecrets {
  /// The named profile of that name.
  /// - Parameter name: The named profile, such as `"client-x"`.
  /// - Returns: The secrets source.
  public static func profile(_ name: String) -> CustomProfile.ProfileSecrets {
    CustomProfile.ProfileSecrets(name: name)
  }
}

extension CustomProfile.Secrets where Self == CustomProfile.EnvironmentSecrets {
  /// Environment variables only. Nothing is read from the Keychain.
  public static var environment: CustomProfile.EnvironmentSecrets {
    CustomProfile.EnvironmentSecrets()
  }
}
