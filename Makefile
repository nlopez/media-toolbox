TAG := $(shell git log -1 --pretty=%h)
UID := 1001
GID := 1001
IMAGE := nlopez/media-toolbox
YT_DLP_VERSION := 2025.02.19
YTARCHIVE_VERSION := 0.5.0

build:
	@docker build \
		--build-arg YT_DLP_VERSION=$(YT_DLP_VERSION) \
		--build-arg YTARCHIVE_VERSION=$(YTARCHIVE_VERSION) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		-t $(IMAGE):$(TAG) .

build-no-cache:
	@docker build --no-cache --build-arg UID=$(UID) --build-arg GID=$(GID) -t $(IMAGE):$(TAG) .

push: build
	@docker push $(IMAGE):$(TAG)

run: build
	@docker run -it $(IMAGE):$(TAG)
