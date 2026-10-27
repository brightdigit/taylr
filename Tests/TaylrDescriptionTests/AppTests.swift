import Testing

@testable import TaylrDescription

@Suite("App")
internal enum AppTests {
  @Suite("init")
  internal struct InitTests {
    @Test("Everything but name, profile and platforms takes its documented default")
    internal func defaults() {
      let app = AppTests.minimal
      #expect(app.name == "Acme")
      #expect(app.profile == .named("default"))
      #expect(app.platforms == [.iOS()])
      #expect(app.bundleID == nil)
      #expect(app.appGroupID == nil)
      #expect(app.urls == nil)
      #expect(app.packages == .appOnly)
      #expect(app.appStoreConnect == .fastlane)
      #expect(app.screenshots == .fastlaneSnapshot)
      #expect(app.distribution == [.appStore])
      #expect(app.pressKit == .uv)
      #expect(app.localizations == ["en-US"])
      #expect(app.crossPlatform)
      #expect(app.generator == .tuist)
      #expect(app.taylrVersion == "1.0.0")
      #expect(app.github == nil)
      #expect(app.ci == .githubActions())
      #expect(app.swiftVersion == nil)
      #expect(!app.includeNightly)
      #expect(app.devcontainer)
      #expect(app.lint == [.swiftLint, .swiftFormat])
      #expect(app.header == .file("Scripts/header.mustache"))
      #expect(app.license == .proprietary)
      #expect(app.gitLFS)
      #expect(app.agents == [.claudeCode])
    }

    @Test("server: stores .withServer")
    internal func serverBecomesWithServer() {
      let server = Package.server(framework: .hummingbird(routing: .openAPI))
      let app = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS()],
        server: server
      )
      #expect(app.packages == .withServer(server))
    }

    @Test("server: leaves the other defaults alone")
    internal func serverKeepsDefaults() {
      let app = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS()],
        server: .server()
      )
      #expect(app.license == .proprietary)
      #expect(app.gitLFS)
      #expect(app.appStoreConnect == .fastlane)
    }
  }

  @Suite("Reference examples")
  internal struct ReferenceExampleTests {
    @Test("The app with a server compiles")
    internal func appWithServer() {
      let manifest = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS(), .macOS()],
        urls: .base("https://acme.example"),
        server: .server(framework: .hummingbird(routing: .openAPI))
      )
      #expect(manifest.urls?.privacy == "https://acme.example/privacy")
      #expect(manifest.platforms == [.iOS(), .macOS()])
    }

    @Test("The iOS 27.2 app without a server compiles")
    internal func iOS272() {
      let manifest = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS("27.2")]
      )
      #expect(manifest.platforms == [.iOS("27.2")])
      #expect(manifest.packages == .appOnly)
    }

    @Test("The four-package app compiles")
    internal func fourPackages() throws {
      let models = Package(name: "AcmeModels")
      let kit = Package(name: "AcmeKit", dependencies: [models])
      let app = Package(name: "AcmeApp", dependencies: [kit])
      let server = Package.server(dependencies: [models])

      let manifest = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS(), .macOS()],
        packages: Packages(client: app, server: server)
      )
      let names = try manifest.packages.resolvedPackages(appName: "Acme").map(\.name)
      #expect(names == ["AcmeApp", "AcmeKit", "AcmeModels", "AcmeServer"])
    }

    @Test("An app with an inline profile, base URLs and spelled-out CI compiles")
    internal func inlineProfileAndCI() {
      let manifest = App(
        name: "Acme",
        profile: .init(
          organization: "Client X Inc",
          bundleIDPrefix: "com.clientx",
          apple: .init(teamID: "ABCDE12345", ascTeamID: "7654321"),
          signing: .init(storage: .git("git@github.com:clientx/certs.git")),
          github: .init(org: "clientx")
        ),
        platforms: [.iOS()],
        urls: .base("https://acme.example", privacy: "/legal/privacy", support: "/help"),
        ci: .githubActions(
          runners: .githubHosted,
          workflows: [.ci, .appStoreMetadata, .appStoreSession]
        )
      )
      #expect(manifest.urls?.support == "https://acme.example/help")
      let expected = CI.githubActions(
        runners: .githubHosted,
        workflows: [.ci, .appStoreMetadata, .appStoreSession]
      )
      #expect(manifest.ci == expected)
    }
  }

  private static let minimal = App(
    name: "Acme",
    profile: .named("default"),
    platforms: [.iOS()]
  )
}
