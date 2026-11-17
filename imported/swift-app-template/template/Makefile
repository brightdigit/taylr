# Makefile for {{TEMPLATE_APP_NAME}}

.PHONY: help setup-app setup-groups setup-app-ids bundle-install certs certs-dev certs-appstore certs-all certs-regenerate certs-regenerate-dev certs-regenerate-appstore certs-nuke-dev add-dev-device test build lint clean generate generate-strict generate-no-lint beta release-build sync-build-number sync-app-store privacy-details sync-featuring-nomination prepare-iap-review-screenshots icons capture-ios capture-frame capture-all

# Default target
help:
	@echo "{{TEMPLATE_APP_NAME}} Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup-app                - Register app in Apple Developer Portal"
	@echo "  make setup-groups             - Create the App Group and associate it with the App ID"
	@echo ""
	@echo "Certificate Management:"
	@echo "  make certs                    - Sync all certificates (development + appstore)"
	@echo "  make certs-dev                - Sync development certificates only"
	@echo "  make certs-appstore           - Sync App Store certificates only"
	@echo "  make certs-regenerate         - Force regenerate all profiles (use after adding capabilities)"
	@echo "  make certs-regenerate-dev     - Force regenerate development profiles"
	@echo "  make certs-regenerate-appstore - Force regenerate App Store profiles"
	@echo "  make certs-nuke-dev           - Revoke + delete the team development cert (then certs-regenerate-dev)"
	@echo "  make add-dev-device UDID=... NAME=... - Register a device and refresh dev profiles"
	@echo ""
	@echo "Development:"
	@echo "  make test                     - Run all tests"
	@echo "  make build                    - Build debug version"
	@echo "  make lint                     - Run linting checks"
	@echo "  make generate                 - Generate Xcode project (auto-fix mode)"
	@echo "  make generate-strict          - Generate Xcode project (strict mode)"
	@echo "  make generate-no-lint         - Generate Xcode project (no linting)"
	@echo ""
	@echo "Deployment:"
	@echo "  make beta                     - Build and upload to TestFlight"
	@echo "  make release-build            - Build release version for App Store"
	@echo "  make sync-build-number        - Set build number to latest TestFlight build + 1"
	@echo ""
	@echo "App Store Listing:"
	@echo "  make sync-app-store           - Upload metadata, screenshots, age rating (no binary)"
	@echo "  make privacy-details          - Upload App Privacy labels (needs Apple ID session / FASTLANE_SESSION)"
	@echo "  make sync-featuring-nomination - Sync fastlane/nominations/*.yml to App Store Connect"
	@echo "  make prepare-iap-review-screenshots - Flatten/resize IAP review screenshots for upload"
	@echo "  make icons                   - Export app icon renditions, submission icon, favicons (Marketing/icons)"
	@echo ""
	@echo "Screenshots (iOS/tvOS/watchOS only):"
	@echo "  make capture-ios              - Capture screenshots (fastlane/Snapfile)"
	@echo "  make capture-frame            - Frame screenshots with device bezels + titles"
	@echo "  make capture-all              - Capture and frame all screenshots"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean                    - Clean build artifacts"

# Bundle Install
bundle-install:
	@echo "📦 Installing Ruby dependencies..."
	@mise exec -- bundle check > /dev/null 2>&1 || mise exec -- bundle install

# Setup
setup-app: bundle-install
	@echo "📱 Registering app in Apple Developer Portal..."
	mise exec -- bundle exec fastlane setup_app

setup-groups: bundle-install
	@echo "👥 Creating App Group and associating it with the App ID..."
	mise exec -- bundle exec fastlane setup_groups

setup-app-ids: setup-app setup-groups

# Certificate Management
certs: certs-all

certs-all: bundle-install
	@echo "🔐 Syncing all certificates..."
	mise exec -- bundle exec fastlane sync_certificates

certs-dev: bundle-install
	@echo "🔐 Syncing development certificates..."
	mise exec -- bundle exec fastlane sync_certificates_development

certs-appstore: bundle-install
	@echo "🔐 Syncing App Store certificates..."
	mise exec -- bundle exec fastlane sync_certificates_appstore

certs-regenerate: bundle-install
	@echo "🔄 Force regenerating all provisioning profiles..."
	@echo "⚠️  This will update profiles with new capabilities like App Groups"
	mise exec -- bundle exec fastlane regenerate_all_profiles

certs-regenerate-dev: bundle-install
	@echo "🔄 Force regenerating development provisioning profiles..."
	mise exec -- bundle exec fastlane regenerate_development_profiles

certs-regenerate-appstore: bundle-install
	@echo "🔄 Force regenerating App Store provisioning profiles..."
	mise exec -- bundle exec fastlane regenerate_appstore_profiles

certs-nuke-dev: bundle-install
	@echo "💣 Revoking and deleting the team development certificate..."
	mise exec -- bundle exec fastlane nuke_development_certs

