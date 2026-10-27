import Foundation

@testable import TaylrDescription

/// The reference's example manifests and their JSON, shared by the App tests.
internal enum AppFixtures {
  internal static let minimal = App(
    name: "Acme",
    profile: .named("default"),
    platforms: [.iOS()]
  )

  internal static let serverApp = App(
    name: "Acme",
    profile: .named("default"),
    platforms: [.iOS(), .macOS()],
    urls: .base("https://acme.example"),
    server: .server(framework: .hummingbird(routing: .openAPI))
  )

  internal static let iOS272App = App(
    name: "Acme",
    profile: .named("default"),
    platforms: [.iOS("27.2")]
  )

  internal static let fourPackageApp = {
    let models = Package(name: "AcmeModels")
    let kit = Package(name: "AcmeKit", dependencies: [models])
    let app = Package(name: "AcmeApp", dependencies: [kit])
    let server = Package.server(dependencies: [models])
    return App(
      name: "Acme",
      profile: .named("default"),
      platforms: [.iOS(), .macOS()],
      packages: Packages(client: app, server: server)
    )
  }()

  /// The app-level settings every example shares, as JSON object members.
  internal static let appSettingsJSON = """
    "agents": ["claudeCode"],
    "appStoreConnect": "fastlane",
    "ci": {"githubActions": {"configuration": {
      "matrix": {
        "feature": {"exclude": [], "include": []},
        "main": {"exclude": [], "include": []},
        "version": {"exclude": [], "include": []}
      },
      "runners": {"selfHosted": {"labels": ["self-hosted", "macOS"],
                                 "xcodes": ["/Applications/Xcode.app"]}},
      "workflows": ["ci", "appStoreMetadata", "appStoreSession", "cleanup", "claude"]
    }}},
    "crossPlatform": true,
    "devcontainer": true,
    "distribution": ["appStore"],
    "generator": "tuist",
    "gitLFS": true,
    "header": {"file": {"path": "Scripts/header.mustache"}},
    "includeNightly": false,
    "license": "proprietary",
    "lint": ["swiftLint", "swiftFormat"],
    "localizations": ["en-US"],
    "name": "Acme",
    "pressKit": "uv",
    "profile": {"reference": {"name": "default"}},
    "screenshots": "fastlaneSnapshot",
    "taylrVersion": "1.0.0"
    """

  /// The settings of a package that `Package(name:)` leaves at their defaults, as JSON object
  /// members.
  internal static let packageSettingsJSON = """
    "agents": ["claudeCode"],
    "ci": {"githubActions": {"configuration": {
      "matrix": {
        "feature": {"exclude": [], "include": []},
        "main": {"exclude": [], "include": []},
        "version": {"exclude": [], "include": []}
      },
      "runners": {"selfHosted": {"labels": ["self-hosted", "macOS"],
                                 "xcodes": ["/Applications/Xcode.app"]}},
      "workflows": ["ci", "cleanup", "claude"]
    }}},
    "devcontainer": true,
    "gitLFS": false,
    "header": {"file": {"path": "Scripts/header.mustache"}},
    "includeNightly": false,
    "license": "mit",
    "lint": ["swiftLint", "swiftFormat"],
    "taylrVersion": "1.0.0"
    """

  internal static let serverAppJSON = """
    {
      \(appSettingsJSON),
      "packages": {"withServer": {"server": {
        \(packageSettingsJSON),
        "dependencies": [],
        "framework": {"hummingbird": {"routing": "openAPI"}},
        "platforms": [{"minimumVersion": "27", "name": "macOS"}]
      }}},
      "platforms": [
        {"minimumVersion": "27", "name": "iOS"},
        {"minimumVersion": "27", "name": "macOS"}
      ],
      "urls": {
        "marketing": "https://acme.example",
        "privacy": "https://acme.example/privacy",
        "support": "https://acme.example/support"
      }
    }
    """

  internal static let iOS272JSON = """
    {
      \(appSettingsJSON),
      "packages": {"appOnly": {}},
      "platforms": [{"minimumVersion": "27.2", "name": "iOS"}]
    }
    """

  internal static let fourPackageJSON = """
    {
      \(appSettingsJSON),
      "packages": {"custom": {
        "client": {
          \(packageSettingsJSON),
          "dependencies": [{"local": {"package": {
            \(packageSettingsJSON),
            "dependencies": [{"local": {"package": {
              \(packageSettingsJSON),
              "dependencies": [],
              "name": "AcmeModels",
              "platforms": []
            }}}],
            "name": "AcmeKit",
            "platforms": []
          }}}],
          "name": "AcmeApp",
          "platforms": []
        },
        "others": [],
        "server": {
          \(packageSettingsJSON),
          "dependencies": [{"local": {"package": {
            \(packageSettingsJSON),
            "dependencies": [],
            "name": "AcmeModels",
            "platforms": []
          }}}],
          "framework": {"hummingbird": {"routing": "builtIn"}},
          "platforms": [{"minimumVersion": "27", "name": "macOS"}]
        }
      }},
      "platforms": [
        {"minimumVersion": "27", "name": "iOS"},
        {"minimumVersion": "27", "name": "macOS"}
      ]
    }
    """
}
