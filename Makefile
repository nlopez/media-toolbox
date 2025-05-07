TAG := $(shell git log -1 --pretty=%h)
UID := 1001
GID := 1001
IMAGE := nlopez/media-toolbox
YTARCHIVE_VERSION := 0.5.0
YT_DLP_GET_POT_VERSION := 0.3.0
YT_DLP_VERSION := 2025.04.30
BGUTIL_YTDLP_POT_PROVIDER_VERSION := 0.7.4

build:
	@docker build \
		--build-arg YTARCHIVE_VERSION=$(YTARCHIVE_VERSION) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg YT_DLP_GET_POT_VERSION=$(YT_DLP_GET_POT_VERSION) \
		-t $(IMAGE):$(TAG) .

build-no-cache:
	@docker build \
		--no-cache \
		--build-arg YTARCHIVE_VERSION=$(YTARCHIVE_VERSION) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg YT_DLP_GET_POT_VERSION=$(YT_DLP_GET_POT_VERSION) \
		-t $(IMAGE):$(TAG) .

push: build
	@docker push $(IMAGE):$(TAG)

run: build
	docker run -e PUID=1001 -e PGID=1001 -e TERM=${TERM} -it $(IMAGE):$(TAG) /bin/bash
