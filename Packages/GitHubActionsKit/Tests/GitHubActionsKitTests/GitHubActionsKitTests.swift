import Testing

@testable import GitHubActionsKit

@Suite("GitHubActionsKit")
internal enum GitHubActionsKitTests {
  @Suite("Placeholder")
  internal struct PlaceholderTests {
    private static let expectedName = "GitHubActionsKit"

    @Test("The namespace is reachable from tests")
    internal func namespaceIsReachable() {
      #expect(String(describing: GitHubActionsKit.self) == Self.expectedName)
    }
  }
}
