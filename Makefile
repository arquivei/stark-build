## #####################################
##
## Stark Build System
##
## This is the "entry point" to the stark-build make
## tools. Special automatic configurations and importing of
## further makefiles should be centralized in this file, when
## possible.

## Version of the project being built.
## Defaults to last git tag.
VERSION  ?= $(shell git describe --tags --always 2> /dev/null || echo 'development')

## List of enabled Stark Build System modules.
## The name of the modules are the directories inside 'modules/' directory.
STARK_BUILD_MODULES ?= meta git golang cloudfunctions docker slack

current_makefile_path = $(abspath $(lastword $(MAKEFILE_LIST)))
# STARK_BUILD_DIR is the directory of this file.
STARK_BUILD_DIR = $(dir $(current_makefile_path))

main_makefile_path = $(abspath $(firstword $(MAKEFILE_LIST)))

# This is the directory of the project includind this makefile.
PROJECT_DIR = $(dir $(main_makefile_path))


## Cache directory where modulos may store temporary files.
STARK_BUILD_CACHE_DIR ?= .cache

ifeq ($(VERSION),)
$(error VERSION is empty. Please set VERSION variable)
endif

ifeq ($(STARK_BUILD_MODULES),)
$(error STARK_BUILD_MODULES is empty. Please set STARK_BUILD_MODULES variable)
endif

$(info [Stark Build] Initializing Stark Build System...)
$(info [Stark Build]   STARK_BUILD_DIR = $(STARK_BUILD_DIR))
$(info [Stark Build]   STARK_BUILD_MODULES = $(STARK_BUILD_MODULES))
$(info [Stark Build]   VERSION = $(VERSION))

include $(foreach MOD,$(STARK_BUILD_MODULES),$(STARK_BUILD_DIR)/modules/$(MOD)/Makefile)

$(info [Stark Build] Stark Build System initialized. Have a nice day! )
