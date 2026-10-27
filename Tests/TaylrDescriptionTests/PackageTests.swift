import Foundation
import Testing

@testable import TaylrDescription

@Suite("Package")
internal enum PackageTests {
  @Suite("Defaults")
  internal struct DefaultsTests {
    private static let package = Package(name: "AcmeKit")

    @Test("A package with only a name takes the documented defaults")
    internal func takesDocumentedDefaults() {
      let package = Self.package
      #expect(package.name == "AcmeKit")
      #expect(package.platforms.isEmpty)
      #expect(package.swiftVersion == nil)
      #expect(package.dependencies.isEmpty)
      #expect(package.taylrVersion == "1.0.0")
      #expect(package.includeNightly == false)
      #expect(package.github == nil)
      #expect(package.devcontainer)
      #expect(package.lint == [.swiftLint, .swiftFormat])
      #expect(package.header == .file(path: "Scripts/header.mustache"))
      #expect(package.license == .mit)
      #expect(package.gitLFS == false)
      #expect(package.agents == [.claudeCode])
    }

    @Test("CI defaults to GitHub Actions with the ci, cleanup and claude workflows")
    internal func ciDefaultsToPackageWorkflows() {
      #expect(
        Self.package.ci
          == GitHubActions.githubActions(workflows: [.ci, .cleanup, .claude]).serialization)
    }

    @Test("ci: nil means no CI")
    internal func nilCIMeansNoCI() {
      #expect(Package(name: "AcmeKit", ci: nil).ci == nil)
    }
  }

  @Suite("String literal")
  internal struct StringLiteralTests {
    @Test("A string literal is a package with that name and every default")
    internal func literalIsPackageWithName() {
      let package: Package = "AcmeKit"
      #expect(package == Package(name: "AcmeKit"))
      #expect(package.license == .mit)
      #expect(package.ci == Package(name: "AcmeKit").ci)
    }

    @Test("A string literal works in an array of packages")
    internal func literalWorksInArray() {
      let packages: [Package] = ["AcmeKit", "AcmeUtilities"]
      #expect(packages.map(\.name) == ["AcmeKit", "AcmeUtilities"])
    }
  }

  @Suite("Equality")
  internal struct EqualityTests {
    @Test("Packages are equal only when every field is equal")
    internal func equalWhenEveryFieldMatches() {
      let lhs = Package(name: "AcmeKit", license: .mit)
      let rhs = Package(name: "AcmeKit", platforms: [.iOS()], license: .apache2, gitLFS: true)
      #expect(lhs != rhs)
      #expect(lhs == Package(name: "AcmeKit", license: .mit))
    }

    @Test("Packages with different names are not equal")
    internal func differentNamesAreNotEqual() {
      #expect(Package(name: "AcmeKit") != Package(name: "AcmeCharts"))
    }
  }

  @Suite("Codable")
  internal struct CodableTests {
    private static let full = Package(
      name: "AcmeCharts",
      platforms: [.iOS(), .macOS("27.2")],
      swiftVersion: "6.1",
      dependencies: [Package(name: "AcmeUtilities")],
      taylrVersion: "1.2.3",
      includeNightly: true,
      github: .init(repository: "acme/AcmeCharts"),
      ci: .githubActions(runners: .githubHosted, workflows: [.ci]),
      devcontainer: false,
      lint: [.swiftLint, .periphery],
      header: nil,
      license: .apache2,
      gitLFS: true,
      agents: []
    )

    @Test("Every field survives an encode and decode")
    internal func roundTripsEveryField() throws {
      let data = try JSONEncoder().encode(Self.full)
      let decoded = try JSONDecoder().decode(Package.self, from: data)
      // `==` compares names only, so every field is checked on its own.
      #expect(decoded.name == "AcmeCharts")
      #expect(decoded.platforms == [.iOS(), .macOS("27.2")])
      #expect(decoded.swiftVersion == "6.1")
      #expect(decoded.dependencies == [.local(Package(name: "AcmeUtilities"))])
      #expect(decoded.taylrVersion == "1.2.3")
      #expect(decoded.includeNightly)
      #expect(decoded.github == .init(repository: "acme/AcmeCharts"))
      #expect(
        decoded.ci
          == GitHubActions.githubActions(runners: .githubHosted, workflows: [.ci]).serialization)
      #expect(decoded.devcontainer == false)
      #expect(decoded.lint == [.swiftLint, .periphery])
      #expect(decoded.header == nil)
      #expect(decoded.license == .apache2)
      #expect(decoded.gitLFS)
      #expect(decoded.agents.isEmpty)
    }

    @Test("A package with defaults round-trips its defaults")
    internal func roundTripsDefaults() throws {
      let data = try JSONEncoder().encode(Package(name: "AcmeKit"))
      let decoded = try JSONDecoder().decode(Package.self, from: data)
      #expect(
        decoded.ci
          == GitHubActions.githubActions(workflows: [.ci, .cleanup, .claude]).serialization)
      #expect(decoded.header == .file(path: "Scripts/header.mustache"))
      #expect(decoded.lint == [.swiftLint, .swiftFormat])
      #expect(decoded.agents == [.claudeCode])
      #expect(decoded.license == .mit)
    }
  }

  @Suite("Reference examples")
  internal struct ReferenceExampleTests {
    @Test("The Swift package example compiles")
    internal func swiftPackageExample() {
      let manifest = Package(
        name: "Acme",
        platforms: [.iOS(), .macOS(), .visionOS()]
      )
      #expect(manifest.platforms.count == 3)
    }

    @Test("The open-source package example compiles")
    internal func openSourcePackageExample() {
      let manifest = Package(
        name: "AcmeCharts",
        platforms: [.iOS(), .macOS()],
        swiftVersion: "6.1",
        includeNightly: true,
        github: .init(repository: "acme/AcmeCharts"),
        ci: .githubActions(runners: .githubHosted),
        lint: [.swiftLint, .swiftFormat, .periphery],
        license: .apache2
      )
      #expect(manifest.license == .apache2)
      #expect(manifest.lint.count == 3)
    }

    @Test("TaylrDescription.Package names the package type")
    internal func qualifiedName() {
      let manifest = TaylrDescription.Package(name: "AcmeKit")
      #expect(manifest == Package(name: "AcmeKit"))
    }
  }
}
