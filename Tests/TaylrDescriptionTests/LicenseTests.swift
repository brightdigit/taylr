import Foundation
import Testing

@testable import TaylrDescription

@Suite("License")
internal enum LicenseTests {
  internal struct Row: Sendable, CustomTestStringConvertible {
    internal let license: License
    internal let spdx: String
    internal let fileName: String
    internal let copyrightLine: Bool
    internal let perFileNotice: Bool

    internal var testDescription: String { license.rawValue }

    internal init(
      _ license: License,
      _ spdx: String,
      _ fileName: String,
      _ copyrightLine: Bool,
      _ perFileNotice: Bool
    ) {
      self.license = license
      self.spdx = spdx
      self.fileName = fileName
      self.copyrightLine = copyrightLine
      self.perFileNotice = perFileNotice
    }
  }

  @Suite("Reference table")
  internal struct TableTests {
    private static let rows: [Row] = [
      Row(.proprietary, "LicenseRef-Proprietary", "LICENSE", true, false),
      Row(.mit, "MIT", "LICENSE", true, false),
      Row(.apache2, "Apache-2.0", "LICENSE", true, true),
      Row(.bsd2, "BSD-2-Clause", "LICENSE", true, false),
      Row(.bsd3, "BSD-3-Clause", "LICENSE", true, false),
      Row(.boost, "BSL-1.0", "LICENSE", true, false),
      Row(.mpl2, "MPL-2.0", "LICENSE", true, true),
      Row(.epl2, "EPL-2.0", "LICENSE", true, true),
      Row(.gpl2, "GPL-2.0", "LICENSE", true, true),
      Row(.gpl3, "GPL-3.0", "COPYING", true, true),
      Row(.lgpl21, "LGPL-2.1", "LICENSE", true, true),
      Row(.agpl3, "AGPL-3.0", "LICENSE", true, true),
      Row(.cc0, "CC0-1.0", "LICENSE", false, false),
      Row(.unlicense, "Unlicense", "UNLICENSE", false, false),
    ]

    @Test("Each license matches its row of the reference table", arguments: Self.rows)
    internal func matchesRow(row: Row) {
      #expect(row.license.spdxIdentifier == row.spdx)
      #expect(row.license.fileName == row.fileName)
      #expect(row.license.includesCopyrightLine == row.copyrightLine)
      #expect(row.license.requiresPerFileNotice == row.perFileNotice)
    }

    @Test("Every license has its own SPDX identifier", arguments: License.allCases)
    internal func hasSPDXIdentifier(license: License) {
      #expect(license.spdxIdentifier != license.rawValue)
    }

    @Test("The table covers every case once")
    internal func tableCoversAllCases() {
      #expect(Self.rows.map(\.license) == License.allCases)
    }
  }

  @Suite("Cases and Codable")
  internal struct CodableTests {
    @Test("There are 14 licenses")
    internal func hasFourteenCases() {
      #expect(License.allCases.count == 14)
    }

    @Test("A license encodes as its case name")
    internal func encodesAsString() throws {
      let data = try JSONEncoder().encode([License.apache2])
      #expect(String(decoding: data, as: UTF8.self) == "[\"apache2\"]")
    }

    @Test("Every license survives a Codable round trip", arguments: License.allCases)
    internal func roundTrips(license: License) throws {
      let data = try JSONEncoder().encode([license])
      #expect(try JSONDecoder().decode([License].self, from: data) == [license])
    }
  }
}
