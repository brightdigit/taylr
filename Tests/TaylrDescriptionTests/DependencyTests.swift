import Foundation
import Testing

@testable import TaylrDescription

@Suite("Dependency")
internal enum DependencyTests {
  @Suite("Codable")
  internal struct CodableTests {
    private static let cases: [DependencySerialization] = [
      UpToNextMajorDependency.package(
        url: "https://github.com/apple/swift-collections", from: "1.1.0"
      )
      .serialization,
      ExactDependency.package(url: "https://github.com/apple/swift-log", exact: "1.6.1")
        .serialization,
      BranchDependency.package(url: "https://github.com/acme/acme-design", branch: "main")
        .serialization,
      PathDependency.package(path: "../SharedCode").serialization,
      Package(name: "AcmeModels", platforms: [.iOS()], license: .apache2).serialization,
    ]

    @Test("Every case survives an encode and decode", arguments: cases)
    internal func roundTrips(dependency: DependencySerialization) throws {
      let data = try JSONEncoder().encode(dependency)
      #expect(try JSONDecoder().decode(DependencySerialization.self, from: data) == dependency)
      #expect(!String(decoding: data, as: UTF8.self).contains("_0"))
    }

    @Test("A local package keeps its other settings through an encode and decode")
    internal func localKeepsSettings() throws {
      let local = Package(name: "AcmeModels", gitLFS: true).serialization
      let data = try JSONEncoder().encode(local)
      let decoded = try JSONDecoder().decode(DependencySerialization.self, from: data)
      guard case .local(let package) = decoded else {
        Issue.record("Expected a local dependency")
        return
      }
      #expect(package.gitLFS)
    }

    @Test("A path dependency encodes under a labeled key")
    internal func pathEncodesLabeled() throws {
      let data = try JSONEncoder().encode(PathDependency(path: "../A").serialization)
      #expect(String(decoding: data, as: UTF8.self) == #"{"path":{"path":"..\/A"}}"#)
    }
  }

  @Suite("Cases")
  internal struct CaseTests {
    @Test("The package statics build the matching cases")
    internal func staticsBuildCases() {
      let url = "https://acme.example/a"
      #expect(
        UpToNextMajorDependency.package(url: url, from: "1.0.0").serialization
          == .upToNextMajor(url: url, from: "1.0.0"))
      #expect(
        ExactDependency.package(url: url, exact: "1.0.0").serialization
          == .exact(url: url, version: "1.0.0"))
      #expect(
        BranchDependency.package(url: url, branch: "main").serialization
          == .branch(url: url, name: "main"))
      #expect(PathDependency.package(path: "../A").serialization == .path(path: "../A"))
    }

    @Test("A string and its package serialize equally")
    internal func stringMatchesPackage() {
      #expect(String.serializesEqually("AcmeKit", Package(name: "AcmeKit")))
    }
  }

  @Suite("In a package's dependencies")
  internal struct ListTests {
    private static let models = Package(name: "AcmeModels")

    @Test("A string literal becomes a local dependency")
    internal func stringBecomesLocal() {
      let package = Package(name: "AcmeKit", dependencies: ["AcmeUtilities"])
      #expect(package.dependencies == [.local(package: "AcmeUtilities")])
    }

    @Test("A Package value becomes a local dependency")
    internal func packageBecomesLocal() {
      let package = Package(name: "AcmeKit", dependencies: [Self.models])
      #expect(package.dependencies == [.local(package: Self.models)])
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
          .local(package: models),
          .local(package: "AcmeUtilities"),
          .upToNextMajor(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
          .exact(url: "https://github.com/apple/swift-log", version: "1.6.1"),
          .branch(url: "https://github.com/acme/acme-design", name: "main"),
          .path(path: "../SharedCode"),
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
