import SyntaxKit

enum AppModelGenerator {
  static func generate(appName: String) -> String {
    let imports = [
      Import("Observation").generateCode()
    ].joined(separator: "\n")

    let classDecl = Class("AppModel") {
      Variable(.var, name: "count", type: "Int", equals: 0).access(.public)
      Initializer {}.access(.public)
    }
    .attribute("Observable")
    .attribute("MainActor")
    .access(.public)
    .final()
    .generateCode()

    return "\(imports)\n\n\(classDecl)"
  }
}
