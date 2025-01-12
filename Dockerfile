# escape=`
FROM ubuntu:latest AS stage1
ARG UID=1000
ARG GID=1000
RUN groupadd -g "${GID}" user `
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" user

FROM ubuntu:latest AS stage2
COPY --link --from=stage1 / /
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends `
  aria2 `
  bash `
  bash-completion `
  bc `
  bwm-ng `
  curl `
  ffmpeg `
  git `
  htop `
  iotop `
  jq `
  less `
  locales `
  mediainfo `
  mkvtoolnix `
  ncdu `
  pipx `
  python3-pip `
  python3-venv `
  rclone `
  ripgrep `
  rsync `
  screen `
  unzip `
  vim-tiny `
  wget `
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 `
  && apt-get clean `
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM ubuntu:latest AS stage3
COPY --link --from=stage2 / /
USER user
WORKDIR /home/user
RUN pipx install tubeup streamlink yt-dlp[default]==2024.12.23
# RUN pipx inject yt-dlp bgutil-ytdlp-pot-provider

FROM ubuntu:latest AS stage4
COPY --link --from=stage3 / /
RUN wget -O /tmp/ytarchive.zip https://github.com/Kethsar/ytarchive/releases/download/v0.5.0/ytarchive_linux_amd64.zip && `
  unzip /tmp/ytarchive.zip -d /usr/local/bin && `
  rm /tmp/ytarchive.zip && `
  chmod +x /usr/local/bin/ytarchive

FROM ubuntu:latest AS stage5
COPY --link --from=stage4 / /
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && `
  apt-get install -y nodejs && `
  npm install --global twspace-crawler

FROM ubuntu:latest AS stage6
COPY --link --from=stage5 / /
ARG UID=1000
ARG GID=1000
COPY --link --chown=${UID}:${GID} rootfs/ /
USER user
ENV TERM=xterm-256color
ENV SHELL=/bin/bash
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "trap : TERM INT; sleep infinity & wait"]
