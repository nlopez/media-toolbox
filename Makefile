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

# Pushes with skopeo (needs `skopeo` and registry logins): `docker push` of a docker-loaded
# Nix image sends the layers uncompressed, while skopeo gzips them.
push: build
	@./result > image.tar
	@skopeo copy --retry-times 3 docker-archive:image.tar docker://docker.io/$(IMAGE):$(TAG)
	@skopeo copy --retry-times 3 docker://docker.io/$(IMAGE):$(TAG) docker://docker.io/$(IMAGE):$(TAG)-$(SHA)
	@skopeo copy --retry-times 3 docker://docker.io/$(IMAGE):$(TAG) docker://docker.io/$(IMAGE):$(SHA)
	@for t in $(TAG) $(TAG)-$(SHA) $(SHA); do \
		skopeo copy --retry-times 3 docker://docker.io/$(IMAGE):$(TAG) docker://$(GHCR_IMAGE):$$t; \
	done

run: build
	@docker run -it --entrypoint /bin/bash $(IMAGE):$(TAG)

.PHONY: tag build push run
