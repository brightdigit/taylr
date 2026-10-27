import Foundation
import Testing

@testable import TaylrDescription

@Suite("Packages")
internal enum PackagesTests {
  @Suite("Presets")
  internal struct PresetTests {
    @Test("appOnly is AcmeApp depending on AcmeKit")
    internal func appOnly() throws {
      let resolved = try AppOnlyLayout.appOnly.resolvedPackages(appName: "Acme")
      #expect(resolved.map(\.name) == ["AcmeApp", "AcmeKit"])
      #expect(resolved[0].dependencies == ["AcmeKit"].map(\.serialization))
    }

    @Test("withServer(.server()) names the server AcmeServer; app and server use AcmeKit")
    internal func withServer() throws {
      let resolved = try ServerLayout.withServer(.server()).resolvedPackages(appName: "Acme")
      #expect(resolved.map(\.name) == ["AcmeApp", "AcmeKit", "AcmeServer"])
      #expect(resolved[2].framework == .hummingbird())
      #expect(resolved[2].dependencies == ["AcmeKit"].map(\.serialization))
    }

    @Test("withServer keeps the server's own dependencies and name")
    internal func withServerKeepsDependencies() throws {
      let server = Package.server(name: "AcmeAPI", dependencies: ["AcmeModels"])
      let resolved = try ServerLayout.withServer(server).resolvedPackages(appName: "Acme")
      #expect(resolved.map(\.name) == ["AcmeApp", "AcmeKit", "AcmeAPI", "AcmeModels"])
      #expect(resolved[2].dependencies == ["AcmeModels", "AcmeKit"].map(\.serialization))
    }
  }

  @Suite("Resolving")
  internal struct ResolvingTests {
    @Test("The reference's four-package example resolves breadth-first")
    internal func referenceExample() throws {
      let models = Package(name: "AcmeModels")
      let kit = Package(name: "AcmeKit", dependencies: [models])
      let app = Package(name: "AcmeApp", dependencies: [kit])
      let server = Package.server(dependencies: [models])
      let packages = Packages(client: app, server: server)
      #expect(
        try PackagesTests.names(packages) == ["AcmeApp", "AcmeKit", "AcmeModels", "AcmeServer"])
    }

    @Test("Name-only dependencies on client and server resolve")
    internal func nameOnlyReferences() throws {
      let packages = Packages(
        client: Package(name: "AcmeApp", dependencies: ["AcmeKit"]),
        server: .server(dependencies: ["AcmeKit"])
      )
      #expect(try PackagesTests.names(packages) == ["AcmeApp", "AcmeKit", "AcmeServer"])
    }

    @Test("A name and a declaration with that name are one package; the declaration wins")
    internal func declarationWinsOverName() throws {
      let kit = Package(name: "AcmeKit", dependencies: ["AcmeModels"], license: .apache2)
      let packages = Packages(
        client: Package(name: "AcmeApp", dependencies: ["AcmeKit"]),
        server: .server(dependencies: [kit])
      )
      let resolved = try packages.resolvedPackages(appName: "Acme")
      #expect(resolved.map(\.name) == ["AcmeApp", "AcmeKit", "AcmeModels", "AcmeServer"])
      #expect(resolved[1].license == .apache2)
    }

    @Test("The same declaration twice is one package")
    internal func sameDeclarationTwice() throws {
      let kit = Package(name: "AcmeKit", license: .apache2)
      let app = Package(name: "AcmeApp", dependencies: [kit])
      let packages = Packages(client: app, server: .server(dependencies: [kit]))
      #expect(try PackagesTests.names(packages) == ["AcmeApp", "AcmeKit", "AcmeServer"])
    }

    @Test("others are added after the client and the server")
    internal func othersComeLast() throws {
      let packages = Packages(
        client: Package(name: "AcmeApp", dependencies: ["AcmeKit"]),
        others: ["AcmeExperiments"]
      )
      #expect(try PackagesTests.names(packages) == ["AcmeApp", "AcmeKit", "AcmeExperiments"])
    }

