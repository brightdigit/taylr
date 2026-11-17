import Testing

@testable import TemplateGenerator

@Suite("App Entry Generator")
internal struct AppEntryGeneratorTests {
  @Test("Generates App protocol with model requirement and default body")
  internal func generatesAppProtocol() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import SwiftUI"))
    #expect(generated.contains("import TestAppKit"))
    #expect(generated.contains("protocol TestAppApp"))
    #expect(generated.normalizeStructural().contains(":App"))
    #expect(generated.contains("var model: AppModel"))
    #expect(generated.contains("WindowGroup"))
    #expect(generated.contains("ContentView()"))
    #expect(generated.contains(".environment(model)"))
    #expect(!generated.contains("@main"))
    #expect(!generated.contains("@State"))
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = AppEntryGenerator.generate(appName: "My_Weather_App")
    #expect(generated.contains("import My_Weather_AppKit"))
    #expect(generated.contains("protocol My_Weather_AppApp"))
  }

  @Test("Generated code imports SwiftUI and Kit package")
  internal func containsRequiredImports() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import SwiftUI"))
    #expect(generated.contains("import TestAppKit"))
  }

  @Test("Generated protocol conforms to App")
  internal func conformsToAppProtocol() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.normalizeStructural().contains(":App"))
  }

  @Test("Generated protocol has model property requirement")
  internal func hasModelRequirement() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("var model: AppModel"))
  }

  @Test("Generated extension provides WindowGroup body")
  internal func hasWindowGroupBody() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("WindowGroup"))
  }

  @Test("Generated code injects model into environment")
  internal func injectsModelIntoEnvironment() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains(".environment(model)"))
  }

  @Test("Generated protocol name matches app name")
  internal func protocolNameMatchesAppName() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("protocol TestAppApp"))
  }

  @Test("Generated file does not contain @main")
  internal func doesNotContainMainAttribute() {
    let generated = AppEntryGenerator.generate(appName: "TestApp")
    #expect(!generated.contains("@main"))
  }
}
