import Foundation
import Testing

@testable import TaylrDescription

@Suite("Agent")
internal enum AgentTests {
  @Suite("Codable")
  internal struct CodableTests {
    @Test("claudeCode round-trips as a plain string")
    internal func roundTrips() throws {
      let data = try JSONEncoder().encode(Agent.claudeCode)
      #expect(String(decoding: data, as: UTF8.self) == "\"claudeCode\"")
      #expect(try JSONDecoder().decode(Agent.self, from: data) == .claudeCode)
    }

    @Test("An empty list of agents round-trips")
    internal func emptyListRoundTrips() throws {
      let data = try JSONEncoder().encode([Agent]())
      #expect(try JSONDecoder().decode([Agent].self, from: data).isEmpty)
    }
  }
}
