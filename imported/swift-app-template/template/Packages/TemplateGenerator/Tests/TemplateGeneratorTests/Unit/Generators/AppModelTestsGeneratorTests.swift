import Testing

@testable import TemplateGenerator

@Suite("App Model Tests Generator")
internal struct AppModelTestsGeneratorTests {
  @Test("Generates test file with Swift Testing patterns")
  internal func generatesTestFile() {
    let generated = AppModelTestsGenerator.generate(appName: "TestApp")
    let expected = """
      import Testing
      @testable import TestAppKit

      @Suite("App Model")
      internal struct AppModelTests {
        private static let initialCount = 0

        @Test("Initial count is zero")
        internal func initialCount() {
          #expect(Self.initialCount == 0)
        }
      }
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = AppModelTestsGenerator.generate(appName: "My_Weather_App")
    let expected = """
      import Testing
      @testable import My_Weather_AppKit

      @Suite("App Model")
      internal struct AppModelTests {
        private static let initialCount = 0

        @Test("Initial count is zero")
        internal func initialCount() {
          #expect(Self.initialCount == 0)
        }
      }
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generated code imports Testing framework")
  internal func containsTestingImport() {
    let generated = AppModelTestsGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import Testing"))
  }

  @Test("Generated code contains @testable import")
  internal func containsTestableImport() {
    let generated = AppModelTestsGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@testable import"))
  }

  @Test("Generated code contains @Suite attribute")
  internal func containsSuiteAttribute() {
    let generated = AppModelTestsGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@Suite"))
  }

  @Test("Generated code contains @Test attribute")
  internal func containsTestAttribute() {
    let generated = AppModelTestsGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@Test"))
  }

  @Test("Generated code uses #expect macro")
  internal func usesExpectMacro() {
    let generated = AppModelTestsGenerator.generate(appName: "TestApp")
    #expect(generated.contains("#expect"))
  }
}
