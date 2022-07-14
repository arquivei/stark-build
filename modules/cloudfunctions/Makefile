## #####################################
##
## Module: Cloud Functions
##
## This module handles compilation and publishing of
## google's cloud functions.

## Variables

## Compiled directory (must end with slash)
CLOUDFUNCTIONS_BIN_DIR ?= out/cloudfunctions/

## Source directory for cloud functions (must end with slash)
## Default: functions/
CLOUDFUNCTIONS_SRC_DIR ?= functions/

# Functions to be build automatically
CLOUDFUNCTIONS ?= $(shell ls $(CLOUDFUNCTIONS_SRC_DIR) 2>/dev/null)

$(info [Stark Build] Initializing CloudFunctions module...)

## Targets

.PHONY: cloudfunctions cloudfunction-% cloudfunction-vendor-%

## Initial implementation of cloud-functions building. As of now, it just makes zip files
cloudfunctions: $(foreach CLOUDFUNCTION,$(CLOUDFUNCTIONS),cloudfunction-$(CLOUDFUNCTION))

## Creates the zip files of cloud functions
cloudfunction-%: cloudfunction-vendor-%
	mkdir -p $(PROJECT_DIR)$(CLOUDFUNCTIONS_BIN_DIR)
	$(eval FUNC=$(@:cloudfunction-%=%))
	$(eval FUNCZIP=$(PROJECT_DIR)$(CLOUDFUNCTIONS_BIN_DIR)$(FUNC).zip)

	rm -f $(FUNCZIP)
	cd $(CLOUDFUNCTIONS_SRC_DIR)$(FUNC) && \
	find -type f \
	-path './vendor/*' \
	-o '(' -name '*.go' -not -name '*_test.go' -not -path '*/testdata/*' -not -path '*/cmd/*' ')' | \
	zip $(FUNCZIP)  -@

# Vendor

.PHONY: cloudfunctions-vendor cloudfunction-vendor-%

cloudfunctions-vendor:$(foreach CLOUDFUNCTION,$(CLOUDFUNCTIONS),cloudfunction-vendor-$(CLOUDFUNCTION)) ## Dowload all the dependencies of all cloud functions to their respective vendors

cloudfunction-vendor-%:  ## Download all the dependencies of a single cloud function to its vendor
	cd $(CLOUDFUNCTIONS_SRC_DIR)$(@:cloudfunction-vendor-%=%) && \
	$(GO) mod vendor

.PHONY: cloudfunctions-tests cloudfunction-tests-%

cloudfunctions-tests: $(foreach CLOUDFUNCTION,$(CLOUDFUNCTIONS),cloudfunction-tests-$(CLOUDFUNCTION))  ## Run go test to all cloud functions

## Run go test to specific cloud function
cloudfunction-tests-%: cloudfunction-vendor-%
	cd $(CLOUDFUNCTIONS_SRC_DIR)$(@:cloudfunction-tests-%=%) && \
	$(GO) test -short ./...

# Linting

# Because the function's directory has a go.mod file, it's handled as a separate project and it's not checked by the default linter.
# To make it work, we create a new target to handle the functions alone using the default linter and configuration.

.PHONY: cloudfunctions-lint cloudfunction-lint-%

cloudfunctions-lint: $(foreach CLOUDFUNCTION,$(CLOUDFUNCTIONS),cloudfunction-lint-$(CLOUDFUNCTION)) ## Run golangci to all cloud functions

cloudfunction-lint-%: cloudfunction-vendor-% ## Run golangci to specific cloud function
	cd $(CLOUDFUNCTIONS_SRC_DIR)$(@:cloudfunction-lint-%=%) && \
	$(GO_TOOLS_DIR)/golangci-lint --config $(PROJECT_DIR).golangci.yml run

# publishing and deploy

.PHONY: cloudfunctions-publish cloudfunction-publish-%

## Saves the cloud functions in GCS.
cloudfunctions-publish: $(foreach CLOUDFUNCTION,$(CLOUDFUNCTIONS),cloudfunction-publish-$(CLOUDFUNCTION)) ## Publishes all cloud functions in a GCS bucket

## Prefix for the path of the cloud function inside GCS.
CLOUDFUNCTIONS_GCS_PREFIX ?= cloud-functions

cloudfunction-publish-%: require-CLOUDFUNCTIONS_GCS_BUCKET
	$(eval CLOUDFUNCTION=$(@:cloudfunction-publish-%=%))
	gsutil cp \
		$(CLOUDFUNCTIONS_BIN_DIR)$(CLOUDFUNCTION).zip \
		gs://$(CLOUDFUNCTIONS_GCS_BUCKET)/$(CLOUDFUNCTIONS_GCS_PREFIX)/$(GO_PROJECT)/$(CLOUDFUNCTION)/$(VERSION)/function.zip

## Directory containning terraform files used to deploy the cloud function.
## NOTE: This should be revisited in the future.
CLOUDFUNCTIONS_DEPLOY_DIR ?= $(PROJECT_DIR)/tooling/terraform/

## Deploys the cloud functions using terraform.
.PHONY: cloudfunctions-deploy
cloudfunctions-deploy:
	cd $(CLOUDFUNCTIONS_DEPLOY_DIR) && \
	TF_VAR_cloudfunction_version=$(VERSION) terraform apply -auto-approve


## Removes cloud functions files.
cloudfunctions-clean:
	rm -rf $(CLOUDFUNCTIONS_BIN_DIR)*.zip

$(info [Stark Build] CloudFunctions module loaded.)
