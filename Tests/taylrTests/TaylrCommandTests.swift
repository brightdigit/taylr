import Testing

@testable import taylr

@Suite("taylr")
internal enum TaylrCommandTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedPrefix = "taylr is in development"

    @Test("The placeholder message says taylr is in development")
    internal func messageSaysInDevelopment() {
      #expect(Taylr.message.hasPrefix(Self.expectedPrefix))
    }
  }
}
