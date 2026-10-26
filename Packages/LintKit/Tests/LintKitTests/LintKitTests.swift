import Testing

@testable import LintKit

@Suite("LintKit")
internal enum LintKitTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "LintKit"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: LintKit.self) == Self.expectedName)
    }
  }
}
