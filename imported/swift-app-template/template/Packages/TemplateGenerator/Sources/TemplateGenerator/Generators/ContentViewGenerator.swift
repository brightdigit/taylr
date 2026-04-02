import SyntaxKit

enum ContentViewGenerator {
  static func generate(appName: String) -> String {
    IfCanImport("SwiftUI") {
      Import("SwiftUI")
      Import("\(appName)Kit")
      Struct("ContentView") {
        Variable(.var, name: "model", type: "")
          .attribute("Environment", arguments: ["\(appName)Kit.AppModel.self"])
          .access(.private)
        ComputedProperty("body", type: "some View") {
          Init("PrimaryView")
        }.access(.internal)
      }
      .access(.internal)
      .inherits("View")
    }
    .generateCode()
  }
}
