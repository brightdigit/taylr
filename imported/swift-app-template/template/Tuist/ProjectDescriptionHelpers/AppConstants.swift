//
//  AppConstants.swift
//  {{TEMPLATE_APP_NAME}}
//
//  Copyright (c) {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}.
//  All rights reserved.
//

import ProjectDescription

/// App identity shared by Project.swift and the other helpers.
public enum AppConstants {
  public static let name = "{{TEMPLATE_APP_NAME}}"
  public static let teamID = "{{TEMPLATE_TEAM_ID}}"
  public static let bundleID = "{{TEMPLATE_BUNDLE_ID}}"
  public static let appGroup = "{{TEMPLATE_APP_GROUP_ID}}"
  public static let copyright = "Copyright © {{TEMPLATE_YEAR}} {{TEMPLATE_ORG_NAME}}"
  /// App Store category (`LSApplicationCategoryType`); keep in sync with
  /// fastlane/metadata/primary_category.txt.
  public static let category = "public.app-category.utilities"
}
