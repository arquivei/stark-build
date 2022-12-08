## #####################################
##
## Module: Docker
## This module handles docker image creation and publishing.

## Images to be created are listed by DOCKER_IMAGES variable,
## and defaults to all directories found directly under 'cmd'
## path.
##
## By default, a scratch image (see stark-build/docker/Dockerfile)
## will be used. If a custom Dockerfile is needed, a Dockerfile must
## be created under the cmd directory, i.e., 'cmd/mybinary/Dockerfile'.
## This new Dockerfile will be used automatically.
##
## NOTE: Some variables are deprecated. Please update your build.

## Docker Module Variables

## List of images the will be built or published. It defaults
## to cmd/ directory content.
DOCKER_IMAGES ?= $(shell ls ./cmd/ 2> /dev/null)

## Name of the project. This will compose the image's name like
## 'gcr.io/<GCR_PROJECT>/<DOCKER_BASE_IMAGE>/<CMD>:<VERSION>'.
## It defaults to the projets directory name.
## Deprecated: Use DOCKER_IMAGE_PREFIX instead
DOCKER_BASE_IMAGE ?= $(GO_PROJECT)

## Google's registry prefix that will be pre-appended at the
## image name like '<GCR_BASE_URL>/<DOCKER_BASE_IMAGE>/<CMD>:<VERSION>'.
## Defaults to 'gcr.io/<GCR_PROJECT>'. See GCR_PROJECT.
## Deprecated: Use DOCKER_IMAGE_PREFIX instead
GCR_BASE_URL ?=

## Is the project id for the google's container registry. See DOCKER_BASE_IMAGE
## documentation.
## Deprecated: Use DOCKER_IMAGE_PREFIX instead
GCR_PROJECT ?=

ifdef GCR_BASE_URL
$(info [Stark Build] !!! Setting GCR_BASE_URL is deprecated. Please set DOCKER_IMAGE_PREFIX instead.)
ifndef DOCKER_BASE_IMAGE
$(error [Stark Build] Missing required variable DOCKER_BASE_IMAGE)
endif
DOCKER_IMAGE_PREFIX ?= $(GCR_BASE_URL)/$(DOCKER_BASE_IMAGE)
else
ifdef GCR_PROJECT
$(info [Stark Build] !!! Setting GCR_PROJECT is deprecated. Please set DOCKER_IMAGE_PREFIX instead.)
DOCKER_IMAGE_PREFIX ?= gcr.io/$(GCR_PROJECT)/$(DOCKER_BASE_IMAGE)
else
## Prefix of the image. This will be used to make the fullname of the
## image as <DOCKER_IMAGE_PREFIX>/<CMD>:<VERSION>
## The default value is deprecated and will depends on what variables are set. The order is:
##   1: $(GCR_BASE_URL)/$(DOCKER_BASE_IMAGE)
##   2: gcr.io/$(GCR_PROJECT)/$(DOCKER_BASE_IMAGE)
DOCKER_IMAGE_PREFIX ?=
endif
endif

$(info [Stark Build] Initializing docker module...)
$(info [Stark Build]   DOCKER_IMAGES = $(DOCKER_IMAGES))
$(info [Stark Build]   DOCKER_IMAGE_PREFIX = $(DOCKER_IMAGE_PREFIX))
$(info [Stark Build]   DOCKER_BASE_IMAGE [Deprecated] = $(DOCKER_BASE_IMAGE))
$(info [Stark Build]   GCR_PROJECT [Deprecated] = $(GCR_PROJECT))
$(info [Stark Build]   GCR_BASE_URL [Deprecated] = $(GCR_BASE_URL))

## Docker Module Targets

## Builds all images listed in DOCKER_IMAGES var.
.PHONY: docker-images
docker-images: $(foreach img,$(DOCKER_IMAGES),docker-image-$(img))

## Builds a tar file containing all images
out/docker_images.tar: docker-images require-DOCKER_IMAGE_PREFIX
	docker save --output $@ $(foreach img,$(DOCKER_IMAGES),$(DOCKER_IMAGE_PREFIX)/$(img):$(VERSION))

## Builds single docker image
.PHONY: docker-image-%
docker-image-%: require-DOCKER_IMAGE_PREFIX
	$(eval BINARY = $(@:docker-image-%=%))
	$(eval DOCKERFILE = $(shell [ -f cmd/$(BINARY)/Dockerfile ] && echo cmd/$(BINARY)/Dockerfile || echo $(STARK_BUILD_DIR)modules/docker/Dockerfile ) )
	docker build \
		--build-arg BINARY=out/bin/$(BINARY) \
		--file $(DOCKERFILE) \
		--pull \
		--tag '$(DOCKER_IMAGE_PREFIX)/$(BINARY):$(VERSION)' \
		.

## Publishes all docker images using VERSION as tag.
.PHONY: docker-publish
docker-publish: $(foreach img,$(DOCKER_IMAGES),docker-publish-version-$(img))

## Publishes all docker images using 'latest' as tag.
.PHONY: docker-publish-latest
docker-publish-latest: $(foreach img,$(DOCKER_IMAGES),docker-publish-latest-$(img))

## Publishes a single image using 'latest' as tag.
docker-publish-latest-%: require-DOCKER_IMAGE_PREFIX require-VERSION
	$(eval IMAGE = $(@:docker-publish-latest-%=$(DOCKER_IMAGE_PREFIX)/%))
	$(eval LOCAL_TAG = $(IMAGE):$(VERSION))
	$(eval REMOTE_TAG = $(IMAGE):latest)
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

## Publishes the generated images into Google's Registry using version as tag.
docker-publish-version-%: require-DOCKER_IMAGE_PREFIX require-VERSION
	$(eval IMAGE = $(@:docker-publish-version-%=$(DOCKER_IMAGE_PREFIX)/%))
	docker push $(IMAGE):$(VERSION)

## Removes all local images matching the same base name.
.PHONY: docker-clean
docker-clean:
	docker images -a | grep $(DOCKER_IMAGE_PREFIX) | awk '{print $$3}' | xargs --no-run-if-empty docker rmi

$(info [Stark Build] Docker module initialized.)
