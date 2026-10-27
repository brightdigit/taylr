import Foundation
import Testing

@testable import TaylrDescription

@Suite("URLs")
internal enum URLsTests {
  @Suite("init")
  internal struct InitTests {
    private static let full = URLs(
      privacy: "https://acme.example/privacy",
      support: "https://acme.example/support",
      marketing: "https://acme.example"
    )

    @Test("Each link is kept as given")
    internal func keepsLinks() {
      #expect(Self.full.privacy == "https://acme.example/privacy")
      #expect(Self.full.support == "https://acme.example/support")
      #expect(Self.full.marketing == "https://acme.example")
    }

    @Test("Marketing is nil when left out")
    internal func marketingDefaultsToNil() {
      let urls = URLs(privacy: "https://acme.example/p", support: "https://acme.example/s")
      #expect(urls.marketing == nil)
    }
  }

  @Suite("base")
  internal struct BaseTests {
    private static let site = "https://acme.example"

    @Test("The defaults yield the three documented URLs")
    internal func defaults() {
      #expect(
        URLs.base(Self.site)
          == URLs(
            privacy: "https://acme.example/privacy",
            support: "https://acme.example/support",
            marketing: "https://acme.example"
          )
      )
    }

    @Test("Custom paths are joined to the base")
    internal func customPaths() {
      let urls = URLs.base(Self.site, privacy: "/legal/privacy", support: "/help")
      #expect(urls.privacy == "https://acme.example/legal/privacy")
      #expect(urls.support == "https://acme.example/help")
      #expect(urls.marketing == "https://acme.example")
    }

    @Test("A trailing slash on the base never doubles")
    internal func trailingSlashBase() {
      #expect(URLs.base("https://acme.example/") == URLs.base(Self.site))
    }

    @Test("A path without a leading slash never goes missing a slash")
    internal func pathWithoutLeadingSlash() {
      let urls = URLs.base(Self.site, privacy: "legal/privacy", marketing: "home")
      #expect(urls.privacy == "https://acme.example/legal/privacy")
      #expect(urls.marketing == "https://acme.example/home")
    }

    @Test("A base with a path keeps it")
    internal func baseWithPath() {
      #expect(URLs.base("https://acme.example/app/").support == "https://acme.example/app/support")
    }
  }

  @Suite("Codable")
  internal struct CodableTests {
    private static let urls = URLs.base("https://acme.example")

    @Test("Round-trips through JSON")
    internal func roundTrip() throws {
      let data = try JSONEncoder().encode(Self.urls)
      #expect(try JSONDecoder().decode(URLs.self, from: data) == Self.urls)
    }

    @Test("A nil marketing round-trips")
    internal func roundTripWithoutMarketing() throws {
      let urls = URLs(privacy: "https://acme.example/p", support: "https://acme.example/s")
      let data = try JSONEncoder().encode(urls)
      #expect(try JSONDecoder().decode(URLs.self, from: data) == urls)
    }
  }
}
