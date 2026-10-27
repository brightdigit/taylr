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
        #expect(Profile(organization: organization).resolvedBundleIDPrefix == expected)
      }
    }

    @Test("A written prefix is kept")
    internal func keepsWrittenPrefix() {
      let profile = Profile(organization: "Client X Inc", bundleIDPrefix: "com.clientx")
      #expect(profile.resolvedBundleIDPrefix == "com.clientx")
    }

    @Test("A named profile has no resolved prefix")
    internal func namedHasNone() {
      #expect(Profile.named("client-x").resolvedBundleIDPrefix == nil)
    }
  }

  @Suite("Reference example")
  internal struct ReferenceTests {
    private static let named: Profile = .named("client-x")
    private static let inline: Profile = .init(
      organization: "Client X Inc",
      bundleIDPrefix: "com.clientx",
      apple: .init(teamID: "FGHIJ67890", ascTeamID: "7654321"),
      signing: .init(storage: .git("git@github.com:clientx/certs.git")),
      github: .init(org: "clientx")
    )

    @Test("Both spellings compile and round-trip")
    internal func roundTrips() throws {
      #expect(try ProfileTests.roundTrip(Self.named) == Self.named)
      #expect(try ProfileTests.roundTrip(Self.inline) == Self.inline)
    }

    @Test("Omitted fields take their defaults")
    internal func defaults() {
      let profile = Profile(organization: "Acme Corp")
      guard case .inline(_, let prefix, let apple, let signing, let github, let secrets) = profile
      else {
        Issue.record("Expected an inline profile")
        return
      }
      #expect(prefix == nil)
      #expect(apple == nil)
      #expect(signing == nil)
      #expect(github == nil)
      #expect(secrets == .team())
      #expect(secrets == .team(nil))
    }
  }

  @Suite("Decoding JSON")
  internal struct DecodingTests {
    private static let namedJSON = #"{"named":{"_0":"client-x"}}"#
    private static let inlineJSON = """
      {"inline":{"organization":"Acme Corp","bundleIDPrefix":"com.acmecorp",\
      "apple":{"teamID":"ABCDE12345"},\
      "signing":{"storage":{"s3":{"bucket":"acme-certs","region":"us-east-1"}}},\
      "github":{"org":"acme","ciSecrets":"skip"},\
      "secrets":{"profile":{"_0":"acme"}}}}
      """

    @Test(".named decodes from JSON")
    internal func decodesNamed() throws {
      let profile = try JSONDecoder().decode(Profile.self, from: Data(Self.namedJSON.utf8))
      #expect(profile == .named("client-x"))
    }

    @Test("An inline profile decodes from JSON")
    internal func decodesInline() throws {
      let profile = try JSONDecoder().decode(Profile.self, from: Data(Self.inlineJSON.utf8))
      let expected = Profile(
        organization: "Acme Corp",
        bundleIDPrefix: "com.acmecorp",
        apple: .init(teamID: "ABCDE12345"),
        signing: .init(storage: .s3(bucket: "acme-certs", region: "us-east-1")),
        github: .init(org: "acme", ciSecrets: .skip),
        secrets: .profile("acme")
      )
      #expect(profile == expected)
      #expect(try ProfileTests.roundTrip(profile) == expected)
    }
  }

  @Suite("Cases")
  internal struct CaseTests {
    private static let storages: [Profile.Signing.Storage] = [
      .git("git@github.com:acme/certs.git"),
      .s3(bucket: "acme-certs", region: "us-east-1"),
      .googleCloudStorage(bucket: "acme-certs"),
      .gitlabSecureFiles(project: "acme/certs"),
    ]
    private static let ciSecrets: [Profile.GitHubOrganization.CISecrets] = [
      .organization, .repository, .skip,
    ]
    private static let secrets: [Profile.Secrets] = [
      .team(), .team("ABCDE12345"), .profile("acme"), .environment,
    ]

    @Test("Every Storage case round-trips")
    internal func storagesRoundTrip() throws {
      for value in Self.storages {
        #expect(try ProfileTests.roundTrip(value) == value)
      }
    }

    @Test("Every CISecrets case round-trips as a plain string")
    internal func ciSecretsRoundTrip() throws {
      for value in Self.ciSecrets {
        #expect(try ProfileTests.roundTrip(value) == value)
      }
      let data = try JSONEncoder().encode(Profile.GitHubOrganization.CISecrets.skip)
      #expect(String(decoding: data, as: UTF8.self) == "\"skip\"")
    }

    @Test("Every Secrets case round-trips")
    internal func secretsRoundTrip() throws {
      for value in Self.secrets {
        #expect(try ProfileTests.roundTrip(value) == value)
      }
    }
  }

  fileprivate static func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
    try JSONDecoder().decode(T.self, from: JSONEncoder().encode(value))
  }
}
