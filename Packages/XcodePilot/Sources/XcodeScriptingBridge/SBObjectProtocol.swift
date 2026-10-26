//
//  SBObjectProtocol.swift
//  Swoop
//
//  Created by Leo Dion on 7/16/24.
//

package import ScriptingBridge

@objc package protocol SBObjectProtocol: NSObjectProtocol {
  func get() -> Any!
}

@objc package protocol SBApplicationProtocol: SBObjectProtocol {
  func activate()
  var delegate: (any SBApplicationDelegate)! { get set }
  //var running: Bool { @objc(isRunning) get }
}

// Define the protocols with @objc and optional methods/properties
@objc package protocol XcodeGenericMethods: AnyObject, SBObjectProtocol {
  @objc optional func closeSaving(_ saving: XcodeSaveOptions, savingIn: URL?)
  @objc optional func delete()
  @objc optional func moveTo(_ to: SBObject)
  @objc optional func build() -> any XcodeSchemeActionResult
  @objc optional func clean() -> any XcodeSchemeActionResult
  @objc optional func stop()
  @objc optional func run(withCommandLineArguments: Any, withEnvironmentVariables: Any)
    -> any XcodeSchemeActionResult
  @objc optional func test(withCommandLineArguments: Any, withEnvironmentVariables: Any)
    -> any XcodeSchemeActionResult
  @objc optional func attachToProcessIdentifier(_ toProcessIdentifier: Int, suspended: Bool)
  @objc optional func debugScheme(
    _ scheme: String, runDestinationSpecifier: String, skipBuilding: Bool,
    commandLineArguments: Any, environmentVariables: Any
  ) -> any XcodeSchemeActionResult
}

@objc package protocol XcodeApplication: SBApplicationProtocol, XcodeGenericMethods {
  @objc optional var documents: SBElementArray { get }
  @objc optional var windows: SBElementArray { get }
  @objc optional var name: String { get }
  @objc optional var frontmost: Bool { get }
  @objc optional var version: String { get }

  @objc optional func open(_ x: Any) -> Any
  @objc optional func quitSaving(_ saving: XcodeSaveOptions)
  @objc optional func exists(_ x: Any) -> Bool
  @objc optional func createTemporaryDebuggingWorkspace() -> any XcodeWorkspaceDocument
}

@objc package protocol XcodeDocument: XcodeGenericMethods, SBObjectProtocol {
  @objc optional var name: String { get }
  @objc optional var modified: Bool { get }
  @objc optional var file: URL { get }
}

@objc package protocol XcodeWindow: XcodeGenericMethods {
  @objc optional var name: String { get }
  @objc optional var id: Int { get }
  @objc optional var index: Int { get set }
  @objc optional var bounds: NSRect { get set }
  @objc optional var closeable: Bool { get }
  @objc optional var miniaturizable: Bool { get }
  @objc optional var miniaturized: Bool { get set }
  @objc optional var resizable: Bool { get }
  @objc optional var visible: Bool { get set }
  @objc optional var zoomable: Bool { get }
  @objc optional var zoomed: Bool { get set }
  @objc optional var document: any XcodeDocument { get }
}

@objc package protocol XcodeApplicationSuite: XcodeApplication {
  @objc optional var fileDocuments: SBElementArray { get }
  @objc optional var sourceDocuments: SBElementArray { get }
  @objc optional var workspaceDocuments: SBElementArray { get }
  @objc optional var activeWorkspaceDocument: any XcodeWorkspaceDocument { get set }
}

@objc package protocol XcodeDocumentSuite: XcodeDocument {
  @objc optional var path: String { get set }
}

@objc package protocol XcodeFileDocument: XcodeDocumentSuite {}

@objc package protocol XcodeTextDocument: XcodeFileDocument {
  @objc optional var selectedCharacterRange: [NSNumber] { get set }
  @objc optional var selectedParagraphRange: [NSNumber] { get set }
  @objc optional var text: String { get set }
  @objc optional var notifiesWhenClosing: Bool { get set }
}

@objc package protocol XcodeSourceDocument: XcodeTextDocument {}

@objc package protocol XcodeWorkspaceDocument: XcodeDocument, SBObjectProtocol {
  @objc optional var projects: SBElementArray { get }
  @objc optional var schemes: SBElementArray { get }
  @objc optional var runDestinations: SBElementArray { get }
  @objc optional var loaded: Bool { get set }
  @objc optional var activeScheme: any XcodeScheme { get set }
  @objc optional var activeRunDestination: any XcodeRunDestination { get set }
  @objc optional var lastSchemeActionResult: any XcodeSchemeActionResult { get set }
  @objc optional var file: URL { get }
}

