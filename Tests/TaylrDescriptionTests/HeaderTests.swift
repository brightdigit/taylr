import Foundation
import Testing

@testable import TaylrDescription

@Suite("Header")
internal enum HeaderTests {
  @Suite("Codable")
  internal struct CodableTests {
    private static let path = "Scripts/our-header.mustache"

    @Test("file keeps its path through a round trip")
    internal func fileRoundTrips() throws {
      let header = Header.file(Self.path)
      let data = try JSONEncoder().encode(header)
      #expect(try JSONDecoder().decode(Header.self, from: data) == header)
    }

    @Test("Different paths are not equal")
    internal func differentPathsDiffer() {
      #expect(Header.file(Self.path) != Header.file("Scripts/header.mustache"))
    }

    @Test("An optional header round-trips both as nil and as a file")
    internal func optionalRoundTrips() throws {
      let headers: [Header?] = [nil, .file(Self.path)]
      let data = try JSONEncoder().encode(headers)
      #expect(try JSONDecoder().decode([Header?].self, from: data) == headers)
    }
  }
}
