import Foundation
import Testing

@testable import TaylrDescription

@Suite("ServerFramework")
internal enum ServerFrameworkTests {
  @Suite("Hummingbird")
  internal struct HummingbirdTests {
    @Test("hummingbird() routes with the built-in router")
    internal func defaultsToBuiltIn() {
      #expect(HummingbirdServer.hummingbird().serialization == .hummingbird(routing: .builtIn))
    }

    @Test("The two routings are different frameworks")
    internal func routingsDiffer() {
      let openAPI = HummingbirdServer(routing: .openAPI)
      #expect(!HummingbirdServer.serializesEqually(openAPI, HummingbirdServer()))
    }
  }

  @Suite("Codable")
  internal struct CodableTests {
    private static let frameworks: [ServerFrameworkSerialization] = [
      .hummingbird(),
      .hummingbird(routing: .builtIn),
      .hummingbird(routing: .openAPI),
    ]

    @Test("Every framework survives an encode and decode", arguments: frameworks)
    internal func roundTrips(framework: ServerFrameworkSerialization) throws {
      let data = try JSONEncoder().encode(framework)
      #expect(try JSONDecoder().decode(ServerFrameworkSerialization.self, from: data) == framework)
    }

    @Test("A framework encodes under labeled keys")
    internal func encodesLabeled() throws {
      let framework = ServerFrameworkSerialization.hummingbird(routing: .openAPI)
      let data = try JSONEncoder().encode(framework)
      #expect(String(decoding: data, as: UTF8.self) == #"{"hummingbird":{"routing":"openAPI"}}"#)
    }

    @Test("Routing encodes as its case name")
    internal func routingIsPlainString() throws {
      let data = try JSONEncoder().encode(HummingbirdServer.Routing.openAPI)
      #expect(String(decoding: data, as: UTF8.self) == "\"openAPI\"")
    }
  }
}
