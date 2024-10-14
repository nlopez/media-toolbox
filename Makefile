TAG := $(shell git log -1 --pretty=%h)
UID := 1001
GID := 1001
IMAGE := nlopez/media-toolbox

build:
	@docker build --build-arg UID=$(UID) --build-arg GID=$(GID) -t $(IMAGE):$(TAG) .

build-no-cache:
	@docker build --no-cache --build-arg UID=$(UID) --build-arg GID=$(GID) -t $(IMAGE):$(TAG) .

push: build
	@docker push $(IMAGE):$(TAG)

run: build
	@docker run -it $(IMAGE)
