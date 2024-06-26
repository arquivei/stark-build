## #####################################
##
## Module: Meta
##
## This module handles stuff related to the Stark Build itself
## or provides utility targets.

ifeq ($(STARK_BUILD_DEBUG),true)
$(info [Stark Build] Initializing meta module...)
endif

# This target was created inspired by this stackoverflow question:
# https://stackoverflow.com/questions/4728810/makefile-variable-as-prerequisite/35845931

## Requires that a specific variable is defined, example require-MYVAR
require-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable $* not set"; \
		exit 1; \
	fi

## Prints the variable value, e.g., make print-VERSION
print-%: require-%
	@ echo "${${*}}"

## Updates the Stark Build System to the latest version.
.PHONY: stark-build-update
stark-build-update:
	cd $(STARK_BUILD_DIR) && git fetch --prune --prune-tags && git reset --hard origin/main

## Prints this help.
.PHONY: help
help:
	@awk -f $(STARK_BUILD_DIR)modules/meta/help.awk $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

ifeq ($(STARK_BUILD_DEBUG),true)
$(info [Stark Build] Meta module initialized.)
endif
