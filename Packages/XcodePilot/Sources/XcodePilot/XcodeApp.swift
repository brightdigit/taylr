//
//  XcodeApp.swift
//  XcodePilot
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(ScriptingBridge)
  public import Foundation
  import ScriptingBridge
  @preconcurrency import XcodeScriptingBridge

  /// A running copy of Xcode, driven through its scripting dictionary.
  public struct XcodeApp: Sendable {
    internal let xcode: XcodeApplication

    /// Connects to the Xcode at a file path.
    ///
    /// - Parameter filePath: The path of the app, such as `/Applications/Xcode.app`.
    public init?(filePath: String) {
      self.init(applicationURL: .init(filePath: filePath))
    }

    /// Connects to the Xcode at a URL.
    ///
    /// - Parameter applicationURL: The file URL of the app bundle.
    public init?(applicationURL: URL) {
      guard let application = SBApplication(url: applicationURL) else {
        return nil
      }
      self.xcode = application as XcodeApplication
    }

    /// Opens a workspace or project in Xcode.
    ///
    /// - Parameter url: The file URL of the `.xcworkspace` or `.xcodeproj`.
    /// - Returns: The opened workspace document.
    /// - Throws: An error when Xcode does not report the document as opened.
    public func openWorkspaceDocument(at url: URL) async throws -> XcodePilot.XcodeWorkspaceDocument
    {
      _ = xcode.open?(url.standardizedFileURL)
      guard
        let document = xcode.documents?.object(withName: url.lastPathComponent)
          as? XcodeScriptingBridge.XcodeWorkspaceDocument
      else {
        throw PilotError.invalidWorkspaceDocument
      }
      return .init(app: self, document: document)
    }
  }
#endif
