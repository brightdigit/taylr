import Testing

@testable import ScaffoldKit

@Suite("ScaffoldKit")
internal enum ScaffoldKitTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "ScaffoldKit"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: ScaffoldKit.self) == Self.expectedName)
    }
  }
}
