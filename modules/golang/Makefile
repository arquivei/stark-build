## #####################################
##
## Module: Golang
##
## This makefile contains common instructions to build golang artifacts

## Variables

# Maybe you would like to change these variables:

## List of the binaries being built.
GO_BINS ?= $(shell ls ./cmd/ 2> /dev/null)

## List of .so libraries being built.
GO_LIBS ?= $(shell ls $(GO_LIB_DIR) 2>/dev/null)

## Minimum coverage required by go-ensure-coverage.
## This step will fail if coverage fall bellow this number.
GO_MINIMUM_COVERAGE ?= 80

# You probably don't want to change these variables.
# Those can be changed to fine tune the build proccess.
# Use with caution.

GO_MODULE ?= $(shell head go.mod | grep module | cut -d ' ' -f2)
GO_PROJECT ?= $(notdir $(GO_MODULE))

# Let's always assume someone wants to build for Linux
# If it is not the case, use 'GOOS=darwin make' instead
GOOS        ?= linux
GOARCH      ?= amd64
CGO_ENABLED ?= 0
GO111MODULE ?= on

export GO_MODULE
export GO_PROJECT
export GOOS
export GOARCH
export GO111MODULE

# Specific variables to be used inside the pipeline
ifeq ($(PIPELINE_ENABLED),1)
# Use local .cache when inside pipeline message
GOCACHE ?= $(CURDIR)/.cache/go
GOLANGCI_LINT_CACHE ?= $(CURDIR)/.cache/golangci-lint
# Export cache variables so programs can use it
export GOCACHE
export GOLANGCI_LINT_CACHE
endif

# Basic go commands
GO       ?= go
# CGO must always be enabled during tests
GO_TEST   ?= CGO_ENABLED=1 $(GO) test -mod=vendor -tags="$(GOBUILDTAGS)"
GO_TOOL   ?= $(GO) tool
GO_BUILD  ?= $(GO) build -mod=vendor -tags="$(GOBUILDTAGS)" -ldflags="-s -w -X main.version=$(VERSION) $(GOLDFLAGS)"

# GO_COVER_MODE sets the coverage mode.
# https://blog.golang.org/cover
# The go test command accepts a -covermode flag to set the coverage mode to one of three settings:
# set: did each statement run?
# count: how many times did each statement run?
# atomic: like count, but counts precisely in parallel programs
GO_COVER_MODE ?= set

GO_LIB_DIR ?= lib
GO_LIB_OUTPUT_DIR ?= out/lib

ifeq ($(STARK_BUILD_DEBUG),true)
$(info [Stark Build] Initializing golang module...)
$(info [Stark Build]   GOVERSION = $(shell $(GO) env GOVERSION))
$(info [Stark Build]   GO_BINS = $(GO_BINS))
$(info [Stark Build]   COMPRESS_ENABLED = $(COMPRESS_ENABLED))
$(info [Stark Build]   GO_MINIMUM_COVERAGE = $(GO_MINIMUM_COVERAGE))
$(info [Stark Build]   GO_LIBS = $(GO_LIBS))
endif

## Compilation targets

out/bin:
	mkdir -p out/bin

## Compiles all binaries listed in GO_BINS.
.PHONY: go-bin
go-bin:
	@for BIN in $(GO_BINS); do \
		echo "[Stark Build] Building '$${BIN}'..."; \
		$(MAKE) "out/bin/$${BIN}"; \
	done;

# Generic rule for building binaries
out/bin/%: vendor | out/bin ## Compiles a command under cmd/<command> into out/bin/<command>
	$(eval $(file < ./cmd/$(@:out/bin/%=%)/buildenv.mk))
	CGO_ENABLED=$(CGO_ENABLED) $(GO_BUILD) -o $@ ./cmd/$(@:out/bin/%=%)

## Creates and/or syncs the vendor directory.
.PHONY: vendor
vendor:  ## Download all the dependencies to vendor
	$(GO) mod vendor

## Libraries specific targets

$(GO_LIB_OUTPUT_DIR):
	mkdir -p $@

## GCP Project where the lib will be published.
## artifacts.$(GO_LIB_GCP_PROJECT).appspot.com
GO_LIB_PUBLISH_BUCKET ?= artifacts.$(GO_LIB_GCP_PROJECT).appspot.com


## Builds all libraries listed in GO_LIBS.
.PHONY: go-libs
go-libs: $(foreach LIB,$(GO_LIBS),$(GO_LIB_OUTPUT_DIR)/$(LIB)_$(VERSION).tar.gz)

$(GO_LIB_OUTPUT_DIR)/%:
	mkdir -p $@

