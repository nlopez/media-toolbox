FROM ubuntu:latest AS stage1
ARG UID=1000
ARG GID=1000
ARG MEDIA_USERNAME=media
RUN groupadd -g "${GID}" "${MEDIA_USERNAME}" \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} "${MEDIA_USERNAME}"

FROM ubuntu:latest AS stage2
COPY --link --from=stage1 / /
ARG UID=1000
ARG GID=1000
ENV DEBIAN_FRONTEND=noninteractive
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

FROM ubuntu:latest AS stage3
ARG MEDIA_USERNAME=media
COPY --link --from=stage2 / /
USER "${MEDIA_USERNAME}"
RUN pipx install tubeup streamlink yt-dlp
RUN pipx inject yt-dlp https://github.com/coletdjnz/yt-dlp-youtube-oauth2/archive/refs/heads/master.zip
RUN pipx inject yt-dlp bgutil-ytdlp-pot-provider

FROM ubuntu:latest AS stage4
ARG UID=1000
ARG GID=1000
ARG MEDIA_USERNAME=media
COPY --link --from=stage3 / /
COPY --chown=${UID}:${GID} rootfs/ /
USER "${MEDIA_USERNAME}"
ENV TERM="xterm-256color"
ENV SHELL="/bin/bash"
ENV HOME="/home/${MEDIA_USERNAME}"
WORKDIR /home/${MEDIA_USERNAME}
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "trap : TERM INT; sleep infinity & wait"]
