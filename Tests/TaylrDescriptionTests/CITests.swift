import Foundation
import Testing

@testable import TaylrDescription

@Suite("CI")
internal enum CITests {
  @Suite("Workflow.fileNames")
  internal struct WorkflowFileNamesTests {
    private struct Row {
      let workflow: CI.Workflow
      let names: [String]
    }

    private static let cleanupNames = ["cleanup-caches.yml", "cleanup-pr-caches.yml"]
    private static let claudeNames = ["claude.yml", "claude-code-review.yml"]

    private static let rows: [Row] = [
      Row(workflow: .ci, names: ["integration.yml"]),
      Row(workflow: .appStoreMetadata, names: ["app-store-metadata.yml"]),
      Row(workflow: .appStoreSession, names: ["asc-session.yml"]),
      Row(workflow: .cleanup, names: Self.cleanupNames),
      Row(workflow: .claude, names: Self.claudeNames),
    ]

    @Test("Each Workflow-table row names its files")
    internal func tableRows() {
      for row in Self.rows {
        #expect(row.workflow.fileNames == row.names)
      }
    }

    @Test("The table covers every workflow")
    internal func coversEveryWorkflow() {
      #expect(Self.rows.map(\.workflow) == CI.Workflow.allCases)
    }

    @Test("No two workflows share a file name")
    internal func fileNamesAreDistinct() {
      let names = CI.Workflow.allCases.flatMap(\.fileNames)
      #expect(Set(names).count == names.count)
    }
  }

  @Suite("Runners")
  internal struct RunnersTests {
    private static let custom = CI.Runners.selfHosted(
      labels: ["self-hosted", "acme"],
      xcodes: ["/Applications/Xcode-26.app"]
    )

    @Test("selfHosted() defaults its labels and xcodes")
    internal func selfHostedDefaults() {
      #expect(
        CI.Runners.selfHosted()
          == .selfHosted(labels: ["self-hosted", "macOS"], xcodes: ["/Applications/Xcode.app"])
      )
    }

    @Test("Round-trips selfHosted and githubHosted")
    internal func roundTrips() throws {
      for value in [CI.Runners.selfHosted(), Self.custom, .githubHosted] {
        #expect(try roundTrip(value) == value)
      }
    }
  }

  @Suite("Workflow")
  internal struct WorkflowTests {
    @Test("Every Workflow round-trips as its case name")
    internal func roundTrips() throws {
      for workflow in CI.Workflow.allCases {
        #expect(try roundTrip(workflow) == workflow)
        let json = try String(decoding: JSONEncoder().encode(workflow), as: UTF8.self)
        #expect(json == "\"\(workflow.rawValue)\"")
      }
    }
  }

  @Suite("githubActions")
  internal struct GitHubActionsTests {
    @Test("Defaults to self-hosted runners and every workflow")
    internal func defaults() {
      #expect(
        CI.githubActions()
          == .githubActions(
            runners: .selfHosted(),
            workflows: CI.Workflow.allCases,
            matrix: CI.Matrix()
          )
      )
    }

    @Test("The matrix reference example compiles and round-trips")
    internal func matrixReferenceExample() throws {
      let config: CI = .githubActions(
        runners: .selfHosted(xcodes: ["/Applications/Xcode.app", "/Applications/Xcode-26.4.app"]),
        matrix: .init(
          feature: .init(include: [.linux(.jammy)]),
          main: .init(
            include: [.xcode(path: "/Applications/Xcode-26.4.app")],
            exclude: [.android(api: 34)]
          )
        )
      )
      #expect(try roundTrip(config) == config)
      #expect(config != .githubActions())
    }

    @Test("The reference example compiles and round-trips")
    internal func referenceExample() throws {
      let config: CI = .githubActions(
        runners: .githubHosted,
        workflows: [.ci, .appStoreMetadata, .appStoreSession]
      )
      #expect(try roundTrip(config) == config)
      #expect(CI.githubActions(runners: .githubHosted) != config)
    }
  }

  @Suite("Matrix")
  internal struct MatrixTests {
    private static let entries: [CI.MatrixEntry] = [
      .swift("6.1"), .linux(.noble), .linux(.jammy), .wasm, .wasmEmbedded,
      .windows(.v2022), .windows(.v2025), .android(api: 34), .android(api: 35),
      .xcode("26.4"), .xcode(path: "/Applications/Xcode-26.4.app"),
    ]

    @Test("Matrix and Entries default to empty")
    internal func defaults() {
      let matrix = CI.Matrix()
      #expect(matrix.feature == CI.Matrix.Entries(include: [], exclude: []))
      #expect(matrix.version == CI.Matrix.Entries())
      #expect(matrix.main == CI.Matrix.Entries())
      #expect(CI.Matrix.Entries().include.isEmpty)
      #expect(CI.Matrix.Entries().exclude.isEmpty)
    }

    @Test("Each entry round-trips", arguments: entries)
    internal func entryRoundTrips(entry: CI.MatrixEntry) throws {
      #expect(try roundTrip(entry) == entry)
    }

    @Test("The two xcode spellings and the android levels stay distinct")
    internal func distinctEntries() throws {
      #expect(CI.MatrixEntry.xcode("26.4") != .xcode(path: "26.4"))
      #expect(CI.MatrixEntry.android(api: 34) != .android(api: 35))
      let decoded = try roundTrip(CI.MatrixEntry.xcode(path: "26.4"))
      #expect(decoded == .xcode(path: "26.4"))
    }

    @Test("A full matrix round-trips")
    internal func matrixRoundTrips() throws {
      let matrix = CI.Matrix(
        feature: .init(include: [.wasm], exclude: [.windows(.v2025)]),
        version: .init(exclude: [.swift("6.0")]),
        main: .init(include: Self.entries)
      )
      #expect(try roundTrip(matrix) == matrix)
    }
  }
}

private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
  try JSONDecoder().decode(T.self, from: JSONEncoder().encode(value))
}
