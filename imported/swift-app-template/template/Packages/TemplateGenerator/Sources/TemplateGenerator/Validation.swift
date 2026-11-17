import Foundation

private let swiftKeywords: Set<String> = [
  // Declaration keywords
  "class", "struct", "enum", "protocol", "extension", "typealias",
  "associatedtype", "actor",

  // Statement keywords
  "func", "init", "deinit", "subscript", "var", "let", "import",
  "return", "if", "else", "switch", "case", "default", "where",
  "for", "in", "while", "repeat", "break", "continue", "fallthrough",
  "guard", "defer", "do", "catch", "throw", "throws", "rethrows",
  "try", "await", "async",

  // Expression and type keywords
  "as", "is", "Any", "Self", "self", "super", "nil", "true", "false",
  "_",

  // Pattern keywords
  "inout", "infix", "prefix", "postfix",

  // Access control
  "public", "private", "fileprivate", "internal", "open",

  // Attributes
  "available", "unavailable", "discardableResult", "dynamicCallable",
  "dynamicMemberLookup", "main", "objc", "testable", "escaping",
  "autoclosure", "convention", "frozen", "IBAction", "IBOutlet",
  "IBDesignable", "IBInspectable", "NSManaged", "NSCopying",
  "GKInspectable", "UIApplicationMain", "NSApplicationMain",

  // Type modifiers
  "static", "dynamic", "final", "lazy", "optional", "required",
  "convenience", "override", "mutating", "nonmutating", "indirect",
  "weak", "unowned",

  // Context keywords
  "Type", "Protocol"
]

func validateAppName(_ name: String) throws {
  guard !name.isEmpty else {
    throw GeneratorError.invalidAppName(name, reason: "App name cannot be empty")
  }

  let identifierPattern = "^[a-zA-Z_][a-zA-Z0-9_]*$"
  guard let regex = try? NSRegularExpression(pattern: identifierPattern),
        regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) != nil
  else {
    throw GeneratorError.invalidAppName(
      name,
      reason: "Must start with letter/underscore and contain only alphanumerics/underscores"
    )
  }

  if swiftKeywords.contains(name.lowercased()) {
    throw GeneratorError.invalidAppName(name, reason: "'\(name)' is a reserved Swift keyword")
  }
}
