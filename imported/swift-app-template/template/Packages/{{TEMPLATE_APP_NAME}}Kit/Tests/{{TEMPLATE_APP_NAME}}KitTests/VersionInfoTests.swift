//
//  VersionInfoTests.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import Testing

@testable import {{TEMPLATE_APP_NAME}}Kit

@Suite("Version Info")
internal struct VersionInfoTests {
  // MARK: - Functional Tests

  @Test("base 0 / build 6 renders 1.0.0 beta 6")
  internal func betaBaseZeroBuildSix() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "6", betaBase: "0")
        == "1.0.0 beta 6"
    )
  }

  @Test("non-zero base subtracts from the build number")
  internal func betaBaseSubtracts() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "10", betaBase: "4")
        == "1.0.0 beta 6"
    )
  }

  @Test("base 2 / build 12 renders 1.0.0 beta 10")
  internal func betaTenDisplay() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "12", betaBase: "2")
        == "1.0.0 beta 10"
    )
  }

  @Test("nil base renders the plain release version")
  internal func nilBaseIsRelease() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "6", betaBase: nil)
        == "1.0.0"
    )
  }

  @Test("empty base renders the plain release version")
  internal func emptyBaseIsRelease() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "6", betaBase: "")
        == "1.0.0"
    )
  }

  @Test("whitespace-only base renders the plain release version")
  internal func whitespaceBaseIsRelease() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "6", betaBase: "   ")
        == "1.0.0"
    )
  }

  @Test("surrounding whitespace in raw values is tolerated")
  internal func trimsWhitespace() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: " 6 ", betaBase: " 0 ")
        == "1.0.0 beta 6"
    )
  }

  @Test("non-numeric base falls back to the release version")
  internal func nonNumericBaseIsRelease() {
    #expect(
      VersionInfo.displayVersion(marketing: "1.0.0", build: "6", betaBase: "NO")
        == "1.0.0"
    )
  }
}
