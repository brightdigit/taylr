import Foundation
import Testing

@testable import TaylrDescription

@Suite("Manifest")
internal enum ManifestTests {
  @Suite("ManifestJSON round trip")
  internal struct RoundTripTests {
    private static let app = App(
      name: "Acme",
      profile: .named("default"),
      platforms: [.iOS(), .macOS()],
      urls: .base("https://acme.example"),
      server: .server(framework: .hummingbird(routing: .openAPI))
    )

    private static let package = Package(
      name: "AcmeCharts",
      platforms: [.iOS(), .macOS()],
      swiftVersion: "6.1",
      includeNightly: true,
      github: .init(repository: "acme/AcmeCharts"),
      ci: .githubActions(runners: .githubHosted),
      lint: [.swiftLint, .swiftFormat, .periphery],
      license: .apache2
    )

    @Test("An app manifest decodes to an equal app")
    internal func appRoundTrips() throws {
      let manifest = Manifest.app(app: Self.app)
      let data = try ManifestJSON.data(for: manifest)
      #expect(try ManifestJSON.manifest(from: data) == manifest)
    }

    @Test("A package manifest decodes to an equal package")
    internal func packageRoundTrips() throws {
      let manifest = Manifest.package(package: Self.package)
      let data = try ManifestJSON.data(for: manifest)
      #expect(try ManifestJSON.manifest(from: data) == manifest)
    }

    @Test("Encoding twice gives the same bytes, because the keys are sorted")
    internal func encodingIsStable() throws {
      let manifest = Manifest.app(app: Self.app)
      let first = try ManifestJSON.data(for: manifest)
      let second = try ManifestJSON.data(for: manifest)
      #expect(first == second)
    }

    @Test("An app and a package decode to their own cases")
    internal func casesAreDistinct() throws {
      let app = try ManifestJSON.manifest(from: ManifestJSON.data(for: .app(app: Self.app)))
      let package = try ManifestJSON.manifest(
        from: ManifestJSON.data(for: .package(package: Self.package))
      )
      #expect(app != package)
      guard case .app = app, case .package = package else {
        Issue.record("Decoded the wrong case")
        return
      }
    }

    @Test("JSON that isn't a manifest throws")
    internal func invalidJSONThrows() {
      #expect(throws: DecodingError.self) {
        try ManifestJSON.manifest(from: Data(#"{"other":{}}"#.utf8))
      }
    }
  }

  @Suite("Compiled Manifest.swift")
  internal struct CompiledTests {
    @Test(
      "A compiled Manifest.swift prints JSON that decodes to the same manifest",
      arguments: ManifestExamples.all
    )
    internal func compiledExampleRoundTrips(example: ManifestExamples.Example) async throws {
      let output = try await ManifestCompiler.run(
        name: example.name,
        source: example.source,
        driver: ManifestExamples.driver
      )
      let decoded = try ManifestJSON.manifest(from: output)
      #expect(decoded == example.expected)
    }

    @Test(
      "A compiled Manifest.swift prints JSON with labeled keys only",
      arguments: ManifestExamples.all
    )
    internal func compiledExampleHasNoUnlabeledKeys(example: ManifestExamples.Example) async throws
    {
      let output = try await ManifestCompiler.run(
        name: example.name,
        source: example.source,
        driver: ManifestExamples.driver
      )
      #expect(!String(decoding: output, as: UTF8.self).contains(#""_0""#))
    }
  }
}
