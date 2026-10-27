import Testing

@testable import TaylrDescription

/// The reference's `Manifest.swift` examples: each one's source, and the same value built
/// in-process.
internal enum ManifestExamples {
  /// A docs example.
  internal struct Example: Sendable, CustomTestStringConvertible {
    internal let name: String
    internal let source: String
    internal let expected: Manifest

    internal var testDescription: String { name }
  }

  /// What the compile-and-run step adds next to the user's `Manifest.swift`.
  internal static let driver = "import TaylrDescription\n\ntry ManifestJSON.write(manifest)\n"

  /// The two app and two package examples at the top of the reference, and the four-package app.
  internal static let all: [Example] = [
    appWithServer, iOSApp, swiftPackage, openSourcePackage, fourPackageApp,
  ]

  private static let header = "import TaylrDescription\n\n"

  private static let appWithServer = Example(
    name: "App with a server",
    source: header
      + """
      let manifest = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS(), .macOS()],
        urls: .base("https://acme.example"),
        server: .server(framework: .hummingbird(routing: .openAPI))
      )
      """,
    expected: .app(
      App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS(), .macOS()],
        urls: .base("https://acme.example"),
        server: .server(framework: .hummingbird(routing: .openAPI))
      )
    )
  )

  private static let iOSApp = Example(
    name: "iOS 27.2 app",
    source: header
      + """
      let manifest = App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS("27.2")]
      )
      """,
    expected: .app(
      App(name: "Acme", profile: .named("default"), platforms: [.iOS("27.2")])
    )
  )

  private static let swiftPackage = Example(
    name: "Swift package",
    source: header
      + """
      let manifest = Package(
        name: "Acme",
        platforms: [.iOS(), .macOS(), .visionOS()]
      )
      """,
    expected: .package(
      Package(name: "Acme", platforms: [.iOS(), .macOS(), .visionOS()])
    )
  )

  private static let openSourcePackage = Example(
    name: "Open-source package",
    source: header
      + """
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
      """,
    expected: .package(
      Package(
        name: "AcmeCharts",
        platforms: [.iOS(), .macOS()],
        swiftVersion: "6.1",
        includeNightly: true,
        github: .init(repository: "acme/AcmeCharts"),
        ci: .githubActions(runners: .githubHosted),
        lint: [.swiftLint, .swiftFormat, .periphery],
        license: .apache2
      )
    )
  )

  private static let fourPackageApp = Example(
    name: "Four-package app",
    source: header
      + """
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
      """,
    expected: fourPackageManifest()
  )

  private static func fourPackageManifest() -> Manifest {
    let models = Package(name: "AcmeModels")
    let kit = Package(name: "AcmeKit", dependencies: [models])
    let app = Package(name: "AcmeApp", dependencies: [kit])
    let server = Package.server(dependencies: [models])
    return .app(
      App(
        name: "Acme",
        profile: .named("default"),
        platforms: [.iOS(), .macOS()],
        packages: Packages(client: app, server: server)
      )
    )
  }
}
