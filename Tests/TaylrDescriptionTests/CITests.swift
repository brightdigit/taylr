import Foundation
import Testing

@testable import TaylrDescription

@Suite("CI")
internal enum CITests {
  @Suite("Workflow.fileNames")
  internal struct WorkflowFileNamesTests {
    private struct Row {
      let workflow: GitHubActions.Workflow
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
      #expect(Self.rows.map(\.workflow) == GitHubActions.Workflow.allCases)
    }

    @Test("Every workflow writes at least one file", arguments: GitHubActions.Workflow.allCases)
    internal func everyWorkflowHasFiles(workflow: GitHubActions.Workflow) {
      #expect(!workflow.fileNames.isEmpty)
    }

    @Test("No two workflows share a file name")
    internal func fileNamesAreDistinct() {
      let names = GitHubActions.Workflow.allCases.flatMap(\.fileNames)
      #expect(Set(names).count == names.count)
    }
  }

  @Suite("Runners")
  internal struct RunnersTests {
    private static let custom = GitHubActions.SelfHostedRunners(
      labels: ["self-hosted", "acme"],
      xcodes: ["/Applications/Xcode-26.app"]
    )

    @Test("selfHosted() defaults its labels and xcodes")
    internal func selfHostedDefaults() {
      #expect(
        GitHubActions.SelfHostedRunners.selfHosted().serialization
          == .selfHosted(labels: ["self-hosted", "macOS"], xcodes: ["/Applications/Xcode.app"])
      )
    }

    @Test("Round-trips selfHosted and githubHosted")
    internal func roundTrips() throws {
      let values: [GitHubActions.RunnersSerialization] = [
        GitHubActions.SelfHostedRunners.selfHosted().serialization,
        Self.custom.serialization,
        GitHubActions.GitHubHostedRunners.githubHosted.serialization,
      ]
      for value in values {
        #expect(try roundTrip(value) == value)
      }
    }

    @Test("Runners encode with labeled keys")
    internal func encodesLabeled() throws {
      let json = try encoded(Self.custom.serialization)
      #expect(json.contains(#""labels":"#))
      #expect(!json.contains("_0"))
    }
  }

  @Suite("Workflow")
  internal struct WorkflowTests {
    @Test("Every Workflow round-trips as its case name")
    internal func roundTrips() throws {
      for workflow in GitHubActions.Workflow.allCases {
        #expect(try roundTrip(workflow) == workflow)
        #expect(try encoded(workflow) == "\"\(workflow.rawValue)\"")
      }
    }
  }

  @Suite("githubActions")
  internal struct GitHubActionsTests {
    @Test("Defaults to self-hosted runners and every workflow")
    internal func defaults() {
      #expect(
        GitHubActions.githubActions()
          == .githubActions(
            runners: .selfHosted(),
            workflows: GitHubActions.Workflow.allCases,
            matrix: GitHubActions.Matrix()
          )
      )
    }

    @Test("The matrix reference example compiles and round-trips")
    internal func matrixReferenceExample() throws {
      let config: any CI = .githubActions(
        runners: .selfHosted(xcodes: ["/Applications/Xcode.app", "/Applications/Xcode-26.4.app"]),
        matrix: .init(
          feature: .init(include: [.linux(.jammy)]),
          main: .init(
            include: [.xcode(path: "/Applications/Xcode-26.4.app")],
            exclude: [.android(api: 34)]
          )
        )
      )
      #expect(try roundTrip(config.serialization) == config.serialization)
      #expect(config.serialization != GitHubActions.githubActions().serialization)
      #expect(!(try encoded(config.serialization)).contains("_0"))
    }

    @Test("The reference example compiles and round-trips")
    internal func referenceExample() throws {
      let config: any CI = .githubActions(
        runners: .githubHosted,
        workflows: [.ci, .appStoreMetadata, .appStoreSession]
      )
      #expect(try roundTrip(config.serialization) == config.serialization)
      #expect(
        GitHubActions.githubActions(runners: .githubHosted).serialization != config.serialization)
    }

    @Test("An optional CI parameter takes githubActions, nil, or a default")
    internal func optionalParameter() {
      func serialize(_ config: (any CI)? = .githubActions()) -> CISerialization? {
        config?.serialization
      }
      #expect(serialize() == GitHubActions().serialization)
      #expect(serialize(nil) == nil)
      #expect(serialize(.githubActions(runners: .githubHosted)) != serialize())
    }
  }

  @Suite("Matrix")
  internal struct MatrixTests {
    private static let entries: [any GitHubActions.MatrixEntry] = [
      .swift("6.1"), .linux(.noble), .linux(.jammy), .wasm, .wasmEmbedded,
      .windows(.v2022), .windows(.v2025), .android(api: 34), .android(api: 35),
      .xcode("26.4"), .xcode(path: "/Applications/Xcode-26.4.app"),
    ]

    @Test("Matrix and Entries default to empty")
    internal func defaults() {
      let matrix = GitHubActions.Matrix()
      #expect(matrix.feature == GitHubActions.Matrix.Entries(include: [], exclude: []))
      #expect(matrix.version == GitHubActions.Matrix.Entries())
      #expect(matrix.main == GitHubActions.Matrix.Entries())
      #expect(GitHubActions.Matrix.Entries().include.isEmpty)
      #expect(GitHubActions.Matrix.Entries().exclude.isEmpty)
    }

    @Test("Each entry round-trips with labeled keys")
    internal func entriesRoundTrip() throws {
      for entry in Self.entries {
        #expect(try roundTrip(entry.serialization) == entry.serialization)
        #expect(!(try encoded(entry.serialization)).contains("_0"))
      }
    }

    @Test("Every entry serializes differently")
    internal func entriesAreDistinct() {
      let serializations = Self.entries.map { $0.serialization }
      for (index, serialization) in serializations.enumerated() {
        #expect(!serializations[(index + 1)...].contains(serialization))
      }
    }

    @Test("The two xcode spellings and the android levels stay distinct")
    internal func distinctEntries() throws {
      let version = GitHubActions.XcodeVersionEntry(version: "26.4")
      let path = GitHubActions.XcodePathEntry(path: "26.4")
      #expect(!GitHubActions.XcodeVersionEntry.serializesEqually(version, path))
      let android34 = GitHubActions.AndroidEntry(api: 34)
      let android35 = GitHubActions.AndroidEntry(api: 35)
      #expect(!GitHubActions.AndroidEntry.serializesEqually(android34, android35))
      #expect(try roundTrip(path.serialization) == .xcodePath(path: "26.4"))
    }

    @Test("A full matrix round-trips")
    internal func matrixRoundTrips() throws {
      let matrix = GitHubActions.Matrix(
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

private func encoded(_ value: some Encodable) throws -> String {
  try String(decoding: JSONEncoder().encode(value), as: UTF8.self)
}
