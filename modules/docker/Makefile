## #####################################
##
## Module: Docker
## This module handles docker image creation and publishing.

## Images to be created are listed by DOCKER_IMAGES variable,
## and defaults to all directories found directly under 'cmd'
## path.
##
## By default, a scratch image (see stark-build/docker/Dockerfile)
## will be used. If a custom Dockerfile is needed, a Dockerfile
## can be added (i.e 'cmd/mybinary/Dockerfile'). Then, the provided
## Dockerfile will be used instead

## Docker Module Variables

## List of images the will be built or published. It defaults
## to cmd/ directory content.
DOCKER_IMAGES ?= $(shell ls ./cmd/ 2> /dev/null)

# Deprecation notice for DOCKER_BASE_IMAGE
ifdef DOCKER_BASE_IMAGE
$(info [Stark Build] !!! Setting DOCKER_BASE_IMAGE is deprecated. Please set DOCKER_IMAGE_PREFIX instead.)
endif

## Name of the project. This will compose the image's name like
## 'DOCKER_BASE_IMAGE/CMD:VERSION'. It defaults to the projets
## directory name.
DOCKER_BASE_IMAGE ?= $(GO_PROJECT)

## Prefix of the image. This will be used to make the fullname of the
## image locally as <DOCKER_IMAGE_PREFIX>/<CMD>:<VERSION>
## and when publishing as <DOCKER_REMOTE>/<DOCKER_IMAGE_PREFIX>/<CMD>:<VERSION>
## For compatibility it defaults to DOCKER_BASE_IMAGE, but it really should be
## explicitly set.
DOCKER_IMAGE_PREFIX ?= $(DOCKER_BASE_IMAGE)

# Sets DOCKER_REMOTE ensuring backward compatibility.
ifdef GCR_BASE_URL
$(info [Stark Build] !!! Setting GCR_BASE_URL is deprecated. Please set DOCKER_REMOTE instead.)
DOCKER_REMOTE ?= $(GCR_BASE_URL)
else
ifdef GCR_PROJECT
$(info [Stark Build] !!! Setting GCR_PROJECT is deprecated. Please set DOCKER_REMOTE instead.)
DOCKER_REMOTE ?= gcr.io/$(GCR_PROJECT)
else
## Prefix of the image when publishing to a remote repository. The full name of the image
## is <DOCKER_REMOTE>/<DOCKER_IMAGE_PREFIX>/<CMD>:<VERSION>.
DOCKER_REMOTE ?=
endif
endif

## Google's registry prefix that will be pre-appended at the
## image name like '<GCR_BASE_URL>/<DOCKER_BASE_IMAGE>/<CMD>:<VERSION>'.
## Defaults to 'gcr.io/<GCR_PROJECT>'. See GCR_PROJECT.
## Deprecated: Use DOCKER_IMAGE_PREFIX instead
GCR_BASE_URL ?=

## Is the project id for the google's container registry. See DOCKER_BASE_IMAGE
## documentation.
## Deprecated: Use DOCKER_IMAGE_PREFIX instead
GCR_PROJECT ?=


$(info [Stark Build] Initializing docker module...)
$(info [Stark Build]   DOCKER_IMAGES = $(DOCKER_IMAGES))
$(info [Stark Build]   DOCKER_IMAGE_PREFIX = $(DOCKER_IMAGE_PREFIX))
$(info [Stark Build]   DOCKER_REMOTE = $(DOCKER_REMOTE))
$(info [Stark Build]   DOCKER_BASE_IMAGE [Deprecated] = $(DOCKER_BASE_IMAGE))
$(info [Stark Build]   GCR_PROJECT [Deprecated] = $(GCR_PROJECT))
$(info [Stark Build]   GCR_BASE_URL [Deprecated] = $(GCR_BASE_URL))

##
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
docker-publish-latest-%: require-VERSION require-DOCKER_IMAGE_PREFIX require-DOCKER_REMOTE
	$(eval IMAGE = $(@:docker-publish-latest-%=$(DOCKER_IMAGE_PREFIX)/%))
	$(eval LOCAL_TAG = $(IMAGE):$(VERSION))
	$(eval REMOTE_TAG = $(DOCKER_REMOTE)/$(IMAGE):latest)
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

## Publishes the generated images into Google's Registry using version as tag.
docker-publish-version-%: require-VERSION require-DOCKER_IMAGE_PREFIX require-DOCKER_REMOTE
	$(eval IMAGE = $(@:docker-publish-version-%=$(DOCKER_IMAGE_PREFIX)/%))
	$(eval LOCAL_TAG = $(IMAGE):$(VERSION))
	$(eval REMOTE_TAG = $(DOCKER_REMOTE)/$(LOCAL_TAG))
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

## Removes all local images matching the same base name.
.PHONY: docker-clean
docker-clean:
	docker images -a | grep $(DOCKER_IMAGE_PREFIX) | awk '{print $$3}' | xargs --no-run-if-empty docker rmi

$(info [Stark Build] Docker module initialized.)