.PHONY: $(GO_LIB_OUTPUT_DIR)/%.tar.gz
$(GO_LIB_OUTPUT_DIR)/%.tar.gz: vendor | $(GO_LIB_OUTPUT_DIR)
	$(eval LIB = $(@:$(GO_LIB_OUTPUT_DIR)/%_$(VERSION).tar.gz=%))
	$(eval LIBSO = $(@:%.tar.gz=%/$(LIB).so))
	CGO_ENABLED=1 $(GO_BUILD) -o $(LIBSO) -buildmode=c-shared ./$(GO_LIB_DIR)/$(LIB)
	tar zcvf $@ -C $(GO_LIB_OUTPUT_DIR) $(LIB)_$(VERSION)

## Publishes all libraries.
.PHONY: go-libs-publish
go-libs-publish: $(foreach LIB,$(GO_LIBS),go-lib-publish-$(LIB))

# Publishes a single library.
.PHONY: go-lib-publish-%
go-lib-publish-%:
ifeq ($(GO_LIB_GCP_PROJECT),)
	$(error Variable GO_LIB_GCP_PROJECT is empty. Please set it)
endif
	$(eval LIB = $(@:go-lib-publish-%=%))
	gsutil cp \
		$(GO_LIB_OUTPUT_DIR)/$(LIB)_$(VERSION).tar.gz \
		gs://$(GO_LIB_PUBLISH_BUCKET)/libs/$(GO_PROJECT)/$(LIB)/

## Testing and linting targets

## Run tests
.PHONY: go-tests
go-tests: ## Run all tests
	$(GO_TEST) ./...

## Run tests and outputs in xunit format inside tests-results/ directory.
## This is mainly used inside bitbucket pipeline.
.PHONY: go-tests-xunit
go-tests-xunit:  ## Run unit tests and create a xunit file at test-results/$(GO_PROJECT)/tests.xml
	@mkdir -p test-results/$(GO_PROJECT)
	$(GO_TEST) -v ./... 2>&1 | \
		$(GO_TOOLS_DIR)/go-junit-report -set-exit-code -package-name $(GO_MODULE) > test-results/$(GO_PROJECT)/tests.xml

## Produces a coverage.html code coverage report.
.PHONY: go-coverage
go-coverage: coverage.html

PHONY: .cover/cover.out
.cover/cover.out:
	@rm -rf .cover
	@mkdir .cover
	@for SUBPKG in $(shell $(GO) list -mod=vendor ./...) ; do \
		FILE=$${SUBPKG##$(PKG)/} ; $(GO_TEST) \
		-covermode="$(GO_COVER_MODE)" \
		-coverprofile=".cover/$${FILE////-}.cover" \
		"$$SUBPKG" | tee -a .cover/stdout.txt || exit 1; \
	done
	echo "mode: $(GO_COVER_MODE)" > .cover/cover.out
	grep -h -v "^mode:" .cover/*.cover >> .cover/cover.out

.cover/stdout.txt: .cover/cover.out
.cover/report.txt: .cover/stdout.txt
	@cat .cover/stdout.txt | \
		sed 's|.*/$(GO_PROJECT)/||' | \
		grep -ve '^$(STARK_BUILD_DIR)/' \
			-e '^cmd/' \
			-e '^sdk/' \
			-e '.*/examples/.*' \
			-e '.*/worker[^/]*$$' \
			-e '.*/api[^/]*$$' > .cover/report.txt

coverage.html: .cover/cover.out
	$(GO_TOOL) cover -html=.cover/cover.out -o coverage.html

## Checks for minimum required code coverage
.PHONY: go-ensure-coverage
go-ensure-coverage: .cover/cover.out
	@$(eval COVERAGE := $(shell $(GO_TOOL) cover -func=.cover/cover.out | tail -1 | awk -F '\t+' '{print $3}' | grep -o '[0-9.]*'))
	@echo "COVERAGE: $(COVERAGE)% / $(GO_MINIMUM_COVERAGE)%"
	@if [ $(shell echo "$(COVERAGE) < $(GO_MINIMUM_COVERAGE)" | bc -l) -gt 0 ]; then \
		false; \
	fi


## Runs all the benchmarks, and stores the results into a benchmark_base.txt file
.PHONY: go-benchmark
go-bench:
	@$(GO_TEST) ./...  -run=no_tests -bench=.* -benchmem | tee benchmark_base.txt

#.PHONY: go-benchmark-compare
# TODO: create go-bench-compare that uses benchstat because the previous benchcmp is deprecated.
# https://pkg.go.dev/golang.org/x/perf/cmd/benchstat

## Utility targets

## Removes all assests created by the golang building
.PHONY: go-clean
go-clean:
	rm -rf out/bin test-results .cover coverage.html benchmark_latest.txt

## Updates the version of the dependencies in go.mod and go.sum
.PHONY: go-update-vendor
go-update-vendor:
	$(GO) get -u ./...
	$(GO) mod tidy
	$(GO) mod vendor

# Includes other files
include $(STARK_BUILD_DIR)/modules/golang/tools.mk
include $(STARK_BUILD_DIR)/modules/golang/swagger.mk

ifeq ($(STARK_BUILD_DEBUG),true)
$(info [Stark Build] Golang module loaded.)
endif
