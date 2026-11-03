# Versions of yt-dlp and the bgutil plugin live in nix/versions.json
# (bump with scripts/update-versions.sh).
#
# Building the image needs a Linux builder: run on Linux, or enable a remote/Linux
# builder for nix on macOS.
YT_DLP_VERSION := $(shell jq -r .ytDlp.version nix/versions.json)
IMAGE := nlopez/media-toolbox
GHCR_IMAGE := ghcr.io/nlopez/media-toolbox
SYSTEM ?= x86_64-linux
TAG := ${YT_DLP_VERSION}
SHA = $(shell git log -1 --pretty=%h)

tag:
	@echo $(TAG)

# Builds the image and loads it into docker as $(IMAGE):$(TAG), then adds the other tags.
build:
	@nix build .#packages.$(SYSTEM).image --out-link result
	@./result | docker load
	@docker tag $(IMAGE):$(TAG) $(GHCR_IMAGE):$(TAG)
	@docker tag $(IMAGE):$(TAG) $(IMAGE):$(TAG)-$(SHA)
	@docker tag $(IMAGE):$(TAG) $(GHCR_IMAGE):$(TAG)-$(SHA)
	@docker tag $(IMAGE):$(TAG) $(IMAGE):$(SHA)
	@docker tag $(IMAGE):$(TAG) $(GHCR_IMAGE):$(SHA)

push: build
	@docker push $(IMAGE):$(TAG)
	@docker push $(GHCR_IMAGE):$(TAG)
	@docker push $(IMAGE):$(TAG)-$(SHA)
	@docker push $(GHCR_IMAGE):$(TAG)-$(SHA)
	@docker push $(IMAGE):$(SHA)
	@docker push $(GHCR_IMAGE):$(SHA)

run: build
	@docker run -it --entrypoint /bin/bash $(IMAGE):$(TAG)

.PHONY: tag build push run
