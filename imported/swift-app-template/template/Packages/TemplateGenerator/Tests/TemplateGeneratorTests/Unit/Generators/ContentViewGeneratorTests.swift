import Testing

@testable import TemplateGenerator

@Suite("Content View Generator")
internal struct ContentViewGeneratorTests {
  @Test("Generates ContentView with Environment model")
  internal func generatesContentView() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    let expected = """
      #if canImport(SwiftUI)
      import SwiftUI
      import TestAppKit

      internal struct ContentView: View {
        @Environment(TestAppKit.AppModel.self) private var model
        internal var body: some View {
          PrimaryView()
        }
      }
      #endif
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = ContentViewGenerator.generate(appName: "My_Weather_App")
    let expected = """
      #if canImport(SwiftUI)
      import SwiftUI
      import My_Weather_AppKit

      internal struct ContentView: View {
        @Environment(My_Weather_AppKit.AppModel.self) private var model
        internal var body: some View {
          PrimaryView()
        }
      }
      #endif
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generated code imports SwiftUI and Kit package")
  internal func containsRequiredImports() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import SwiftUI"))
    #expect(generated.contains("import TestAppKit"))
  }

  @Test("Generated code contains @Environment attribute")
  internal func containsEnvironmentAttribute() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@Environment"))
  }

  @Test("Generated code references AppModel from Kit package")
  internal func referencesKitAppModel() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("TestAppKit.AppModel.self"))
  }

  @Test("Generated code conforms to View protocol")
  internal func conformsToViewProtocol() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    #expect(generated.normalizeStructural().contains(":View"))
  }

  @Test("Generated code contains body property")
  internal func containsBodyProperty() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("var body"))
    #expect(generated.contains("some View"))
  }

  @Test("Generated code instantiates PrimaryView")
  internal func instantiatesPrimaryView() {
    let generated = ContentViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("PrimaryView()"))
  }
}
