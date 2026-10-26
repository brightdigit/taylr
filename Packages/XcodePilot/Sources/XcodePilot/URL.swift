//
//  XcodeApplication.swift
//  XcodePilot
//
//  Created by Leo Dion on 7/24/24.
//

public import Foundation
import ProcessExtensions
@preconcurrency import ScriptingBridge
@preconcurrency import XcodeScriptingBridge

extension URL {
  /// Finds the nearest parent URL that has the specified path extension.
  /// - Parameter pathExtension: The path extension to look for.
  /// - Returns: The nearest parent URL with the specified path extension, or `nil` if not found.
  func findParent(withPathExtension pathExtension: String) -> URL? {
    var currentURL = self.deletingLastPathComponent()

    while currentURL.path != "/" {
      if currentURL.pathExtension == pathExtension {
        // Remove the trailing slash if it exists
        var path = currentURL.path
        if path.hasSuffix("/") {
          path.removeLast()
        }
        return URL(fileURLWithPath: path)
      }
      currentURL.deleteLastPathComponent()
    }

    return nil
  }
}
