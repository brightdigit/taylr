import SyntaxKit

enum ServerEntryGenerator {
  static func generate(appName: String) -> String {
    let imports = [
      Import("\(appName)Server").generateCode()
    ].joined(separator: "\n")

    return "\(imports)\n\nawait \(appName)Server.main()"
  }
}
