import Testing

@testable import TaylrKit

@Suite("TaylrKit")
internal enum TaylrKitTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "TaylrKit"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: TaylrKit.self) == Self.expectedName)
    }
  }
}
