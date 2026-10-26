public struct RunDestination: Sendable {
  public init(arch: String? = nil, platform: String, name: String? = nil, OS: String? = nil) {
    self.arch = arch
    self.platform = platform
    self.name = name
    self.OS = OS
  }
  

  let arch: String?
  let platform: String
  let name : String?
  let OS : String?
}
