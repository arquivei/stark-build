## #####################################
##
## Module: Meta
##
## This module handles stuff related to the Stark Build itself
## or provides utility targets.

$(info [Stark Build] Initializing meta module...)

# This target was created inspired by this stackoverflow question:
# https://stackoverflow.com/questions/4728810/makefile-variable-as-prerequisite/35845931

## Requires that a specific variable is defined, example require-MYVAR
require-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

## Prints the variable value, e.g., make print-VERSION
print-%:
	@ echo "${${*}}"

## Updates Stark Build System.
.PHONY: update-stark-build
update-stark-build:
	git submodule update --init --recursive $(STARK_BUILD_DIR)


## Prints this help.

.PHONY: help
help:
	@awk -f $(STARK_BUILD_DIR)modules/meta/help.awk $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

$(info [Stark Build] Meta module initialized.)
