# Run [ferdi]() in a contaainer
#
# docker run -it \
#   -v /etc/localtime:/etc/localtime:ro \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -e DISPLAY=unix$DISPLAY \
#   --device /dev/snd \
#   --device /dev/dri \
#   -v "${HOME}/.config/Ferdi:/root/.config/Ferdi" \
#   --ipc="host" \
#   --name ferdi \
#   frenchbeard/ferdi

FROM ubuntu:20.04

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV FREDI_USER ferdi

# Run behind apt cacher, to prevent bandwith and time waste, using sameersbn's
# docker run --name apt-cacher-ng --init -it --rm \
# --publish 3142:3142 \
# --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng \
# sameersbn/apt-cacher-ng:3.3-20200524 -h
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
    && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    locales \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

RUN useradd -m ${FREDI_USER}

# Runtime dependencies (according to .deb package)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libatspi2.0-0 \
    libuuid1 \
    libappindicator3-1 \
    libsecret-1-0 \
    && rm -rf /var/lib/apt/lists/*

ENV VERSION 5.6.0-beta.5

RUN curl -sSLO https://github.com/getferdi/ferdi/releases/download/v${VERSION}/ferdi_${VERSION}_amd64.deb \
    && dpkg -i ferdi_${VERSION}_amd64.deb \
    && rm -f ferdi_${VERSION}_amd64.deb

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    libx11-xcb1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    libxcb-dri3-0 \
    libdrm2 \
    libgbm1 \
    && rm -rf /var/lib/apt/lists/*

USER ${FREDI_USER}
WORKDIR /home/${FREDI_USER}

CMD ["/opt/Ferdi/ferdi", "--no-sandbox" ]

