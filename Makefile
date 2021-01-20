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
	@echo make build			- build the ferdi image
	@echo make build_nocache	- build the ferdi image, ignoring cache
	@echo make init 			- creates required profile folder, Docker volume as well as authorizes X acces
	@echo make logs				- view logs
	@echo make purge			- stop and remove the container
	@echo make release			- release the latest build on docker hub
	@echo make run				- start ferdi with current user\'s profile
	@echo make shell 			- start ferdi container, and drops in a shell (without running ferdi)
	@echo make stop				- stop ferdi
	@echo make tag_latest		- tag the latest build \"latest\"

build:
	docker build -t $(NAME):$(VERSION) --rm .

build_nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: build tag_latest
	docker push $(NAME):$(VERSION)

run:
	@echo Configuring xhost...
	@xhost +local:
	@echo Starting ferdi container...
	docker run --rm -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		-v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi"  \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		--ipc="host" \
		--name ferdi \
		$(NAME):$(VERSION)


debug:
	@echo Starting ferdi container in the foreground...
	docker run -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /var/run/dbus:/var/run/dbus \
		-e DISPLAY=${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		-v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi" \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		--ipc="host" \
		--name ferdi \
		$(NAME):$(VERSION)

shell:
	@echo "Starting ferdi container..."
	docker run -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=${DISPLAY} \
		--device /dev/snd \
		--device /dev/dri \
		-v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
		-v  "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi"  \
		--ipc="host" \
		--name ferdi \
		$(NAME):$(VERSION) bash

stop:
	@echo "Stopping ferdi..."
	@docker stop ferdi

purge: stop
	@echo "Removing stopped containers..."
	@docker rm -v ferdi

logs:
	@docker logs -f ferdi
