.PHONY: bootstrap
bootstrap:
	@brew install swiftformat

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
	@swiftformat --lint .
