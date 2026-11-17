import SyntaxKit

enum ServerCommandGenerator {
  static func generate(appName: String) -> String {
    let imports = [
      Import("ArgumentParser").generateCode(),
      Import("Foundation").generateCode()
    ].joined(separator: "\n")

    let mainStruct = Struct("\(appName)Server") {
      Variable(
        .let,
        name: "configuration",
        equals: Init("CommandConfiguration") {
          ParameterExp(name: "commandName", value: Literal.string("\(appName.lowercased())-server"))
          ParameterExp(name: "abstract", value: Literal.string("Run the \(appName) server."))
          ParameterExp(name: "subcommands", value: Literal.array([.ref("Serve.self")]))
          ParameterExp(name: "defaultSubcommand", value: VariableExp("Serve.self"))
        }
      ).`static`()
    }
    .attribute("main")
    .access(.internal)
    .inherits("AsyncParsableCommand")
    .generateCode()

    let extensionDecl = Extension("\(appName)Server") {
      Struct("Serve") {
        Variable(
          .let,
          name: "configuration",
          equals: Init("CommandConfiguration") {
            ParameterExp(name: "abstract", value: Literal.string("Start the HTTP server."))
          }
        ).`static`()
        Function("run") {
          Call("print") {
            ParameterExp(unlabeled: Literal.string("\(appName) server starting..."))
          }
        }
        .access(.internal)
        .async()
        .throwing()
      }
      .access(.internal)
      .inherits("AsyncParsableCommand")
    }
    .generateCode()

    return "\(imports)\n\n\(mainStruct)\n\n\(extensionDecl)"
  }
}
