FROM ubuntu:latest AS stage1
ARG UID=1000
ARG GID=1000
RUN groupadd -g "${GID}" media \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" media

FROM ubuntu:latest AS stage2
COPY --link --from=stage1 / /
ARG S6_OVERLAY_VERSION=3.2.0.2
ENV DEBIAN_FRONTEND=noninteractive
# Add yt-dlp repository
# Install packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
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
  mkvtoolnix \
  ncdu \
  pipx \
  python3-venv \
  rclone \
  ripgrep \
  rsync \
  screen \
  tree \
  vim-tiny \
  wget \
  xz-utils \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && apt-get clean \
  &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

FROM ubuntu:latest AS stage3
COPY --link --from=stage2 / /
USER media
RUN pipx install tubeup streamlink yt-dlp
RUN pipx inject yt-dlp https://github.com/coletdjnz/yt-dlp-youtube-oauth2/archive/refs/heads/master.zip
RUN pipx inject yt-dlp bgutil-ytdlp-pot-provider

FROM ubuntu:latest AS stage4
ARG UID=1000
ARG GID=1000
COPY --link --from=stage3 / /
COPY --chown=${UID}:${GID} rootfs/ /
ENTRYPOINT ["/init"]
CMD ["/bin/bash"]
