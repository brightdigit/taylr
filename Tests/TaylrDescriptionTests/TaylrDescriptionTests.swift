import Testing

@testable import TaylrDescription

@Suite("TaylrDescription")
internal enum TaylrDescriptionTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "TaylrDescription"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: TaylrDescription.self) == Self.expectedName)
    }
  }
}
