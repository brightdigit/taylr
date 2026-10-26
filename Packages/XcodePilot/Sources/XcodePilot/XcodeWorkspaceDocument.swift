//
//  XcodeWorkspaceDocument.swift
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
  import Foundation
  import ScriptingBridge
  internal import Subprocess
  @preconcurrency import XcodeScriptingBridge

  /// A workspace or project open in Xcode.
  public struct XcodeWorkspaceDocument: Sendable {
    /// How long `debug` waits for Xcode to load the scheme, in seconds.
    private static let schemeTimeout: TimeInterval = 30

    /// The most `xcodebuild -showdestinations` output read, in bytes.
    private static let showDestinationsOutputLimit = 1_048_576

    internal let app: XcodeApp
    internal let document: XcodeScriptingBridge.XcodeWorkspaceDocument

    internal init(app: XcodeApp, document: any XcodeScriptingBridge.XcodeWorkspaceDocument) {
      self.app = app
      self.document = document
    }

    /// Lists the destinations `xcodebuild` reports for a scheme.
    private static func showDestinations(
      projectFileURL: URL,
      scheme: String
    ) async throws -> [Destination] {
      let result = try await run(
        .path("/usr/bin/xcodebuild"),
        arguments: ["-project", projectFileURL.path(), "-scheme", scheme, "-showdestinations"],
        output: .string(limit: showDestinationsOutputLimit),
        error: .discarded
      )
      guard result.terminationStatus.isSuccess, let output = result.standardOutput else {
        throw PilotError.showDestinationsFailed(String(describing: result.terminationStatus))
      }
      return Destination.parseFrom(output: output)
    }

    /// Builds and debugs a scheme on a run destination.
    ///
    /// - Parameters:
    ///   - scheme: The name of the scheme.
    ///   - destination: The destination to run on.
    ///   - skipBuilding: Whether to debug the last build without building again.
    ///   - commandLineArguments: Arguments passed to the launched app.
    ///   - environmentVariables: Environment variables set for the launched app.
    /// - Throws: An error when the project, scheme or destination cannot be found.
    public func debug(
      scheme: String,
      runDestination destination: RunDestination,
      skipBuilding: Bool = false,
      commandLineArguments: [String] = [],
      environmentVariables: [String: String] = [:]
    ) async throws {
      async let runDestination = resolve(destination, scheme: scheme)
      try await waitForScheme(named: scheme)

      _ = try await self.document.debugScheme?(
        scheme,
        runDestinationSpecifier: runDestination.description,
        skipBuilding: skipBuilding,
        commandLineArguments: commandLineArguments,
        environmentVariables: environmentVariables
      )
    }

    private func resolve(_ destination: RunDestination, scheme: String) async throws -> Destination
    {
      guard let projectFileURL = document.file?.findParent(withPathExtension: "xcodeproj") else {
        throw PilotError.missingProjectFile
      }

      let destinations = try await Self.showDestinations(
        projectFileURL: projectFileURL,
        scheme: scheme
      )

      guard let match = destination.firstMatch(in: destinations) else {
        throw PilotError.destinationNotFound(destination)
      }

      return match
    }

    private func waitForScheme(named scheme: String) async throws {
      let start = Date()
      while Date().timeIntervalSince(start) < Self.schemeTimeout {
        if self.document.schemes?.object(withName: scheme) is SBObject {
          return
        }
        try await Task.sleep(for: .seconds(1))
      }
      throw PilotError.cannotFindScheme(scheme)
    }
  }
#endif
