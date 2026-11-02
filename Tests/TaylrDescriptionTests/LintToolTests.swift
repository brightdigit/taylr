import Foundation
import Testing

@testable import TaylrDescription

@Suite("LintTool")
internal enum LintToolTests {
  @Suite("Codable")
  internal struct CodableTests {
    private static let cases: [(tool: LintTool, name: String)] = [
      (.swiftLint, "swiftLint"),
      (.swiftFormat, "swiftFormat"),
      (.periphery, "periphery"),
    ]

    @Test("Every tool round-trips as a plain string")
    internal func roundTrips() throws {
      for entry in Self.cases {
        let data = try JSONEncoder().encode(entry.tool)
        #expect(String(decoding: data, as: UTF8.self) == "\"\(entry.name)\"")
        #expect(try JSONDecoder().decode(LintTool.self, from: data) == entry.tool)
      }
    }

    @Test("An array of tools round-trips")
    internal func arrayRoundTrips() throws {
      let tools: [LintTool] = [.swiftLint, .swiftFormat, .periphery]
      let data = try JSONEncoder().encode(tools)
      #expect(try JSONDecoder().decode([LintTool].self, from: data) == tools)
    }

    @Test("An unknown tool fails to decode")
    internal func unknownFails() {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(LintTool.self, from: Data("\"unknown\"".utf8))
      }
    }
  }

  @Suite("configurationFile")
  internal struct ConfigurationFileTests {
    @Test("Each tool names its own configuration file")
    internal func configurationFiles() {
      #expect(LintTool.swiftLint.configurationFile == ".swiftlint.yml")
      #expect(LintTool.swiftFormat.configurationFile == ".swift-format")
      #expect(LintTool.periphery.configurationFile == ".periphery.yml")
    }

    @Test("Every tool has its own configuration file", arguments: LintTool.allCases)
    internal func everyToolHasFile(tool: LintTool) {
      #expect(tool.configurationFile != ".\(tool.rawValue)")
    }
  }
}
