import Foundation

// MARK: - Argument Parsing

func parseFlag(_ flag: String) -> String? {
  let args = CommandLine.arguments.dropFirst()
  var iterator = args.makeIterator()
  while let arg = iterator.next() {
    if arg == flag {
      return iterator.next()
    }
  }
  return nil
}

// MARK: - Path Building

struct GeneratorPaths {
  let kitSource: URL
  let kitTests: URL
  let appSource: URL
  let serverSource: URL?
  let daemonSource: URL?
}

func buildPaths(kitDir: String, appDir: String, serverDir: String?, appName: String) -> GeneratorPaths {
  // Normalize all paths through URL API
  let kitBase = URL(fileURLWithPath: kitDir).standardizedFileURL
  let appBase = URL(fileURLWithPath: appDir).standardizedFileURL
  let serverBase = serverDir.map { URL(fileURLWithPath: $0).standardizedFileURL }

  let kitSource = kitBase.appendingPathComponent("\(appName)Kit")

  // Go up from Sources/, then into Tests/
  let kitTests = kitBase
    .deletingLastPathComponent()
    .appendingPathComponent("Tests")
    .appendingPathComponent("\(appName)KitTests")

  let appSource = appBase.appendingPathComponent("\(appName)App")
  let serverSource = serverBase?.appendingPathComponent("\(appName)Server")
  let daemonSource = serverBase?.appendingPathComponent("\(appName.lowercased())d")

  return GeneratorPaths(
    kitSource: kitSource,
    kitTests: kitTests,
    appSource: appSource,
    serverSource: serverSource,
    daemonSource: daemonSource
  )
}

// MARK: - File Writing

func writeFile(at url: URL, content: String) throws {
  do {
    try FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
  } catch {
    throw GeneratorError.directoryCreationFailed(
      path: url.deletingLastPathComponent().path,
      underlyingError: error
    )
  }

  do {
    try content.write(to: url, atomically: true, encoding: .utf8)
    print("Generated: \(url.path)")
  } catch {
    throw GeneratorError.fileWriteFailed(path: url.path, underlyingError: error)
  }
}

// MARK: - Main Execution

do {
  // Parse arguments
  guard let appName = parseFlag("--app-name") else {
    fputs("Error: --app-name is required\n", stderr)
    exit(1)
  }

  guard let kitDir = parseFlag("--kit-dir") else {
    fputs("Error: --kit-dir is required\n", stderr)
    exit(1)
  }

  guard let appDir = parseFlag("--app-dir") else {
    fputs("Error: --app-dir is required\n", stderr)
    exit(1)
  }

  let serverDir = parseFlag("--server-dir")

  // Validate app name
  try validateAppName(appName)

  // Build paths
  let paths = buildPaths(
    kitDir: kitDir,
    appDir: appDir,
    serverDir: serverDir,
    appName: appName
  )

  // Generate Kit Files
  try writeFile(
    at: paths.kitSource.appendingPathComponent("AppModel.swift"),
    content: AppModelGenerator.generate(appName: appName)
  )

  try writeFile(
    at: paths.kitTests.appendingPathComponent("AppModelTests.swift"),
    content: AppModelTestsGenerator.generate(appName: appName)
  )

  // Generate App Files
  try writeFile(
    at: paths.appSource.appendingPathComponent("\(appName)App.swift"),
    content: AppEntryGenerator.generate(appName: appName)
  )

  try writeFile(
    at: paths.appSource.appendingPathComponent("Views").appendingPathComponent("ContentView.swift"),
    content: ContentViewGenerator.generate(appName: appName)
  )

  try writeFile(
    at: paths.appSource.appendingPathComponent("Views").appendingPathComponent("PrimaryView.swift"),
    content: PrimaryViewGenerator.generate(appName: appName)
  )

  // Generate Server Files (optional)
  if let serverSource = paths.serverSource, let daemonSource = paths.daemonSource {
    try writeFile(
      at: serverSource.appendingPathComponent("\(appName)Server.swift"),
      content: ServerCommandGenerator.generate(appName: appName)
    )

    try writeFile(
      at: daemonSource.appendingPathComponent("main.swift"),
      content: ServerEntryGenerator.generate(appName: appName)
    )
  }
} catch let error as GeneratorError {
  fputs("\n❌ Generation failed:\n\(error.localizedDescription)\n\n", stderr)
  exit(1)
} catch {
  fputs("\n❌ Unexpected error: \(error.localizedDescription)\n", stderr)
  exit(1)
}
