build:
	@docker build -t nlopez/media-toolbox .

push:
	@docker push nlopez/media-toolbox

run:
	@docker run -it nlopez/media-toolbox
