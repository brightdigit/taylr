// Define a structure to represent a destination
struct Destination: CustomStringConvertible {
  var description: String {
    var components: [String] = ["platform:\(platform)"]

    if let arch = arch {
      components.append("arch:\(arch)")
    }

    if let variant = variant {
      components.append("variant:\(variant)")
    }

    if let id = id {
      components.append("id:\(id)")
    }
    
    if let OS {
      components.append("OS:\(OS)")
    }

    components.append("name:\(name)")

    return components.joined(separator: ", ")
  }
  public init(
    platform: String, arch: String? = nil, id: String? = nil, name: String, OS: String? = nil, variant: String? = nil
  ) {
    self.platform = platform
    self.arch = arch
    self.id = id
    self.name = name
    self.variant = variant
    self.OS = OS
  }

  private init?(
    platform: String?, arch: String? = nil, id: String? = nil, name: String?, OS : String? = nil, variant: String? = nil
  ) {
    guard let name, let platform else {
      return nil
    }
    self.platform = platform
    self.arch = arch
    self.id = id
    self.name = name
    self.variant = variant
    self.OS = OS
  }

  static let destinationPrefix = "{ platform:"

  // Function to parse the output and create Destination structures
  static func parseFrom(output: String) -> [Destination] {
    var destinations = [Destination]()
    let lines = output.components(separatedBy: .newlines)
    let destinationPrefix = "{ platform:"

    for line in lines {
      guard line.contains(destinationPrefix) else { continue }

      // Clean up the line and split by comma
      let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst().dropLast()
      let components = cleanLine.split(separator: ",")

      var platform = ""
      var arch: String? = nil
      var id: String? = nil
      var name = ""
      var OS : String? = nil
      var variant: String? = nil

      for component in components {
        let keyValue = component.split(separator: ":").map {
          $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if keyValue.count == 2 {
          let key = keyValue[0]
          let value = keyValue[1]

          switch key {
          case "platform":
            platform = value
          case "arch":
            arch = value
          case "id":
            id = value
          case "name":
            name = value
          case "OS":
            OS = value
          case "variant":
            variant = value
          default:
            break
          }
        }
      }

      let destination = Destination(
        platform: platform, arch: arch, id: id, name: name, OS: OS, variant: variant)
      destinations.append(destination)
    }

    return destinations
  }
  internal init?(line: String) {
    guard line.contains(Self.destinationPrefix) else { return nil }

    // Clean up the line and split by comma
    let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst().dropLast()
    let components = cleanLine.split(separator: ",")

    var platform: String? = nil
    var arch: String? = nil
    var id: String? = nil
    var name: String? = nil
    var variant: String? = nil
    var OS: String? = nil

    for component in components {
      let keyValue = component.split(separator: ":").map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      if keyValue.count == 2 {
        let key = keyValue[0]
        let value = keyValue[1]

        switch key {
        case "platform":
          platform = value
        case "arch":
          arch = value
        case "id":
          id = value
        case "name":
          name = value
        case "OS":
          OS = value
        case "variant":
          variant = value
        default:
          break
        }
      }
    }

    self.init(platform: platform, arch: arch, id: id, name: name, variant: variant)
  }

  let platform: String
  let arch: String?
  let id: String?
  let name: String
  let variant: String?
  let OS: String?
}
