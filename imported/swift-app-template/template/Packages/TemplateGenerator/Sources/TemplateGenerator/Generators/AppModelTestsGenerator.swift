import SyntaxKit

enum AppModelTestsGenerator {
  static func generate(appName: String) -> String {
    let imports = [
      Import("Testing").generateCode(),
      Import("\(appName)Kit").attribute("testable").generateCode()
    ].joined(separator: "\n")

    return """
      \(imports)

      @Suite("App Model")
      internal struct AppModelTests {
        private static let initialCount = 0

        @Test("Initial count is zero")
        internal func initialCount() {
          #expect(Self.initialCount == 0)
        }
      }
      """
  }
}