@objc package protocol XcodeSchemeActionResult: XcodeGenericMethods {
  @objc optional var buildErrors: SBElementArray { get }
  @objc optional var buildWarnings: SBElementArray { get }
  @objc optional var analyzerIssues: SBElementArray { get }
  @objc optional var testFailures: SBElementArray { get }
  @objc optional var id: String { get }
  @objc optional var completed: Bool { get }
  @objc optional var status: XcodeSchemeActionResultStatus { get set }
  @objc optional var errorMessage: String { get set }
  @objc optional var buildLog: String { get set }
}

@objc package protocol XcodeSchemeActionIssue: XcodeGenericMethods {
  @objc optional var message: String { get set }
  @objc optional var filePath: String { get set }
  @objc optional var startingLineNumber: Int { get set }
  @objc optional var endingLineNumber: Int { get set }
  @objc optional var startingColumnNumber: Int { get set }
  @objc optional var endingColumnNumber: Int { get set }
}

@objc package protocol XcodeBuildError: XcodeSchemeActionIssue {}

@objc package protocol XcodeBuildWarning: XcodeSchemeActionIssue {}

@objc package protocol XcodeAnalyzerIssue: XcodeSchemeActionIssue {}

@objc package protocol XcodeTestFailure: XcodeSchemeActionIssue {}

@objc package protocol XcodeScheme: XcodeGenericMethods {
  @objc optional var name: String { get }
  @objc optional var id: String { get }
}

@objc package protocol XcodeRunDestination: XcodeGenericMethods {
  @objc optional var name: String { get }
  @objc optional var architecture: String { get }
  @objc optional var platform: String { get }
  @objc optional var device: any XcodeDevice { get }
  @objc optional var companionDevice: any XcodeDevice { get }
}

@objc package protocol XcodeDevice: XcodeGenericMethods {
  @objc optional var name: String { get }
  @objc optional var deviceIdentifier: String { get }
  @objc optional var operatingSystemVersion: String { get }
  @objc optional var deviceModel: String { get }
  @objc optional var generic: Bool { get }
}

@objc package protocol XcodeBuildConfiguration: XcodeGenericMethods {
  @objc optional var buildSettings: SBElementArray { get }
  @objc optional var resolvedBuildSettings: SBElementArray { get }
  @objc optional var id: String { get }
  @objc optional var name: String { get }
}

@objc package protocol XcodeProject: XcodeGenericMethods {
  @objc optional var buildConfigurations: SBElementArray { get }
  @objc optional var targets: SBElementArray { get }
  @objc optional var name: String { get }
  @objc optional var id: String { get }
}

@objc package protocol XcodeBuildSetting: XcodeGenericMethods {
  @objc optional var name: String { get set }
  @objc optional var value: String { get set }
}

@objc package protocol XcodeResolvedBuildSetting: XcodeGenericMethods {
  @objc optional var name: String { get set }
  @objc optional var value: String { get set }
}

@objc package protocol XcodeTarget: XcodeGenericMethods {
  @objc optional var buildConfigurations: SBElementArray { get }
  @objc optional var name: String { get set }
  @objc optional var id: String { get }
  @objc optional var project: any XcodeProject { get }
}

@objc package enum XcodeSaveOptions: Int {
  case yes  // = 'yes ' // Save the file.
  case no  // = 'no  ' // Do not save the file.
  case ask  // = 'ask ' // Ask the user whether or not to save the file.
}

@objc package enum XcodeSchemeActionResultStatus: Int {
  case notYetStarted  // = 'srsn' // The action has not yet started.
  case running  // = 'srsr' // The action is in progress.
  case cancelled  // = 'srsc' // The action was cancelled.
  case failed  // = 'srsf' // The action ran but did not complete successfully.
  case errorOccurred  // = 'srse' // The action was not able to run due to an error.
  case succeeded  // = 'srss' // The action succeeded.
}

// Extend SBObject and SBApplication to conform to the protocols

extension SBObject: XcodeGenericMethods {}

extension SBApplication: XcodeApplication {}

// Similarly, you can extend SBObject for other protocols

// Example for XcodeDocument
extension SBObject: XcodeDocument {}

extension SBObject: XcodeWorkspaceDocument {}

extension SBObject: XcodeRunDestination {}
// Continue this pattern for the rest of the protocols
extension SBObject: XcodeScheme {}

extension SBObject: XcodeSchemeActionResult {}
