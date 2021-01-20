# Ferdi running in a docker container

Packages ferdi 5.6.0-beta.5 in a docker container, to be run on your desktop, but still isolated.

## TL;DR

Requires `xhost` (and `docker`, obviously) installed.

```shell
# Retrieve and build container
git clone https://github.com/frenchbeard/docker-fredi
cd docker-ferdi
make

# Prepare required folder, if never run
mkdir -p ~/.config/Ferdi
# Allow local non-network connection to X server
xhost +local:

# Run it using your existing profile
```

## Prerequisites

In addition to a functioning Docker installed, this container requires you to have `xhost` installed to be properly run. In addition, having `make` available (as you should on most GNU/Linux systems).

Tested on Archlinux, running Docker 20.10.2.

# Usage

The provided `Makefile` helps run it through predefined targets :

```shell
[user@host](docker-ferdi)$ make help
Usage :
----
make build - build the ferdi image
make build_nocache - build the ferdi image, ignoring cache
make init - creates required profile folder, Docker volume as well as authorizes X acces
make logs - view logs
make purge - stop and remove the container
make quickstart - start ferdi with current user's profile
make release - release the latest build on docker hub
make stop - stop ferdi
make shell - start ferdi container, and drops in a shell (without running ferdi)
make tag_latest - tag the latest build "latest"
```

If you prefer, you can simply copy the desired targets content, `alias` it in
your configuration for example.

## Building

The default target builds the image, as `$USER/ferdi:5.6.0-beta.5`.

```shell
[user@host](docker-ferdi)$ make
docker build -t user/ferdi:5.6.0-beta.5 --rm .
Sending build context to Docker daemon  159.8MB
Step 1/14 : FROM ubuntu:20.04
 ---> 2a4d239ad3cc
[...]
Successfully built b89c3ede67db
Successfully tagged user/ferdi:5.6.0-beta.5
```

The cache can also be ignored, using target `build_nocache`.

## Running

Running this container by itself only allows it to display to a non-existent
Xorg server, within the container itself.

The `run` target makes the required changes for current user :
- create `$HOME/.config/Ferdi`, if required
- allow local X server connection through the UNIX socket (through `xhost`)

It then runs the container, with the following options.

```shell
[user@host](docker-ferdi)$ make
Configuring xhost...
xhost +local:
Starting ferdi container...
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
    user/ferdi:5.6.0-beta.5
```

### Options details

TODO

# Troubleshooting

The `logs` target allows you to display running container logs.

```shell
[user@host](docker-ferdi)$ make logs
(ferdi:1): libappindicator-WARNING **: 05:01:49.068: Unable to get the session bus: Unknown or unsupported transport “disabled” for address “disabled:”

(ferdi:1): LIBDBUSMENU-GLIB-WARNING **: 05:01:49.068: Unable to get session bus: Unknown or unsupported transport “disabled” for address “disabled:”
Starting local server on port 45569
info: serving app on http://127.0.0.1:45569
^Cmake: *** [Makefile:103: logs] Interrupt
```

The `shell` target allows you to drop in a shell, without running `ferdi`.

```shell
[user@host](docker-ferdi)$ make shell
make shell
Starting ferdi container...
docker run -it \
	-v /etc/localtime:/etc/localtime:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=:0 \
	--device /dev/snd \
	--device /dev/dri \
	-v "/home/user/.Xauthority:/home/ferdi/.Xauthority" \
	-v  "/home/user/.config/Ferdi:/home/ferdi/.config/Ferdi"  \
	--ipc="host" \
	--name ferdi \
	user/ferdi:5.6.0-beta.5 bash
ferdi@7682c8eb0fb8:~$
```

# Why ?

Because we can, obviously. Still, even though service hibernation helps reduce
memory usage, it doesn’t prevent it from going overboard sometimes. Here you
can simply limit it in your run command, through the
[-m](https://docs.docker.com/config/containers/resource_constraints/) option.

# Credits

- Inspired by [jessfrazz/dockerfiles](https://github.com/jessfrazz/dockerfiles) for the main parts.
- The [app](https://github.com/getferdi/ferdi) itself, off course.
