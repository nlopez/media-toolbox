TAG := $(shell git log -1 --pretty=%h)
UID := 1001
GID := 1001
IMAGE := nlopez/media-toolbox
YTARCHIVE_VERSION := 0.5.0
YT_DLP_VERSION := 2025.08.20
BGUTIL_YTDLP_POT_PROVIDER_VERSION := 1.2.2
BUILDPLATFORM := linux/amd64

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
	@docker run -it $(IMAGE):$(TAG)
