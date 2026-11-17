import Foundation
import Testing

@testable import TemplateGenerator

@Suite("Path Handling")
internal struct PathHandlingTests {
  @Test("buildPaths handles paths without trailing slashes")
  internal func handlesPathsWithoutTrailingSlashes() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/tmp/test/Kit/Sources",
      appDir: "/tmp/test/App/Sources",
      serverDir: nil,
      appName: "TestApp"
    )

    #expect(paths.kitSource.path == "/tmp/test/Kit/Sources/TestAppKit")
    #expect(paths.kitTests.path == "/tmp/test/Kit/Tests/TestAppKitTests")
    #expect(paths.appSource.path == "/tmp/test/App/Sources/TestAppApp")
    #expect(paths.serverSource == nil)
    #expect(paths.daemonSource == nil)
  }

  @Test("buildPaths handles paths with trailing slashes")
  internal func handlesPathsWithTrailingSlashes() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/tmp/test/Kit/Sources/",
      appDir: "/tmp/test/App/Sources/",
      serverDir: nil,
      appName: "TestApp"
    )

    #expect(paths.kitSource.path == "/tmp/test/Kit/Sources/TestAppKit")
    #expect(paths.kitTests.path == "/tmp/test/Kit/Tests/TestAppKitTests")
    #expect(paths.appSource.path == "/tmp/test/App/Sources/TestAppApp")
  }

  @Test("buildPaths handles server directory")
  internal func handlesServerDirectory() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/tmp/test/Kit/Sources",
      appDir: "/tmp/test/App/Sources",
      serverDir: "/tmp/test/Server/Sources",
      appName: "TestApp"
    )

    #expect(paths.serverSource?.path == "/tmp/test/Server/Sources/TestAppServer")
    #expect(paths.daemonSource?.path == "/tmp/test/Server/Sources/testappd")
  }

  @Test("buildPaths lowercases daemon name")
  internal func lowercasesDaemonName() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/tmp/test/Kit/Sources",
      appDir: "/tmp/test/App/Sources",
      serverDir: "/tmp/test/Server/Sources",
      appName: "MyWeatherApp"
    )

    #expect(paths.daemonSource?.path == "/tmp/test/Server/Sources/myweatherappd")
  }

  @Test("buildPaths handles app names with underscores")
  internal func handlesAppNamesWithUnderscores() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/tmp/test/Kit/Sources",
      appDir: "/tmp/test/App/Sources",
      serverDir: nil,
      appName: "My_Weather_App"
    )

    #expect(paths.kitSource.path == "/tmp/test/Kit/Sources/My_Weather_AppKit")
    #expect(paths.kitTests.path == "/tmp/test/Kit/Tests/My_Weather_AppKitTests")
    #expect(paths.appSource.path == "/tmp/test/App/Sources/My_Weather_AppApp")
  }

  @Test("buildPaths correctly navigates from Sources to Tests")
  internal func correctlyNavigatesFromSourcesToTests() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/project/Packages/MyKit/Sources",
      appDir: "/project/Packages/MyApp/Sources",
      serverDir: nil,
      appName: "TestApp"
    )

    // Should go up from Sources/, then into Tests/
    #expect(paths.kitTests.path == "/project/Packages/MyKit/Tests/TestAppKitTests")
  }

  @Test("buildPaths handles relative paths")
  internal func handlesRelativePaths() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "Packages/Kit/Sources",
      appDir: "Packages/App/Sources",
      serverDir: nil,
      appName: "TestApp"
    )

    // URL(fileURLWithPath:) should resolve relative paths
    #expect(paths.kitSource.lastPathComponent == "TestAppKit")
    #expect(paths.appSource.lastPathComponent == "TestAppApp")
  }

  @Test("buildPaths normalizes redundant path components")
  internal func normalizesRedundantPathComponents() {
    let paths: GeneratorPaths = buildPaths(
      kitDir: "/tmp/test/../test/Kit/./Sources",
      appDir: "/tmp/test/App/Sources",
      serverDir: nil,
      appName: "TestApp"
    )

    // standardizedFileURL should normalize ./ and ../
    #expect(!paths.kitSource.path.contains(".."))
    #expect(!paths.kitSource.path.contains("."))
  }

  @Test("buildPaths handles symlinks correctly")
  internal func handlesSymlinksCorrectly() throws {
    let tempDir = FileManager.default.temporaryDirectory
    let realDir = tempDir.appendingPathComponent("real-\(UUID().uuidString)")
    let linkDir = tempDir.appendingPathComponent("link-\(UUID().uuidString)")

    try FileManager.default.createDirectory(at: realDir, withIntermediateDirectories: true)

    #if os(Windows)
    // Skip symlink test on Windows
    #else
    try FileManager.default.createSymbolicLink(at: linkDir, withDestinationURL: realDir)

    let paths = buildPaths(
      kitDir: linkDir.path,
      appDir: linkDir.path,
      serverDir: nil,
      appName: "TestApp"
    )

    // Paths should be valid and usable
    #expect(paths.kitSource.lastPathComponent == "TestAppKit")
    #expect(paths.appSource.lastPathComponent == "TestAppApp")

    // Clean up
    try? FileManager.default.removeItem(at: realDir)
    try? FileManager.default.removeItem(at: linkDir)
    #endif
  }
}
