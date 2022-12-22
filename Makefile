#
# MIT License
# Copyright (c) 2022 Darek Bobak
#
# https://github.com/dbobak/TiddlyWiki-Docker/
# based on https://gitlab.com/nicolaw/tiddlywiki
#

.PHONY: build push
.DEFAULT_GOAL := build

TW_VERSION = 5.2.5
BASE_IMAGE = node:17.9-alpine3.15
REPOSITORY = dbobak/tiddlywiki-docker
USER       = node

IMAGE_TAGS = $(REPOSITORY):$(TW_VERSION) \
	           $(REPOSITORY):$(TW_VERSION)-$(subst /,,$(subst :,,$(BASE_IMAGE))) \
	           $(REPOSITORY):latest

MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

build:
	DOCKER_BUILDKIT=1 docker $@ \
	  --no-cache \
	  --build-arg TW_VERSION=$(TW_VERSION) \
	  --build-arg BASE_IMAGE=$(BASE_IMAGE) \
	  --build-arg USER=$(USER) \
	  -f Dockerfile \
	  $(addprefix -t ,$(IMAGE_TAGS)) \
	  $(MAKEFILE_DIR)

push:
	for t in $(IMAGE_TAGS) ; do docker $@ $$t ; done
