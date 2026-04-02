import Testing

@testable import TemplateGenerator

@Suite("App Model Generator")
internal struct AppModelGeneratorTests {
  @Test("Generates Observable MainActor class")
  internal func generatesObservableClass() {
    let generated = AppModelGenerator.generate(appName: "TestApp")
    let expected = """
      import Observation

      @Observable
      @MainActor
      public final class AppModel {
        public var count: Int = 0
        public init() { }
      }
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = AppModelGenerator.generate(appName: "My_Weather_App")
    let expected = """
      import Observation

      @Observable
      @MainActor
      public final class AppModel {
        public var count: Int = 0
        public init() { }
      }
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generates correct code for single character app name")
  internal func generatesWithSingleChar() {
    let generated = AppModelGenerator.generate(appName: "X")
    let expected = """
      import Observation

      @Observable
      @MainActor
      public final class AppModel {
        public var count: Int = 0
        public init() { }
      }
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generated code contains required imports")
  internal func containsRequiredImports() {
    let generated = AppModelGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import Observation"))
  }

  @Test("Generated code contains Observable attribute")
  internal func containsObservableAttribute() {
    let generated = AppModelGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@Observable"))
  }

  @Test("Generated code contains MainActor attribute")
  internal func containsMainActorAttribute() {
    let generated = AppModelGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@MainActor"))
  }

  @Test("Generated code is public and final")
  internal func isPublicAndFinal() {
    let generated = AppModelGenerator.generate(appName: "TestApp")
    #expect(generated.contains("public final class"))
  }
}
