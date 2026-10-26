import Testing

@testable import DevContainerKit

@Suite("DevContainerKit")
internal enum DevContainerKitTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "DevContainerKit"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: DevContainerKit.self) == Self.expectedName)
    }
  }
}
