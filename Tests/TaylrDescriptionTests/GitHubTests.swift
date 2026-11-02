import Foundation
import Testing

@testable import TaylrDescription

@Suite("GitHub")
internal enum GitHubTests {
  @Suite("Codable")
  internal struct CodableTests {
    private static let repository = "acme/Acme"

    @Test("The repository survives a round trip")
    internal func roundTrips() throws {
      let github = GitHub(repository: Self.repository)
      let data = try JSONEncoder().encode(github)
      let decoded = try JSONDecoder().decode(GitHub.self, from: data)
      #expect(decoded == github)
      #expect(decoded.repository == Self.repository)
    }

    @Test("The dot syntax from the reference compiles")
    internal func dotSyntax() {
      let github: GitHub = .init(repository: Self.repository)
      #expect(github.repository == Self.repository)
    }

    @Test("A missing repository fails to decode")
    internal func missingRepositoryFails() {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(GitHub.self, from: Data("{}".utf8))
      }
    }
  }
}
