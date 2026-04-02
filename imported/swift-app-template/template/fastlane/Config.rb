# Config.rb
# Centralized configuration for Fastlane
# This file is loaded by Fastfile and contains app-specific constants

module FastlaneConfig
  # App Configuration
  APP_NAME = ENV.fetch("APP_NAME", "{{TEMPLATE_APP_NAME}}")
  APP_IDENTIFIER = ENV.fetch("APP_IDENTIFIER", "{{TEMPLATE_BUNDLE_ID}}")
  APPLE_ID = ENV.fetch("APPLE_ID", "{{TEMPLATE_APPLE_ID}}")
  TEAM_ID = ENV.fetch("TEAM_ID", "{{TEMPLATE_TEAM_ID}}")
  ITC_TEAM_ID = ENV.fetch("ITC_TEAM_ID", "{{TEMPLATE_ITC_TEAM_ID}}")

  # App Store Connect numeric app ID (assigned after app registration — set in .env)
  APP_STORE_APP_ID = ENV.fetch("APP_STORE_APP_ID", nil)

  # TestFlight Beta Metadata
  BETA_CHANGELOG = ENV.fetch("BETA_CHANGELOG", "New features and bug fixes.")
  BETA_APP_DESCRIPTION = ENV.fetch("BETA_APP_DESCRIPTION", APP_NAME)
  BETA_FEEDBACK_EMAIL = ENV.fetch("BETA_FEEDBACK_EMAIL", APPLE_ID)

  # App Groups for shared user settings
  APP_GROUPS = ["{{TEMPLATE_APP_GROUP_ID}}"]

  # Platform configuration — set by setup.sh for your target platform
  # PLATFORM: fastlane platform identifier — "mac", "ios", "tvos", "watchos"
  PLATFORM = ENV.fetch("PLATFORM", "{{TEMPLATE_FASTLANE_PLATFORM}}")
  # PRODUCE_PLATFORM: platform string used by the `produce` action — "osx", "ios", "tvos", "watchos"
  PRODUCE_PLATFORM = ENV.fetch("PRODUCE_PLATFORM", "{{TEMPLATE_PRODUCE_PLATFORM}}")
  # TEST_DESTINATION: xcodebuild destination string
  #   macOS: "platform=macOS"
  #   iOS simulator: "platform=iOS Simulator,name=iPhone 16"
  TEST_DESTINATION = ENV.fetch("TEST_DESTINATION", "{{TEMPLATE_TEST_DESTINATION}}")
  # BUILD_ARTIFACT_EXT: release artifact file extension — "pkg" (macOS) or "ipa" (iOS/tvOS/watchOS)
  BUILD_ARTIFACT_EXT = ENV.fetch("BUILD_ARTIFACT_EXT", "{{TEMPLATE_BUILD_ARTIFACT_EXT}}")

  # Can be overridden via environment variables
  # Examples:
  #   export APP_NAME="MyApp"
  #   export APPLE_ID="your-email@example.com"
end
