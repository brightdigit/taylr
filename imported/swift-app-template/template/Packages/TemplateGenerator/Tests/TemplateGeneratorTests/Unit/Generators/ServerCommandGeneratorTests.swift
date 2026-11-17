import Testing

@testable import TemplateGenerator

@Suite("Server Command Generator")
internal struct ServerCommandGeneratorTests {
  @Test("Generates @main AsyncParsableCommand with Serve subcommand")
  internal func generatesServerCommand() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    // Use structural normalization for this test since formatting may vary
    #expect(generated.normalizeStructural().contains("@main"))
    #expect(generated.normalizeStructural().contains("TestAppServer:AsyncParsableCommand"))
    #expect(generated.normalizeStructural().contains("CommandConfiguration"))
    #expect(generated.normalizeStructural().contains("testapp-server"))
    #expect(generated.normalizeStructural().contains("Serve.self"))
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = ServerCommandGenerator.generate(appName: "My_Weather_App")
    #expect(generated.contains("My_Weather_AppServer"))
    #expect(generated.contains("my_weather_app-server"))
    #expect(generated.contains("Run the My_Weather_App server"))
  }

  @Test("Generated code imports ArgumentParser and Foundation")
  internal func containsRequiredImports() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import ArgumentParser"))
    #expect(generated.contains("import Foundation"))
  }

  @Test("Generated code contains @main attribute")
  internal func containsMainAttribute() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("@main"))
  }

  @Test("Generated code conforms to AsyncParsableCommand")
  internal func conformsToAsyncParsableCommand() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("AsyncParsableCommand"))
  }

  @Test("Generated code contains CommandConfiguration")
  internal func containsCommandConfiguration() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("CommandConfiguration"))
  }

  @Test("Generated code contains Serve subcommand")
  internal func containsServeSubcommand() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("struct Serve"))
    #expect(generated.contains("Serve.self"))
  }

  @Test("Generated code contains async throwing run method")
  internal func containsAsyncThrowingRun() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("func run()"))
    #expect(generated.contains("async"))
    #expect(generated.contains("throws"))
  }

  @Test("Generated code lowercases app name in command name")
  internal func lowercasesAppNameInCommandName() {
    let generated = ServerCommandGenerator.generate(appName: "TestApp")
    #expect(generated.contains("testapp-server"))
  }
}
