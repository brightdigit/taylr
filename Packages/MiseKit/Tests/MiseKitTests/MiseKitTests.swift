import Testing

@testable import MiseKit

@Suite("MiseKit")
internal enum MiseKitTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "MiseKit"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: MiseKit.self) == Self.expectedName)
    }
  }
}
