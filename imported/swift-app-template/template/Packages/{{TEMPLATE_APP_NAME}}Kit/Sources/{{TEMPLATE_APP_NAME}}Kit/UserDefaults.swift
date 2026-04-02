//
//  UserDefaults.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import Foundation

#if canImport(OSLog)
  import OSLog
#endif

extension UserDefaults {
  /// The app group identifier for shared preferences.
  private static let identifier = "{{TEMPLATE_APP_GROUP_ID}}"

  /// Shared UserDefaults instance using the app group.
  nonisolated(unsafe) public static let appGroup: UserDefaults = {
    guard let defaults = UserDefaults(suiteName: identifier) else {
      #if canImport(OSLog)
        let logger = Logger(
          subsystem: "{{TEMPLATE_BUNDLE_ID}}",
          category: "UserDefaults"
        )
        logger.warning(
          """
          Failed to create UserDefaults with suite name '\(identifier)', \
          falling back to standard defaults
          """
        )
      #endif
      return UserDefaults.standard
    }
    return defaults
  }()
}
