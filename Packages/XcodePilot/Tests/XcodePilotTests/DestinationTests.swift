import Foundation
import Testing

@testable import XcodePilot

@Suite("Destination")
internal enum DestinationTests {
  @Suite("parseFrom(output:)")
  internal struct ParseTests {
    /// Sample `xcodebuild -showdestinations` output for an `Acme` scheme.
    private static let fixtureURL = Bundle.module.url(
      forResource: "showdestinations",
      withExtension: "txt",
      subdirectory: "Fixtures"
    )

    private static let macID = "00006000-000A1B2C3D4E5F60"
    private static let simulatorID = "6F1D2E3C-4B5A-4978-8695-A4B3C2D1E0F9"
    private static let placeholderID = "dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder"

    private static func parsedFixture() throws -> [Destination] {
      let url = try #require(fixtureURL)
      return Destination.parseFrom(output: try String(contentsOf: url, encoding: .utf8))
    }

    @Test("Every destination line is parsed and other lines are skipped")
    internal func parsesEveryDestination() throws {
      let destinations = try Self.parsedFixture()
      #expect(destinations.count == 6)
    }

    @Test("A macOS destination keeps its arch, id and name")
    internal func parsesMacDestination() throws {
      let destination = try #require(try Self.parsedFixture().first)
      #expect(
        destination
          == Destination(platform: "macOS", arch: "arm64", id: Self.macID, name: "My Mac")
      )
    }

    @Test("A variant with a comma inside brackets stays whole")
    internal func keepsBracketedVariant() throws {
      let destinations = try Self.parsedFixture()
      #expect(destinations[1].variant == "Designed for [iPad,iPhone]")
      #expect(destinations[1].id == Self.macID)
      #expect(destinations[1].name == "My Mac")
    }

    @Test("A simulator destination keeps its OS version")
    internal func parsesSimulatorOS() throws {
      let destination = try Self.parsedFixture()[2]
      #expect(destination.platform == "iOS Simulator")
      #expect(destination.operatingSystem == "26.0")
      #expect(destination.name == "iPhone 17 Pro")
    }

    @Test("An id containing a colon stays whole")
    internal func keepsColonInID() throws {
      let destination = try #require(try Self.parsedFixture().last)
      #expect(destination.id == Self.placeholderID)
      #expect(destination.name == "Any iOS Device")
    }

    @Test("The description is the destination specifier")
    internal func describesSpecifier() throws {
      let destination = try Self.parsedFixture()[2]
      #expect(
        destination.description
          == "platform:iOS Simulator, arch:arm64, id:\(Self.simulatorID), OS:26.0, name:iPhone 17 Pro"
      )
    }

    @Test("A line without a name is not a destination")
    internal func rejectsLineWithoutName() {
      #expect(Destination(line: "{ platform:macOS, arch:arm64 }") == nil)
    }
  }
}
