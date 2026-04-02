import Testing

@testable import TemplateGenerator

@Suite("Server Entry Generator")
internal struct ServerEntryGeneratorTests {
  @Test("Generates server entry point with await main()")
  internal func generatesServerEntry() {
    let generated = ServerEntryGenerator.generate(appName: "TestApp")
    let expected = """
      import TestAppServer

      await TestAppServer.main()
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generates correct code for app name with underscores")
  internal func generatesWithUnderscores() {
    let generated = ServerEntryGenerator.generate(appName: "My_Weather_App")
    let expected = """
      import My_Weather_AppServer

      await My_Weather_AppServer.main()
      """
    #expect(generated.normalize() == expected.normalize())
  }

  @Test("Generated code imports server module")
  internal func containsServerImport() {
    let generated = ServerEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("import TestAppServer"))
  }

  @Test("Generated code awaits main()")
  internal func awaitsMain() {
    let generated = ServerEntryGenerator.generate(appName: "TestApp")
    #expect(generated.contains("await"))
    #expect(generated.contains(".main()"))
  }

  @Test("Generated code is minimal")
  internal func isMinimal() {
    let generated = ServerEntryGenerator.generate(appName: "TestApp")
    let lines = generated.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    #expect(lines.count == 2)  // Just import and await
  }
}
