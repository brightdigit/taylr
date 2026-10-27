import Foundation
import Testing

@testable import TaylrDescription

@Suite("Dependency")
internal enum DependencyTests {
  @Suite("Codable")
  internal struct CodableTests {
    private static let cases: [Dependency] = [
      .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
      .package(url: "https://github.com/apple/swift-log", exact: "1.6.1"),
      .package(url: "https://github.com/acme/acme-design", branch: "main"),
      .package(path: "../SharedCode"),
      .local(Package(name: "AcmeModels", platforms: [.iOS()], license: .apache2)),
    ]

    @Test("Every case survives an encode and decode", arguments: cases)
    internal func roundTrips(dependency: Dependency) throws {
      let data = try JSONEncoder().encode(dependency)
      #expect(try JSONDecoder().decode(Dependency.self, from: data) == dependency)
    }

    @Test("A local package keeps its other settings through an encode and decode")
    internal func localKeepsSettings() throws {
      let local = Dependency.local(Package(name: "AcmeModels", gitLFS: true))
      let data = try JSONEncoder().encode(local)
      let decoded = try JSONDecoder().decode(Dependency.self, from: data)
      guard case .local(let package) = decoded else {
        Issue.record("Expected a local dependency")
        return
      }
      #expect(package.gitLFS)
    }
  }

  @Suite("Cases")
  internal struct CaseTests {
    @Test("The package statics build the matching cases")
    internal func staticsBuildCases() {
      #expect(
        Dependency.package(url: "https://acme.example/a", from: "1.0.0")
          == .upToNextMajor(url: "https://acme.example/a", from: "1.0.0"))
      #expect(
        Dependency.package(url: "https://acme.example/a", exact: "1.0.0")
          == .exact(url: "https://acme.example/a", version: "1.0.0"))
      #expect(
        Dependency.package(url: "https://acme.example/a", branch: "main")
          == .branch(url: "https://acme.example/a", name: "main"))
      #expect(Dependency.package(path: "../A") == .path("../A"))
    }
  }

  @Suite("In a package's dependencies")
  internal struct ListTests {
    private static let models = Package(name: "AcmeModels")

    @Test("A string literal becomes a local dependency")
    internal func stringBecomesLocal() {
      let package = Package(name: "AcmeKit", dependencies: ["AcmeUtilities"])
      #expect(package.dependencies == [.local("AcmeUtilities")])
    }

    @Test("A Package value becomes a local dependency")
    internal func packageBecomesLocal() {
      let package = Package(name: "AcmeKit", dependencies: [Self.models])
      #expect(package.dependencies == [.local(Self.models)])
    }

    @Test("A local dependency keeps the whole package")
    internal func localKeepsPackage() {
      let models = Package(name: "AcmeModels", license: .apache2)
      let package = Package(name: "AcmeKit", dependencies: [models])
      guard case .local(let stored) = package.dependencies.first else {
        Issue.record("Expected a local dependency")
        return
      }
      #expect(stored.license == .apache2)
    }

    @Test("The reference's dependencies example compiles")
    internal func referenceExample() {
      let models = Package(name: "AcmeModels")
      let kit = Package(
        name: "AcmeKit",
        dependencies: [
          models,
          "AcmeUtilities",
          .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
          .package(url: "https://github.com/apple/swift-log", exact: "1.6.1"),
          .package(url: "https://github.com/acme/acme-design", branch: "main"),
          .package(path: "../SharedCode"),
        ]
      )
      #expect(
        kit.dependencies == [
          .local(models),
          .local("AcmeUtilities"),
          .upToNextMajor(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
          .exact(url: "https://github.com/apple/swift-log", version: "1.6.1"),
          .branch(url: "https://github.com/acme/acme-design", name: "main"),
          .path("../SharedCode"),
        ])
    }

    @Test("A package's dependencies round-trip through a package")
    internal func roundTripsThroughPackage() throws {
      let package = Package(
        name: "AcmeKit",
        dependencies: [Self.models, .package(path: "../SharedCode")]
      )
      let data = try JSONEncoder().encode(package)
      let decoded = try JSONDecoder().decode(Package.self, from: data)
      #expect(decoded.dependencies == package.dependencies)
    }
  }
}
