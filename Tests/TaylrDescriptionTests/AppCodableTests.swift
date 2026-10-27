import Foundation
import Testing

@testable import TaylrDescription

@Suite("App JSON")
internal enum AppCodableTests {
  @Suite("Codable")
  internal struct CodableTests {
    private static func decode(_ json: String) throws -> App {
      try JSONDecoder().decode(App.self, from: Data(json.utf8))
    }

    @Test("Each reference example encodes and decodes back equal")
    internal func roundTrips() throws {
      for app in [AppFixtures.serverApp, AppFixtures.iOS272App, AppFixtures.fourPackageApp] {
        let data = try JSONEncoder().encode(app)
        #expect(try JSONDecoder().decode(App.self, from: data) == app)
      }
    }

    @Test("The app with a server decodes from JSON")
    internal func decodesServerApp() throws {
      let app = try Self.decode(AppFixtures.serverAppJSON)
      #expect(app == AppFixtures.serverApp)
      #expect(app.packages == .withServer(.server(framework: .hummingbird(routing: .openAPI))))
      #expect(app.urls == .base("https://acme.example"))
    }

    @Test("The iOS 27.2 app decodes from JSON")
    internal func decodesIOS272App() throws {
      let app = try Self.decode(AppFixtures.iOS272JSON)
      #expect(app == AppFixtures.iOS272App)
      #expect(app.platforms == [.iOS("27.2")])
    }

    @Test("The four-package app decodes from JSON")
    internal func decodesFourPackageApp() throws {
      let app = try Self.decode(AppFixtures.fourPackageJSON)
      #expect(app == AppFixtures.fourPackageApp)
      let names = try app.packages.resolvedPackages(appName: "Acme").map(\.name)
      #expect(names == ["AcmeApp", "AcmeKit", "AcmeModels", "AcmeServer"])
    }

    @Test("Options spelled out in JSON decode to their cases")
    internal func decodesOptions() throws {
      let app = try Self.decode(AppFixtures.iOS272JSON)
      #expect(app.appStoreConnect == .fastlane)
      #expect(app.screenshots == .fastlaneSnapshot)
      #expect(app.distribution == [.appStore])
      #expect(app.pressKit == .uv)
      #expect(app.generator == .tuist)
    }
  }
}
