##
## #####################################
##
## Module: Git
##
## This module provides git integration

ifeq ($(STARK_BUILD_DEBUG),true)
$(info [Stark Build] Initializing git module...)
endif

## List of targets that will run on pre-commit
## Default: go-tools vendor git-ensure-clean go-lint go-tests go-ensure-coverage
GIT_HOOKS_PRECOMMIT ?= go-tools vendor git-ensure-clean go-lint go-tests go-ensure-coverage

## List of targets that will run on post-merge
## Default: vendor
GIT_HOOKS_POSTMERGE ?= vendor

## Directory containing the hooks that should be installed.
## Default: $(STARK_BUILD_DIR)modules/git/hooks
GIT_HOOKS_DIR ?= $(STARK_BUILD_DIR)modules/git/hooks

## Fails if there are unstaged changes.
.PHONY: git-ensure-clean
git-ensure-clean:
	@ if git status --porcelain | grep -qe '^[ MADRCU?!][^ ]' ; then \
		echo "You have modified or untracked files"; \
		git status --porcelain | grep -e '^[ MADRCU?!][^ ]'; \
		exit 1; \
	fi

## Installs all hooks from directory githooks.
.PHONY: git-install-hooks
git-install-hooks: $(GIT_HOOKS_DIR)
	ln -sf $(GIT_HOOKS_DIR)/* .git/hooks/

## Executes pre-commit hook.
.PHONY: git-execute-hook-precommit
git-execute-hook-precommit: $(GIT_HOOKS_PRECOMMIT)

## Executes post-merge hook.
.PHONY: git-execute-hook-postmerge
git-execute-hook-postmerge: $(GIT_HOOKS_POSTMERGE)

ifeq ($(STARK_BUILD_DEBUG),true)
$(info [Stark Build] Git module loaded.)
endif
