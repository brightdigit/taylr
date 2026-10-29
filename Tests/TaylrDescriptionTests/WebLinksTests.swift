import Foundation
import Testing

@testable import TaylrDescription

@Suite("WebLinks")
internal enum WebLinksTests {
  @Suite("init")
  internal struct InitTests {
    private static let full = WebLinks(
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
      let urls = WebLinks(privacy: "https://acme.example/p", support: "https://acme.example/s")
      #expect(urls.marketing == nil)
    }
  }

  @Suite("base")
  internal struct BaseTests {
    private static let site = "https://acme.example"

    @Test("The defaults yield the three documented links")
    internal func defaults() {
      #expect(
        WebLinks.base(Self.site)
          == WebLinks(
            privacy: "https://acme.example/privacy",
            support: "https://acme.example/support",
            marketing: "https://acme.example"
          )
      )
    }

    @Test("Custom paths are joined to the base")
    internal func customPaths() {
      let urls = WebLinks.base(Self.site, privacy: "/legal/privacy", support: "/help")
      #expect(urls.privacy == "https://acme.example/legal/privacy")
      #expect(urls.support == "https://acme.example/help")
      #expect(urls.marketing == "https://acme.example")
    }

    @Test("A trailing slash on the base never doubles")
    internal func trailingSlashBase() {
      #expect(WebLinks.base("https://acme.example/") == WebLinks.base(Self.site))
    }

    @Test("A path without a leading slash never goes missing a slash")
    internal func pathWithoutLeadingSlash() {
      let urls = WebLinks.base(Self.site, privacy: "legal/privacy", marketing: "home")
      #expect(urls.privacy == "https://acme.example/legal/privacy")
      #expect(urls.marketing == "https://acme.example/home")
    }

    @Test("A base with a path keeps it")
    internal func baseWithPath() {
      #expect(
        WebLinks.base("https://acme.example/app/").support == "https://acme.example/app/support")
    }
  }

  @Suite("Codable")
  internal struct CodableTests {
    private static let urls = WebLinks.base("https://acme.example")

    @Test("Round-trips through JSON")
    internal func roundTrip() throws {
      let data = try JSONEncoder().encode(Self.urls)
      #expect(try JSONDecoder().decode(WebLinks.self, from: data) == Self.urls)
    }

    @Test("A nil marketing round-trips")
    internal func roundTripWithoutMarketing() throws {
      let urls = WebLinks(privacy: "https://acme.example/p", support: "https://acme.example/s")
      let data = try JSONEncoder().encode(urls)
      #expect(try JSONDecoder().decode(WebLinks.self, from: data) == urls)
    }
  }
}
