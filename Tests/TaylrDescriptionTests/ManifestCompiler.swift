import Foundation

/// Compiles a `Manifest.swift` against the TaylrDescription module and runs it, the way taylr's
/// loader does.
///
/// The module is built once per test run (from `Sources/TaylrDescription/*.swift`), so each
/// example only compiles its own `Manifest.swift` and a driver.
internal enum ManifestCompiler {
  /// A failure to build or run something.
  internal struct Failure: Error, CustomStringConvertible {
    internal let description: String
  }

  /// The output of a finished process.
  private struct Output: Sendable {
    let status: Int32
    let stdout: Data
    let stderr: String
  }

  /// Builds the module once and hands the directory out to every caller.
  private actor Build {
    static let shared = Build()

    private var task: Task<URL, any Error>?

    func directory() async throws -> URL {
      if let task {
        return try await task.value
      }
      let task = Task { try await ManifestCompiler.buildModule() }
      self.task = task
      return try await task.value
    }
  }

  private static let languageFlags = ["-swift-version", "6"]

  /// Compiles `source` and `driver` against the module, runs the binary and returns its stdout.
  /// - Parameters:
  ///   - name: What the manifest is, for error messages.
  ///   - source: The contents of `Manifest.swift`.
  ///   - driver: The contents of `main.swift`.
  /// - Returns: What the binary printed to standard output.
  /// - Throws: ``Failure`` if compiling or running fails.
  internal static func run(name: String, source: String, driver: String) async throws -> Data {
    let module = try await Build.shared.directory()
    let work = module.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
    let manifestFile = work.appendingPathComponent("Manifest.swift")
    let mainFile = work.appendingPathComponent("main.swift")
    try source.write(to: manifestFile, atomically: true, encoding: .utf8)
    try driver.write(to: mainFile, atomically: true, encoding: .utf8)
    let binary = work.appendingPathComponent("manifest")
    let arguments =
      [
        mainFile.path, manifestFile.path,
        "-module-name", "ManifestRunner", "-I", module.path, "-L", module.path,
        "-lTaylrDescription", "-o", binary.path,
      ] + languageFlags
    try await swiftc(arguments, what: "compiling the \(name) manifest")
    let result = try await launch(binary.path, [])
    guard result.status == 0 else {
      throw Failure(description: "The \(name) manifest failed: \(result.stderr)")
    }
    return result.stdout
  }

  /// The module's sources, found from this file's location.
  private static func sources() throws -> [String] {
    let root = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let folder = root.appendingPathComponent("Sources/TaylrDescription")
    return try FileManager.default.contentsOfDirectory(atPath: folder.path)
      .filter { $0.hasSuffix(".swift") }.sorted()
      .map { folder.appendingPathComponent($0).path }
  }

  private static func buildModule() async throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("taylr-manifest-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let module = directory.appendingPathComponent("TaylrDescription.swiftmodule").path
    let library = directory.appendingPathComponent("libTaylrDescription.a").path
    let arguments =
      [
        "-emit-library", "-static", "-emit-module", "-module-name", "TaylrDescription",
        "-enable-upcoming-feature", "InternalImportsByDefault",
        "-emit-module-path", module, "-o", library,
      ] + languageFlags + (try sources())
    try await swiftc(arguments, what: "building TaylrDescription")
    return directory
  }

  private static func swiftc(_ arguments: [String], what: String) async throws {
    #if os(macOS)
      let result = try await launch("/usr/bin/xcrun", ["swiftc"] + arguments)
    #else
      let result = try await launch("/usr/bin/env", ["swiftc"] + arguments)
    #endif
    guard result.status == 0 else {
      throw Failure(description: "swiftc failed \(what): \(result.stderr)")
    }
  }

  /// Runs a process off the cooperative pool and collects its output.
  private static func launch(_ executable: String, _ arguments: [String]) async throws -> Output {
    try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global().async {
        do {
          let errorFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("taylr-stderr-\(UUID().uuidString)")
          _ = FileManager.default.createFile(atPath: errorFile.path, contents: nil)
          defer { try? FileManager.default.removeItem(at: errorFile) }
          let errorHandle = try FileHandle(forWritingTo: errorFile)
          let process = Process()
          process.executableURL = URL(fileURLWithPath: executable)
          process.arguments = arguments
          let pipe = Pipe()
          process.standardOutput = pipe
          process.standardError = errorHandle
          try process.run()
          let stdout = pipe.fileHandleForReading.readDataToEndOfFile()
          process.waitUntilExit()
          try errorHandle.close()
          let stderr = String(decoding: try Data(contentsOf: errorFile), as: UTF8.self)
          let output = Output(status: process.terminationStatus, stdout: stdout, stderr: stderr)
          continuation.resume(returning: output)
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
