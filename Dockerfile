FROM ubuntu:latest AS build
ENV DEBIAN_FRONTEND=noninteractive
# Add yt-dlp repository
RUN apt-get update && \
  apt-get install -y --no-install-recommends software-properties-common && \
  add-apt-repository ppa:tomtomtom/yt-dlp -y && \
  apt-get update --fix-missing
# Install packages
ENV LANG=en_US.UTF-8
RUN apt-get install -y --no-install-recommends \
  aria2 \
  bash \
  bwm-ng \
  curl \
  ffmpeg \
  git \
  htop \
  iotop \
  jq \
  less \
  locales \
  mediainfo \
  ncdu \
  pipx \
  python3-venv \
  rclone \
  ripgrep \
  rsync \
  screen \
  vim \
  wget \
  yt-dlp \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && apt-get clean \
  &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM ubuntu:latest
ARG UID=1000
ARG GID=1000

COPY --from=build / /
RUN groupadd -g "${GID}" user \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" user
COPY --chown=${UID}:${GID} rootfs/ /

RUN pipx install tubeup streamlink --include-deps
ENV TERM=xterm-256color
ENV SHELL=/bin/bash
USER user
WORKDIR /home/user
ENTRYPOINT ["bash", "--login", "-c", "screen -D -RR" ]
