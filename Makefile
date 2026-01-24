# https://pypi.org/project/yt-dlp/#history
YT_DLP_VERSION := 2026.1.19.233146.dev0
# https://github.com/Brainicism/bgutil-ytdlp-pot-provider
BGUTIL_YTDLP_POT_PROVIDER_VERSION := 1.2.2
# https://github.com/Kethsar/ytarchive
YTARCHIVE_VERSION := 0.5.0

UID := 1001
GID := 1001
IMAGE := nlopez/media-toolbox
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
		-t $(IMAGE):$(TAG) .

build-no-cache:
	@docker build --no-cache \
		--platform $(BUILDPLATFORM) \
		--build-arg YTARCHIVE_VERSION=$(YTARCHIVE_VERSION) \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg BGUTIL_YTDLP_POT_PROVIDER_VERSION=$(BGUTIL_YTDLP_POT_PROVIDER_VERSION) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		-t $(IMAGE):$(TAG) .

push: build
	@docker push $(IMAGE):$(TAG)

run: build
	@docker run -it --entrypoint /bin/bash $(IMAGE):$(TAG)
