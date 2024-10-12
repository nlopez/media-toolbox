TAG := $(shell git log -1 --pretty=%h)

build:
	@docker build --build-arg UID=1001 --build-arg GID=1001 -t nlopez/media-toolbox:$(TAG) .

build-no-cache:
	@docker build --no-cache --build-arg UID=1001 --build-arg GID=1001 -t nlopez/media-toolbox:$(TAG) .

push: build
	@docker push nlopez/media-toolbox:$(TAG)

run: build
	@docker run -it nlopez/media-toolbox
