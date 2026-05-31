# https://pypi.org/project/yt-dlp/#history
YT_DLP_VERSION := 2026.5.25.234532.dev0
# https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases
BGUTIL_YTDLP_POT_PROVIDER_VERSION := 1.3.1
# https://github.com/Kethsar/ytarchive/releases
YTARCHIVE_VERSION := 0.5.0

UID := 1001
GID := 1001
IMAGE := nlopez/media-toolbox
GHCR_IMAGE := ghcr.io/nlopez/media-toolbox
BUILDPLATFORM := linux/amd64
TAG := ${YT_DLP_VERSION}-$(shell git log -1 --pretty=%h)

tag:
	@echo $(TAG)

build:
	@docker build \
		--platform $(BUILDPLATFORM) \
		--build-arg YTARCHIVE_VERSION=$(YTARCHIVE_VERSION) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		-t $(IMAGE):$(TAG) \
		-t $(GHCR_IMAGE):$(TAG) .

build-no-cache:
	@docker build --no-cache \
		--platform $(BUILDPLATFORM) \
		--build-arg YTARCHIVE_VERSION=$(YTARCHIVE_VERSION) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		-t $(IMAGE):$(TAG) \
		-t $(GHCR_IMAGE):$(TAG) .

push: build
	@docker push $(IMAGE):$(TAG)
	@docker push $(GHCR_IMAGE):$(TAG)

run: build
	@docker run -it --entrypoint /bin/bash $(IMAGE):$(TAG)
