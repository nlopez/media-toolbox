build:
	@docker build --build-arg UID=1001 --build-arg GID=1001 -t nlopez/media-toolbox .

build-no-cache:
	@docker build --no-cache --build-arg UID=1001 --build-arg GID=1001 -t nlopez/media-toolbox .

push: build
	@docker push nlopez/media-toolbox

run: build
	@docker run -it nlopez/media-toolbox
