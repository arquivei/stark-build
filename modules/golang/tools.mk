## Tooling

## List of tools that should be enabled
GO_TOOLS ?= golangci-lint go-junit-report goose swagger

## Directory where we will store external tools
GO_TOOLS_DIR ?= $(STARK_BUILD_CACHE_DIR)/tools

GO_TOOLS_OS ?= linux
GO_TOOLS_ARCH ?= amd64

## Selects swagger version.
## https://github.com/go-swagger/go-swagger/releases
GO_TOOLS_SWAGGER_VERSION ?= v0.30.4

## Selects golangci-lint version.
## https://github.com/golangci/golangci-lint/releases
GO_TOOLS_GOLANGCI_VERSION ?= 1.51.0

## Selects goose version.
## https://github.com/pressly/goose/releases
GO_TOOLS_GOOSE_VERSION ?= v3.9.0

## Selects go-junit-report version.
## https://github.com/jstemmer/go-junit-report/releases
GO_TOOLS_XUNIT_VERSION ?= v2.0.0

$(info [Stark Build]   GO_TOOLS = $(GO_TOOLS))
$(info [Stark Build]   GO_TOOLS_DIR = $(GO_TOOLS_DIR))

$(GO_TOOLS_DIR):
	mkdir -p $(GO_TOOLS_DIR)

## Lint the files using golangci-lint
go-lint: | $(GO_TOOLS_DIR)/golangci-lint
	$(GO_TOOLS_DIR)/golangci-lint run --build-tags="$(GOBUILDTAGS)"

## Updates the golang tools to the predefined versions
.PHONY: go-tools
go-tools: $(foreach tool,$(GO_TOOLS),$(GO_TOOLS_DIR)/$(tool))
	$(info All golang tools are updated.)

# Because swagger source installation is too complex,
# we do binary installation instead.
# See https://goswagger.io/install.html
.PHONY: $(GO_TOOLS_DIR)/swagger
$(GO_TOOLS_DIR)/swagger: | $(GO_TOOLS_DIR)
	@$(STARK_BUILD_DIR)modules/golang/install-go-tool.sh $(GO_TOOLS_DIR) $@ github.com/go-swagger/go-swagger/cmd/swagger $(GO_TOOLS_SWAGGER_VERSION) version

# Installation script is preferred over `go install`.
# See: https://golangci-lint.run/usage/install/
.PHONY: $(GO_TOOLS_DIR)/golangci-lint
$(GO_TOOLS_DIR)/golangci-lint: | $(GO_TOOLS_DIR)
	@ if ! $@ --version | grep -q -s -F "$(GO_TOOLS_GOLANGCI_VERSION)"; then \
		echo "Installing $(notdir $@) version $(GO_TOOLS_GOLANGCI_VERSION)"; \
		curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
			sh -s -- -b "$(GO_TOOLS_DIR)" "v$(GO_TOOLS_GOLANGCI_VERSION)"; \
	else \
		echo "$(notdir $@) already at version $(GO_TOOLS_GOLANGCI_VERSION)"; \
	fi

.PHONY: $(GO_TOOLS_DIR)/goose
$(GO_TOOLS_DIR)/goose: | $(GO_TOOLS_DIR)
	@$(STARK_BUILD_DIR)modules/golang/install-go-tool.sh $(GO_TOOLS_DIR) $@ github.com/pressly/goose/v3/cmd/goose $(GO_TOOLS_GOOSE_VERSION) -version

.PHONY: $(GO_TOOLS_DIR)/go-junit-report
$(GO_TOOLS_DIR)/go-junit-report:
	@$(STARK_BUILD_DIR)modules/golang/install-go-tool.sh $(GO_TOOLS_DIR) $@ github.com/jstemmer/go-junit-report/v2 $(GO_TOOLS_XUNIT_VERSION) -version
