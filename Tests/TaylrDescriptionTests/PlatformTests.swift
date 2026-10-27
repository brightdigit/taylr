import Foundation
import Testing

@testable import TaylrDescription

@Suite("Platform")
internal enum PlatformTests {
  @Suite("Platform")
  internal struct PlatformBehaviorTests {
    private static let defaultJSON = #"{"minimumVersion":"27","name":"iOS"}"#
    private static let decodableJSON = #"{"name":"tvOS","minimumVersion":"27.1"}"#
    private static let all: [(Platform, String)] = [
      (.iOS(), "iOS"), (.macOS(), "macOS"), (.tvOS(), "tvOS"),
      (.watchOS(), "watchOS"), (.visionOS(), "visionOS"),
    ]

    private static func encoder() -> JSONEncoder {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys]
      return encoder
    }

    @Test("iOS() encodes as iOS 27")
    internal func defaultEncodesAs27() throws {
      let data = try Self.encoder().encode(Platform.iOS())
      #expect(String(decoding: data, as: UTF8.self) == Self.defaultJSON)
    }

    @Test("visionOS(\"27.2\") round-trips")
    internal func visionOSRoundTrips() throws {
      let platform = Platform.visionOS("27.2")
      let data = try Self.encoder().encode(platform)
      let decoded = try JSONDecoder().decode(Platform.self, from: data)
      #expect(decoded == platform)
      #expect(decoded.minimumVersion.rawValue == "27.2")
    }

    @Test("macOS(.v27) equals macOS()")
    internal func explicitEqualsDefault() {
      #expect(Platform.macOS(.v27) == Platform.macOS())
    }

    @Test("Each platform has its name and a default minimum of 27")
    internal func names() {
      for (platform, name) in Self.all {
        #expect(platform.name == name)
        #expect(platform.minimumVersion == .v27)
      }
    }

    @Test("Different platforms and versions are not equal")
    internal func inequality() {
      #expect(Platform.iOS() != Platform.macOS())
      #expect(Platform.iOS("27.2") != Platform.iOS())
    }

    @Test("Decodes from JSON")
    internal func decodes() throws {
      let decoded = try JSONDecoder().decode(Platform.self, from: Data(Self.decodableJSON.utf8))
      #expect(decoded == Platform.tvOS("27.1"))
    }
  }

  @Suite("PlatformVersion")
  internal struct PlatformVersionTests {
    private static let encodedJSON = #"{"v":"27"}"#
    private static let unnormalizedJSON = #"{"v":"27.0"}"#

    @Test("\"27\", \"27.0\" and .v27 are equal")
    internal func normalizes() {
      let plain: PlatformVersion = "27"
      let zero: PlatformVersion = "27.0"
      let zeros: PlatformVersion = "27.0.0"
      #expect(plain == .v27)
      #expect(zero == .v27)
      #expect(zeros == .v27)
      #expect(zero.rawValue == "27")
    }

    @Test("A non-zero minor is kept")
    internal func keepsMinor() {
      let version: PlatformVersion = "27.2"
      #expect(version != .v27)
      #expect(version.rawValue == "27.2")
    }

    @Test("Encodes as a single string and decodes normalized")
    internal func codable() throws {
      let data = try JSONEncoder().encode(["v": PlatformVersion.v27])
      #expect(String(decoding: data, as: UTF8.self) == Self.encodedJSON)
      let json = Data(Self.unnormalizedJSON.utf8)
      let decoded = try JSONDecoder().decode([String: PlatformVersion].self, from: json)
      #expect(decoded["v"] == .v27)
    }
  }
}
