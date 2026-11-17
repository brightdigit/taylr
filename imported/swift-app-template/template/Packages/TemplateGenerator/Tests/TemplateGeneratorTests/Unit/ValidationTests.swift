import Testing

@testable import TemplateGenerator

@Suite("Input Validation")
internal struct ValidationTests {
  @Test("Valid app names are accepted")
  internal func acceptsValidAppNames() throws {
    // Simple names
    try validateAppName("MyApp")
    try validateAppName("TestApp")
    try validateAppName("X")

    // Names with underscores
    try validateAppName("My_Weather_App")
    try validateAppName("_Private")

    // Names with numbers
    try validateAppName("App2")
    try validateAppName("Test123")
  }

  @Test("Empty app name is rejected")
  internal func rejectsEmptyName() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("")
    }
  }

  @Test("App name starting with number is rejected")
  internal func rejectsNameStartingWithNumber() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("2Fast")
    }
  }

  @Test("App name with spaces is rejected")
  internal func rejectsNameWithSpaces() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("My App")
    }
  }

  @Test("App name with hyphens is rejected")
  internal func rejectsNameWithHyphens() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("My-App")
    }
  }

  @Test("App name with special characters is rejected")
  internal func rejectsNameWithSpecialChars() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("My@App")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("My.App")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("My!App")
    }
  }

  @Test("Swift keywords are rejected")
  internal func rejectsSwiftKeywords() {
    // Common keywords
    #expect(throws: GeneratorError.self) {
      try validateAppName("class")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("struct")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("enum")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("protocol")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("import")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("func")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("var")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("let")
    }
  }

  @Test("Swift keywords are case-insensitive")
  internal func rejectsKeywordsCaseInsensitive() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("Class")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("STRUCT")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("Enum")
    }
  }

  @Test("Context identifiers are rejected")
  internal func rejectsContextIdentifiers() {
    #expect(throws: GeneratorError.self) {
      try validateAppName("self")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("Self")
    }
    #expect(throws: GeneratorError.self) {
      try validateAppName("super")
    }
  }

  @Test("Error messages are descriptive")
  internal func errorMessagesAreDescriptive() {
    do {
      try validateAppName("")
      Issue.record("Should have thrown error")
    } catch let error as GeneratorError {
      let message = error.errorDescription ?? ""
      #expect(message.contains("empty"))
    } catch {
      Issue.record("Wrong error type")
    }

    do {
      try validateAppName("class")
      Issue.record("Should have thrown error")
    } catch let error as GeneratorError {
      let message = error.errorDescription ?? ""
      #expect(message.contains("keyword"))
    } catch {
      Issue.record("Wrong error type")
    }

    do {
      try validateAppName("My-App")
      Issue.record("Should have thrown error")
    } catch let error as GeneratorError {
      let message = error.errorDescription ?? ""
      #expect(message.contains("letter") || message.contains("underscore") || message.contains("alphanumeric"))
    } catch {
      Issue.record("Wrong error type")
    }
  }
}
