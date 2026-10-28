SHELL := /bin/bash
.PHONY: help test build run package clean fmt-check version

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

version: ## Print version from package.json (Swift)
	swift run -c release VersionTool

test: ## Run CoreTestRunner
	swift run -c release CoreTestRunner

build: ## Build the menu-bar app (release)
	swift build -c release --product KeyboardSourceLockerApp

run: ## Run the app via SwiftPM
	swift run KeyboardSourceLockerApp

package: ## Build and package dist/KeyboardSourceLocker.app (version from package.json)
	chmod +x Scripts/package-app.sh
	Scripts/package-app.sh release

clean: ## Remove build and dist outputs
	rm -rf .build dist

fmt-check: ## Compile-check all products (smoke)
	swift build -c debug --product KeyboardSourceLockerApp
	swift build -c debug --product CoreTestRunner
	swift build -c debug --product VersionTool
