import Foundation
import Testing

@testable import TaylrDescription

@Suite("Profile")
internal enum ProfileTests {
  @Suite("resolvedBundleIDPrefix")
  internal struct PrefixTests {
    private static let cases: [(String, String)] = [
      ("Acme Corp", "com.acmecorp"),
      ("Acme, Corp.", "com.acmecorp"),
      ("Acme 42 Inc", "com.acme42inc"),
      ("A-B_C!", "com.abc"),
    ]

    @Test("The prefix is com. and the lowercased organization without punctuation")
    internal func derivesPrefix() {
      for (organization, expected) in Self.cases {
        #expect(CustomProfile(organization: organization).resolvedBundleIDPrefix == expected)
      }
    }

    @Test("A written prefix is kept")
    internal func keepsWrittenPrefix() {
      let profile = CustomProfile(organization: "Client X Inc", bundleIDPrefix: "com.clientx")
      #expect(profile.resolvedBundleIDPrefix == "com.clientx")
      #expect(profile.serialization.resolvedBundleIDPrefix == "com.clientx")
    }

    @Test("A named profile has no resolved prefix")
    internal func namedHasNone() {
      #expect(ProfileReference.named("client-x").serialization.resolvedBundleIDPrefix == nil)
    }
  }

  @Suite("Reference example")
  internal struct ReferenceTests {
    private static let named: any ProfileSource = .named("client-x")
    private static let custom: any ProfileSource = .organization(
      "Client X Inc",
      bundleIDPrefix: "com.clientx",
      apple: .init(teamID: "FGHIJ67890", ascTeamID: "7654321"),
      signing: .init(storage: .git("git@github.com:clientx/certs.git")),
      github: .init(org: "clientx")
    )

    @Test("Both spellings compile and round-trip")
    internal func roundTrips() throws {
      #expect(try ProfileTests.roundTrip(Self.named.serialization) == Self.named.serialization)
      #expect(try ProfileTests.roundTrip(Self.custom.serialization) == Self.custom.serialization)
    }

    @Test("A custom profile and its spelled-out type serialize equally")
    internal func customMatchesInit() {
      let profile = CustomProfile(
        organization: "Client X Inc",
        bundleIDPrefix: "com.clientx",
        apple: .init(teamID: "FGHIJ67890", ascTeamID: "7654321"),
        signing: .init(storage: .git("git@github.com:clientx/certs.git")),
        github: .init(org: "clientx")
      )
      #expect(profile.serialization == Self.custom.serialization)
    }

    @Test("Omitted fields take their defaults")
    internal func defaults() {
      let profile = CustomProfile(organization: "Acme Corp")
      #expect(profile.bundleIDPrefix == nil)
      #expect(profile.apple == nil)
      #expect(profile.signing == nil)
      #expect(profile.github == nil)
      #expect(profile.secrets == .team(teamID: nil))
    }
  }

  @Suite("Encoding JSON")
  internal struct EncodingTests {
    private static let namedJSON = #"{"reference":{"name":"client-x"}}"#
    private static let customJSON = """
      {"custom":{"profile":{"organization":"Acme Corp","bundleIDPrefix":"com.acmecorp",\
      "apple":{"teamID":"ABCDE12345"},\
      "signing":{"storage":{"s3":{"bucket":"acme-certs","region":"us-east-1"}}},\
      "github":{"org":"acme","ciSecrets":"skip"},\
      "secrets":{"profile":{"name":"acme"}}}}}
      """

    @Test(".named decodes from JSON")
    internal func decodesNamed() throws {
      let data = Data(Self.namedJSON.utf8)
      let profile = try JSONDecoder().decode(ProfileSerialization.self, from: data)
      #expect(profile == ProfileReference.named("client-x").serialization)
    }

    @Test("A custom profile decodes from JSON")
    internal func decodesCustom() throws {
      let data = Data(Self.customJSON.utf8)
      let profile = try JSONDecoder().decode(ProfileSerialization.self, from: data)
      let expected = CustomProfile.organization(
        "Acme Corp",
        bundleIDPrefix: "com.acmecorp",
        apple: .init(teamID: "ABCDE12345"),
        signing: .init(storage: .s3(bucket: "acme-certs", region: "us-east-1")),
        github: .init(org: "acme", ciSecrets: .skip),
        secrets: .profile("acme")
      ).serialization
      #expect(profile == expected)
      #expect(try ProfileTests.roundTrip(profile) == expected)
    }

    @Test("A named profile encodes with labeled keys")
    internal func encodesNamed() throws {
      let data = try JSONEncoder().encode(ProfileReference.named("client-x").serialization)
      #expect(String(decoding: data, as: UTF8.self) == Self.namedJSON)
    }
  }

  @Suite("Cases")
  internal struct CaseTests {
    private static let storages: [any CustomProfile.Signing.Storage] = [
      .git("git@github.com:acme/certs.git"),
      .s3(bucket: "acme-certs", region: "us-east-1"),
      .googleCloudStorage(bucket: "acme-certs"),
      .gitlabSecureFiles(project: "acme/certs"),
    ]
    private static let ciSecrets: [CustomProfile.GitHubOrganization.CISecrets] = [
      .organization, .repository, .skip,
    ]
    private static let secrets: [any CustomProfile.Secrets] = [
      .team(), .team("ABCDE12345"), .profile("acme"), .environment,
    ]

    @Test("Every Storage case round-trips with labeled keys")
    internal func storagesRoundTrip() throws {
      for value in Self.storages.map({ $0.serialization }) {
        #expect(try ProfileTests.roundTrip(value) == value)
        let data = try JSONEncoder().encode(value)
        #expect(!String(decoding: data, as: UTF8.self).contains("_0"))
      }
    }

    @Test("Every CISecrets case round-trips as a plain string")
    internal func ciSecretsRoundTrip() throws {
      for value in Self.ciSecrets {
        #expect(try ProfileTests.roundTrip(value) == value)
      }
      let data = try JSONEncoder().encode(CustomProfile.GitHubOrganization.CISecrets.skip)
      #expect(String(decoding: data, as: UTF8.self) == "\"skip\"")
    }

    @Test("Every Secrets case round-trips with labeled keys")
    internal func secretsRoundTrip() throws {
      for value in Self.secrets.map({ $0.serialization }) {
        #expect(try ProfileTests.roundTrip(value) == value)
        let data = try JSONEncoder().encode(value)
        #expect(!String(decoding: data, as: UTF8.self).contains("_0"))
      }
    }

    @Test(".team() and .team(nil) serialize equally")
    internal func teamDefault() {
      let explicit = CustomProfile.TeamSecrets(teamID: nil)
      #expect(CustomProfile.TeamSecrets.serializesEqually(.team(), explicit))
    }
  }

  fileprivate static func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
    try JSONDecoder().decode(T.self, from: JSONEncoder().encode(value))
  }
}