# Usage: make add-dev-device UDID=00008110-000123456789801E NAME="My iPhone"
add-dev-device: bundle-install
	@test -n "$(UDID)" || (echo "❌ UDID is required: make add-dev-device UDID=... NAME=..." && exit 1)
	@echo "📱 Registering device $(UDID)..."
	mise exec -- bundle exec fastlane add_dev_device udid:"$(UDID)" name:"$(NAME)"

# Development
test: bundle-install
	@echo "🧪 Running tests..."
	mise exec -- bundle exec fastlane test

build: bundle-install
	@echo "🔨 Building debug version..."
	mise exec -- bundle exec fastlane build

lint:
	@echo "✨ Running linting..."
	./Scripts/lint.sh

generate:
	@echo "🔧 Generating Xcode project (auto-fix mode)..."
	mise exec -- tuist generate

generate-strict:
	@echo "🔧 Generating Xcode project (strict linting mode)..."
	TUIST_LINT_MODE=STRICT mise exec -- tuist generate

generate-no-lint:
	@echo "🔧 Generating Xcode project (no linting)..."
	TUIST_LINT_MODE=none mise exec -- tuist generate

# Deployment
beta: bundle-install
	@echo "📦 Building and uploading to TestFlight..."
	mise exec -- bundle exec fastlane beta

release-build: bundle-install
	@echo "📦 Building release version..."
	mise exec -- bundle exec fastlane release_build

sync-build-number: bundle-install
	@echo "🔢 Syncing build number from TestFlight..."
	mise exec -- bundle exec fastlane sync_build_number

# App Store listing
# upload_app_privacy_details_to_app_store has no API-key auth: it needs an Apple
# ID session (cached in ~/.fastlane/spaceship locally, FASTLANE_SESSION in CI).
privacy-details: bundle-install
	@echo "🔒 Uploading App Privacy details..."
	mise exec -- bundle exec fastlane upload_privacy_details

# upload_metadata also tries privacy details first, non-fatally.
sync-app-store: bundle-install
	@echo "🛍️ Syncing App Store listing (metadata, screenshots, age rating)..."
	mise exec -- bundle exec fastlane upload_metadata

sync-featuring-nomination: bundle-install
	@echo "⭐ Syncing Featuring Nomination..."
	mise exec -- bundle exec fastlane sync_featuring_nomination

prepare-iap-review-screenshots:
	./Scripts/prepare-iap-review-screenshots.sh

icons:
	@echo "🎨 Exporting app icons..."
	./Scripts/generate-icons.sh

# Screenshots (iOS/tvOS/watchOS only)
capture-ios: generate bundle-install
	@echo "📸 Capturing screenshots..."
	mise exec -- bundle exec fastlane capture_ios

capture-frame: bundle-install
	@echo "🖼️ Framing screenshots with device bezels..."
	mise exec -- bundle exec fastlane capture_frame

capture-all: generate bundle-install
	@echo "📸 Capturing and framing all screenshots..."
	mise exec -- bundle exec fastlane capture_all

# Cleanup
clean:
	@echo "🧹 Cleaning build artifacts and untracked files..."
	@if command -v trash >/dev/null 2>&1; then \
		echo "📦 Moving to trash..."; \
		[ -d build/ ] && trash build/ || true; \
		[ -d DerivedData/ ] && trash DerivedData/ || true; \
		[ -d "Packages/{{TEMPLATE_PACKAGE_NAME}}/.build" ] && trash "Packages/{{TEMPLATE_PACKAGE_NAME}}/.build" || true; \
		[ -d "Packages/{{TEMPLATE_PACKAGE_NAME}}/.swiftpm" ] && trash "Packages/{{TEMPLATE_PACKAGE_NAME}}/.swiftpm" || true; \
		[ -d "Packages/{{TEMPLATE_APP_NAME}}App/.build" ] && trash "Packages/{{TEMPLATE_APP_NAME}}App/.build" || true; \
		[ -d "Packages/{{TEMPLATE_APP_NAME}}App/.swiftpm" ] && trash "Packages/{{TEMPLATE_APP_NAME}}App/.swiftpm" || true; \
		trash ~/Library/Developer/Xcode/DerivedData/{{TEMPLATE_APP_NAME}}-* 2>/dev/null || true; \
		trash *.xcodeproj 2>/dev/null || true; \
		trash *.xcworkspace 2>/dev/null || true; \
		find . -name .DS_Store -type f -exec trash {} + 2>/dev/null || true; \
		[ -f fastlane/report.xml ] && trash fastlane/report.xml || true; \
		git ls-files --others --ignored --exclude-standard | grep -v -e '\.claude/settings\.local\.json' -e '\.env' | xargs -I {} trash {} 2>/dev/null || true; \
	fi
	# -ff also removes untracked nested git repositories (e.g. SwiftPM checkouts).
	git clean -xdff --exclude=.claude/settings.local.json --exclude=.env
	@echo "✅ Clean complete"
