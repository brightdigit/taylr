import Foundation
import Testing

@testable import TaylrDescription

@Suite("ServerFramework")
internal enum ServerFrameworkTests {
  @Suite("Hummingbird")
  internal struct HummingbirdTests {
    @Test("hummingbird() routes with the built-in router")
    internal func defaultsToBuiltIn() {
      #expect(ServerFramework.hummingbird() == .hummingbird(routing: .builtIn))
    }

    @Test("The two routings are different frameworks")
    internal func routingsDiffer() {
      #expect(ServerFramework.hummingbird(routing: .openAPI) != .hummingbird(routing: .builtIn))
    }
  }

  @Suite("Codable")
  internal struct CodableTests {
    private static let frameworks: [ServerFramework] = [
      .hummingbird(),
      .hummingbird(routing: .builtIn),
      .hummingbird(routing: .openAPI),
    ]

    @Test("Every framework survives an encode and decode", arguments: frameworks)
    internal func roundTrips(framework: ServerFramework) throws {
      let data = try JSONEncoder().encode(framework)
      #expect(try JSONDecoder().decode(ServerFramework.self, from: data) == framework)
    }

    @Test("Routing encodes as its case name")
    internal func routingIsPlainString() throws {
      let data = try JSONEncoder().encode(ServerFramework.Routing.openAPI)
      #expect(String(decoding: data, as: UTF8.self) == "\"openAPI\"")
    }
  }
}
