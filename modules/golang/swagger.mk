## Swagger specific configuration and targets
## The following variables must be set for publishing:
##
## GO_SWAGGER_PUBLISH_BUCKET
## GO_SWAGGER_PUBLISH_PATH

## List of commands for which will be generated swagger documentation.
## Defaults to all cmds
GO_SWAGGER_GEN ?= $(shell ls ./cmd/ 2> /dev/null | awk '{print $$0;}')

## Generates the swagger file for cmds in GO_SWAGGER_GEN.
.PHONY: go-swagger-gen
go-swagger-gen: $(foreach CMD,$(GO_SWAGGER_GEN),go-swagger-gen-$(CMD))

# Generates a swagger file of the specified cmd
.PHONY:
go-swagger-gen-%:
	$(eval CMD=$(@:go-swagger-gen-%=%))
	@ mkdir -p out/docs
	$(GO_TOOLS_DIR)/swagger generate spec --compact --output=out/docs/$(CMD).swagger.json ./cmd/$(CMD)
	sed --in-place --regexp-extended 's/"version":"([^"]*)"/"version":"$(VERSION)"/' out/docs/$(CMD).swagger.json

.PHONY: go-swagger-serve-%
go-swagger-serve-%:
	$(eval CMD=$(@:go-swagger-serve-%=%))
	@ mkdir -p out/docs
	$(GO_TOOLS_DIR)/swagger serve -F swagger out/docs/$(CMD).swagger.json

## Publishes all swagger files into GCP. Variables GO_SWAGGER_PUBLISH_BUCKET
## and GO_SWAGGER_PUBLISH_PATH must be set
.PHONY: go-swagger-publish
go-swagger-publish: $(foreach CMD,$(GO_SWAGGER_GEN),go-swagger-publish-$(CMD))

# Generates the swagger file for the given cmd.
# Variables GO_SWAGGER_PUBLISH_BUCKET and GO_SWAGGER_PUBLISH_PATH must be set
.PHONY: go-swagger-publish-%
go-swagger-publish-%:
ifndef GO_SWAGGER_PUBLISH_BUCKET
	$(error Please set GO_SWAGGER_PUBLISH_BUCKET variable)
endif
ifndef GO_SWAGGER_PUBLISH_PATH
	$(error Please set GO_SWAGGER_PUBLISH_PATH variable)
endif
	$(eval CMD=$(@:go-swagger-publish-%=%))
	gsutil cp \
		out/docs/$(CMD).swagger.json \
		gs://$(GO_SWAGGER_PUBLISH_BUCKET)/$(GO_SWAGGER_PUBLISH_PATH)/$(GO_PROJECT)-$(CMD).json
