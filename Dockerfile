# Run [ferdi]() in a contaainer
#
#   docker run --rm -d \
#       -v /etc/localtime:/etc/localtime:ro \
#       -v /tmp/.X11-unix:/tmp/.X11-unix \
#       -e DISPLAY=${DISPLAY} \
#       --device /dev/snd \
#       --device /dev/dri \
#       -v "${HOME}/.config/Ferdi:/home/ferdi/.config/Ferdi" \
#       -v "${HOME}/.Xauthority:/home/ferdi/.Xauthority" \
#       --ipc="host" \
#       --name ferdi\
#       ${USER}:5.6.0-beta.5

FROM ubuntu:20.04

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV FERDI_USER ferdi
ENV FERDI_UID 1000

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

RUN useradd -m ${FERDI_USER} \
    && mkdir -p /home/${FERDI_USER}/.config/Ferdi /run/user/${FERDI_UID}/\
    && chown -R ${FERDI_USER} /home/${FERDI_USER}/ /run/user/${FERDI_UID}/

# Runtime dependencies (according to .deb package)
# as well as die-and-retry
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
    libxcb-dri3-0 \
    libdrm2 \
    libgbm1 \
    libx11-xcb1 \
    libasound2 \
    # prevents an error on post-install for ferdi
    desktop-file-utils \
    && rm -rf /var/lib/apt/lists/*

ENV VERSION 5.6.0-beta.5

RUN curl -sSLO https://github.com/getferdi/ferdi/releases/download/v${VERSION}/ferdi_${VERSION}_amd64.deb \
    && dpkg -i ferdi_${VERSION}_amd64.deb \
    && rm -f ferdi_${VERSION}_amd64.deb

USER ${FERDI_USER}
WORKDIR /home/${FERDI_USER}
VOLUME /home/${FERDI_USER}/.config/Ferdi

CMD ["/opt/Ferdi/ferdi", "--no-sandbox" ]

