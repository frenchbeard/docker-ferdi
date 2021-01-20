# Largely inspired from sameersbn/docker-gitlab's Makefile
# Requires running the following command before running the container
# ```
# $ xhost +local:
# ```
# This allows "non-network local connections, IE, through the X11 socket
# mounted in the container
NAME = $(USER)/ferdi
VERSION = 5.6.0-beta.5

.PHONY: all build test tag_latest release

all: build

help:
	@echo Usage :
	@echo ----
	@echo make build        - build the ferdi image
	@echo make tag_latest   - tag the latest build \"latest\"
	@echo make release      - release the latest build on docker hub
	@echo make quickstart   - start ferdi with current ${USER}\'s profile
	@echo make stop         - stop ferdi
	@echo make logs         - view logs
	@echo make purge        - stop and remove the container

build:
	docker build -t $(NAME):$(VERSION) --rm .

build_nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: build tag_latest
	docker push $(NAME):$(VERSION)

quickstart:
	@echo Starting ferdi container...
	@echo docker run --rm -d\
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		-v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi" \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		--ipc="host" \
		--name ferdi-demo \
		$(NAME):$(VERSION)
	docker run --rm -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		-v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi" \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		--ipc="host" \
		--name ferdi-demo \
		$(NAME):$(VERSION)

shell:
	@echo "Starting ferdi container..."
	@echo docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi" \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=unix${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		--ipc="host" \
		--name ferdi-demo \
		$(NAME):$(VERSION) bash
	docker run -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		-v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi" \
		--ipc="host" \
		--name ferdi-demo \
		$(NAME):$(VERSION) bash


stop:
	@echo "Stopping ferdi..."
	@docker stop ferdi-demo

purge: stop
	@echo "Removing stopped containers..."
	@docker rm -v ferdi-demo

logs:
	@docker logs -f ferdi-demo
