# Makefile for {{TEMPLATE_APP_NAME}}

.PHONY: help setup-app bundle-install certs certs-dev certs-appstore certs-all certs-regenerate certs-regenerate-dev certs-regenerate-appstore test build lint clean generate generate-strict generate-no-lint screenshots screenshots-frame screenshots-all

# Default target
help:
	@echo "{{TEMPLATE_APP_NAME}} Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup-app                - Register app in Apple Developer Portal"
	@echo ""
	@echo "Certificate Management:"
	@echo "  make certs                    - Sync all certificates (development + appstore)"
	@echo "  make certs-dev                - Sync development certificates only"
	@echo "  make certs-appstore           - Sync App Store certificates only"
	@echo "  make certs-regenerate         - Force regenerate all profiles (use after adding capabilities)"
	@echo "  make certs-regenerate-dev     - Force regenerate development profiles"
	@echo "  make certs-regenerate-appstore - Force regenerate App Store profiles"
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
	@echo ""
	@echo "Screenshots (iOS/tvOS/watchOS only):"
	@echo "  make screenshots              - Capture screenshots"
	@echo "  make screenshots-frame        - Frame screenshots with device overlays"
	@echo "  make screenshots-all          - Capture and frame all screenshots"
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

# Screenshots (iOS/tvOS/watchOS only)
screenshots: generate bundle-install
	@echo "📸 Capturing screenshots..."
	mise exec -- bundle exec fastlane screenshots

screenshots-frame: bundle-install
	@echo "🖼️ Framing screenshots with device overlays..."
	mise exec -- bundle exec fastlane screenshots_frame

screenshots-all: generate bundle-install
	@echo "📸 Capturing and framing all screenshots..."
	mise exec -- bundle exec fastlane all_screenshots

# Cleanup
clean:
	@echo "🧹 Cleaning build artifacts and untracked files..."
	@if command -v trash >/dev/null 2>&1; then \
		echo "📦 Moving to trash..."; \
		[ -d build/ ] && trash build/ || true; \
		[ -d DerivedData/ ] && trash DerivedData/ || true; \
		[ -d "Packages/{{TEMPLATE_APP_NAME}}Kit/.build" ] && trash "Packages/{{TEMPLATE_APP_NAME}}Kit/.build" || true; \
		[ -d "Packages/{{TEMPLATE_APP_NAME}}Kit/.swiftpm" ] && trash "Packages/{{TEMPLATE_APP_NAME}}Kit/.swiftpm" || true; \
		trash ~/Library/Developer/Xcode/DerivedData/{{TEMPLATE_APP_NAME}}-* 2>/dev/null || true; \
		trash *.xcodeproj 2>/dev/null || true; \
		trash *.xcworkspace 2>/dev/null || true; \
		find . -name .DS_Store -type f -exec trash {} + 2>/dev/null || true; \
		[ -f fastlane/report.xml ] && trash fastlane/report.xml || true; \
		git ls-files --others --ignored --exclude-standard | grep -v -e '\.claude/settings\.local\.json' -e '\.env' | xargs -I {} trash {} 2>/dev/null || true; \
	fi
	git clean -xdf --exclude=.claude/settings.local.json --exclude=.env
	@echo "✅ Clean complete"
