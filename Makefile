.PHONY: help build test lint clean

help:
	@echo "Available targets:"
	@echo "  build  - Build the root package (TaylrDescription, TaylrKit, taylr)"
	@echo "  test   - Run the root test suite"
	@echo "  lint   - Run swift-format + SwiftLint (strict) via Scripts/lint.sh"
	@echo "  clean  - Clean build artifacts"
	@echo "  help   - Show this help message"
	@echo ""
	@echo "Each package under Packages/ has the same targets; run make there."
	@echo "Lint tooling is pinned in .mise.toml. Run 'mise install' once."

build:
	swift build

test:
	swift test

lint:
	@./Scripts/lint.sh

clean:
	swift package clean
	rm -rf .build
