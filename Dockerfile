FROM ubuntu AS build
ENV DEBIAN_FRONTEND=noninteractive
# Add yt-dlp repository
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:tomtomtom/yt-dlp
# Install packages
RUN apt-get update --fix-missing
ENV LANG=en_US.UTF-8
RUN apt-get install -y \
  aria2 \
  bash \
  bwm-ng \
  curl \
  ffmpeg \
  git \
  htop \
  jq \
  less \
  locales \
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
  && sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

# Clean up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

FROM ubuntu
ARG UID=1000
ARG GID=1000

COPY --from=build / /
RUN groupadd -g "${GID}" user \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" user
COPY --chown=${UID}:${GID} rootfs/ /

RUN pipx install tubeup --include-deps
ENV TERM=xterm-256color
ENV SHELL=/bin/bash
USER user
WORKDIR /home/user
ENTRYPOINT bash --login -c "screen -D -RR"
