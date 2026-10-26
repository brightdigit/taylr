public import Foundation
import ScriptingBridge
@preconcurrency import XcodeScriptingBridge

public struct XcodeApp: Sendable {
  let xcode: XcodeApplication

  public init?(filePath: String) {
    self.init(applicationURL: .init(filePath: filePath))
  }

  public init?(applicationURL: URL) {
    guard let application = SBApplication(url: applicationURL) else {
      return nil
    }
    self.xcode = application as XcodeApplication
  }

  public func openWorkspaceDocument(at url: URL) async throws -> XcodePilot.XcodeWorkspaceDocument {
    _ = xcode.open?(url.standardizedFileURL)
    guard
      let document = xcode.documents?.object(withName: url.lastPathComponent)
        as? XcodeScriptingBridge.XcodeWorkspaceDocument
    else {
      throw PilotError.invalidWorkspaceDocument
    }
    return await .init(app: self, document: document)
  }
}
