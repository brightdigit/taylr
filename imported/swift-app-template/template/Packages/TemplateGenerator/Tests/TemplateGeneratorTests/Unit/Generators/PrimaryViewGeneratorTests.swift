import Testing

@testable import TemplateGenerator

@Suite("Primary View Generator")
internal struct PrimaryViewGeneratorTests {
  @Test("Generates PrimaryView with VStack and Text elements")
  internal func generatesPrimaryView() {
    let generated = PrimaryViewGenerator.generate(appName: "TestApp")
    let expected = """
      #if canImport(SwiftUI)
      import SwiftUI
      import TestAppKit

      internal struct PrimaryView: View {
        @Environment(TestAppKit.AppModel.self) private var model
        internal var body: some View {
          VStack {
            Text("TestApp").font(.title)
            Text("Count: \\(model.count)")
          }
        }
      }
      #endif
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = PrimaryViewGenerator.generate(appName: "My_Weather_App")
    let expected = """
      #if canImport(SwiftUI)
      import SwiftUI
      import My_Weather_AppKit

      internal struct PrimaryView: View {
        @Environment(My_Weather_AppKit.AppModel.self) private var model
        internal var body: some View {
          VStack {
            Text("My_Weather_App").font(.title)
            Text("Count: \\(model.count)")
          }
        }
      }
      #endif
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generated code displays app name in Text")
  internal func displaysAppNameInText() {
    let generated = PrimaryViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("Text(\"TestApp\")"))
  }

  @Test("Generated code contains VStack")
  internal func containsVStack() {
    let generated = PrimaryViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("VStack"))
  }

  @Test("Generated code contains count text")
  internal func containsCountText() {
    let generated = PrimaryViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("Count:"))
    #expect(generated.contains("model.count"))
  }

  @Test("Generated code applies title font")
  internal func appliesTitleFont() {
    let generated = PrimaryViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains(".font(.title)"))
  }

  @Test("Generated code references model from environment")
  internal func referencesEnvironmentModel() {
    let generated = PrimaryViewGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@Environment"))
    #expect(generated.contains("private var model"))
  }
}
