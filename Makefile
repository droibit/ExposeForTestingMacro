.PHONY: bootstrap
bootstrap:
	@brew install mint
	@mint bootstrap

.PHONY: build
build:
	@export TOOLCHAINS=swift
	@swift build

.PHONY: test
test:
	@swift test

.PHONY: format
format:
	@swiftformat .

.PHONY: lint
lint:
	@xcrun --sdk macosx mint run swiftformat swiftformat --lint .
	@xcrun --sdk macosx mint run swiftlint swiftlint lint .
