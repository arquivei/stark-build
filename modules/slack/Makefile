## #####################################
##
## Module Slack
##
## This module provides slack integration

$(info [Stark Build] Initializing slack module...)


# For this to work you must write the desired message in a json file and
# configure NOTIFY_SLACK_MESSAGE variable to this file. Like:
# NOTIFY_SLACK_MESSAGE = notify-slack-message.json

# This will be used by notify-slack to be replaced in the template message.
# By default it will show only the last commit message.
# This can be overwritten by redefining this variable in the main Makefile.

## Message that will be sent to slack
SLACK_GIT_LOG ?= $(shell git log -1 | sed -e ':a' -e 'N' -e '$$!ba' -e 's/\n/\\n/g' -e 's/"/\\"/g')

$(info [Stark Build]   SLACK_MESSAGE = $(SLACK_MESSAGE))
$(info [Stark Build]   SLACK_WEBHOOK_URL = $(SLACK_WEBHOOK_URL))

## Posts a message to slack.
.PHONY: slack-send-message
slack-send-message: require-SLACK_MESSAGE require-SLACK_WEBHOOK_URL
	GIT_LOG='$(SLACK_GIT_LOG)' \
		envsubst < $(SLACK_MESSAGE) | \
		curl \
			--header 'Content-type: application/json' \
			--data @- $(SLACK_WEBHOOK_URL)

$(info [Stark Build] Slack module loaded.)
