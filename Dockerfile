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
  atomicparsley `
  bash `
  bash-completion `
  bc `
  bwm-ng `
  curl `
  fd-find `
  ffmpeg `
  git `
  htop `
  iotop `
  jq `
  kid3-cli `
  less `
  locales `
  mediainfo `
  mkvtoolnix `
  ncdu `
  optipng `
  pipx `
  pngquant `
  python3-pip `
  python3-venv `
  rclone `
  ripgrep `
  rsync `
  screen `
  tmux `
  unzip `
  vim-tiny `
  wget `
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 `
  && apt-get clean `
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM ubuntu:latest AS stage3
ARG YT_DLP_VERSION
ARG YT_DLP_GET_POT_VERSION
ARG BGUTIL_YTDLP_POT_PROVIDER_VERSION
COPY --link --from=stage2 / /
USER user
WORKDIR /home/user
RUN pipx install tubeup streamlink yt-dlp[default]==$YT_DLP_VERSION
RUN pipx inject yt-dlp bgutil-ytdlp-pot-provider==$BGUTIL_YTDLP_POT_PROVIDER_VERSION

FROM ubuntu:latest AS stage4
ARG YTARCHIVE_VERSION
COPY --link --from=stage3 / /
RUN wget -O /tmp/ytarchive.zip https://github.com/Kethsar/ytarchive/releases/download/v${YTARCHIVE_VERSION}/ytarchive_linux_amd64.zip && `
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
ENV HOME=/home/user
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
WORKDIR $HOME
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && `
  ~/.fzf/install --no-completion --key-bindings --update-rc
RUN git clone https://github.com/rockandska/fzf-obc ~/.local/opt/fzf-obc && `
  /bin/sh -c 'echo "source ~/.local/opt/fzf-obc/bin/fzf-obc.bash" >> ~/.bashrc'
ENV SHELL=/bin/bash
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "trap : TERM INT; sleep infinity & wait"]