    @Test("The preset uses the app's name")
    internal func presetUsesAppName() throws {
      #expect(try PackagesTests.names(.appOnly, app: "Zed") == ["ZedApp", "ZedKit"])
    }
  }

  @Suite("Serialization")
  internal struct SerializationTests {
    private static let layouts: [any PackageLayout] = [
      .appOnly,
      .withServer(.server(name: "AcmeServer")),
      Packages(client: "AcmeApp", server: .server(), others: ["AcmeExperiments"]),
    ]

    @Test("Every layout round-trips with labeled keys")
    internal func roundTrips() throws {
      for layout in Self.layouts {
        let data = try JSONEncoder().encode(layout.serialization)
        let decoded = try JSONDecoder().decode(PackageLayoutSerialization.self, from: data)
        #expect(decoded == layout.serialization)
        #expect(!String(decoding: data, as: UTF8.self).contains("_0"))
      }
    }
  }

  @Suite("GraphError")
  internal struct GraphErrorTests {
    private static func error(_ packages: any PackageLayout) -> Packages.GraphError? {
      do {
        _ = try packages.resolvedPackages(appName: "Acme")
        return nil
      } catch {
        return error
      }
    }

    @Test("cycle: AcmeKit and AcmeModels depend on each other")
    internal func cycle() {
      let models = Package(name: "AcmeModels", dependencies: ["AcmeKit"])
      let kit = Package(name: "AcmeKit", dependencies: [models])
      let packages = Packages(client: Package(name: "AcmeApp", dependencies: [kit]))
      #expect(Self.error(packages) == .cycle(path: ["AcmeKit", "AcmeModels", "AcmeKit"]))
    }

    @Test("cycle: a package that depends on itself")
    internal func selfCycle() {
      let packages = Packages(client: Package(name: "AcmeApp", dependencies: ["AcmeApp"]))
      #expect(Self.error(packages) == .cycle(path: ["AcmeApp", "AcmeApp"]))
    }

    @Test("clientDependsOnServer: directly")
    internal func clientDependsOnServerDirectly() {
      let server = Package.server(name: "AcmeServer")
      let app = Package(name: "AcmeApp", dependencies: [server])
      let packages = Packages(client: app, server: server)
      #expect(Self.error(packages) == .clientDependsOnServer(path: ["AcmeApp", "AcmeServer"]))
    }

    @Test("clientDependsOnServer: through another package, by name")
    internal func clientDependsOnServerTransitively() {
      let kit = Package(name: "AcmeKit", dependencies: ["AcmeServer"])
      let app = Package(name: "AcmeApp", dependencies: [kit])
      let packages = Packages(client: app, server: .server())
      #expect(
        Self.error(packages)
          == .clientDependsOnServer(path: ["AcmeApp", "AcmeKit", "AcmeServer"]))
    }

    @Test("multipleServers: a second server in others")
    internal func multipleServers() {
      let other = Package.server(name: "AcmeOtherServer")
      let packages = Packages(client: "AcmeApp", server: .server(), others: [other])
      #expect(Self.error(packages) == .multipleServers(names: ["AcmeServer", "AcmeOtherServer"]))
    }

    @Test("serverOutsideServerSlot: a server in others with no server")
    internal func serverInOthers() {
      let packages = Packages(client: "AcmeApp", others: [.server(name: "AcmeServer")])
      #expect(Self.error(packages) == .serverOutsideServerSlot(name: "AcmeServer"))
    }

    @Test("serverOutsideServerSlot: a server as a dependency")
    internal func serverAsDependency() {
      let server = Package.server(name: "AcmeServer")
      let packages = Packages(client: Package(name: "AcmeApp", dependencies: [server]))
      #expect(Self.error(packages) == .serverOutsideServerSlot(name: "AcmeServer"))
    }

    @Test("serverOutsideServerSlot: a server as the client")
    internal func serverAsClient() {
      let packages = Packages(client: .server(name: "AcmeApp"))
      #expect(Self.error(packages) == .serverOutsideServerSlot(name: "AcmeApp"))
    }

    @Test("duplicateNameDifferentSettings: two configured declarations")
    internal func duplicateNameDifferentSettings() {
      let packages = Packages(
        client: Package(name: "AcmeApp", dependencies: [Package(name: "AcmeKit", gitLFS: true)]),
        server: .server(dependencies: [Package(name: "AcmeKit", license: .apache2)])
      )
      #expect(Self.error(packages) == .duplicateNameDifferentSettings(name: "AcmeKit"))
    }

    @Test("A name-only reference is not different settings from a configured declaration")
    internal func nameOnlyIsNotDifferent() {
      let packages = Packages(
        client: Package(name: "AcmeApp", dependencies: [Package(name: "AcmeKit", gitLFS: true)]),
        server: .server(dependencies: ["AcmeKit"])
      )
      #expect(Self.error(packages) == nil)
    }

    @Test("unusedOthersEntry: an others entry something depends on")
    internal func unusedOthersEntry() {
      let app = Package(name: "AcmeApp", dependencies: ["AcmeKit"])
      let packages = Packages(client: app, others: ["AcmeKit"])
      #expect(Self.error(packages) == .unusedOthersEntry(name: "AcmeKit"))
    }
  }

  private static func names(_ packages: any PackageLayout, app: String = "Acme") throws -> [String?]
  {
    try packages.resolvedPackages(appName: app).map(\.name)
  }
}
