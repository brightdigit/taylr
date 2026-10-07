//
//  {{TEMPLATE_APP_NAME}}UITests.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import XCTest

// UI tests use XCTest — XCUITest has no Swift Testing equivalent. Unit tests in
// the Kit package stay on Swift Testing.

/// Drives the app through the screens captured by `make capture-ios`.
///
/// Each `snapshot("NN_Name")` call writes one App Store screenshot; add a
/// matching `{ "filter": "NN_Name" }` entry to fastlane/screenshots/Framefile.json
/// and a title to fastlane/screenshots/<locale>/title.strings.
@MainActor
internal final class {{TEMPLATE_APP_NAME}}UITests: XCTestCase {
  override internal func setUp() async throws {
    continueAfterFailure = false
  }

  internal func testScreenshots() {
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()

    snapshot("01_Home")
  }
}
