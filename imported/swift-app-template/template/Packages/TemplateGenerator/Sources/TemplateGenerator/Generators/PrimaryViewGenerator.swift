import SyntaxKit

enum PrimaryViewGenerator {
  static func generate(appName: String) -> String {
    IfCanImport("SwiftUI") {
      Import("SwiftUI")
      Import("\(appName)Kit")
      Struct("PrimaryView") {
        Variable(.var, name: "model", type: "")
          .attribute("Environment", arguments: ["\(appName)Kit.AppModel.self"])
          .access(.private)
        ComputedProperty("body", type: "some View") {
          Init("VStack") {
            ParameterExp(
              unlabeled: Closure {
                Init("Text") {
                  ParameterExp(unlabeled: Literal.string(appName))
                }
                .call("font") {
                  ParameterExp(unlabeled: VariableExp(".title"))
                }
                Init("Text") {
                  ParameterExp(unlabeled: Literal.string("Count: \\(model.count)"))
                }
              }
            )
          }
        }.access(.internal)
      }
      .access(.internal)
      .inherits("View")
    }
    .generateCode()
  }
}
