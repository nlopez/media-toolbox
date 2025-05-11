# syntax=docker/dockerfile:1
# escape=`
FROM lscr.io/linuxserver/baseimage-ubuntu:noble-3630948c-ls36 AS stage1
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
  file `
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
  python-is-python3 `
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

# ytarchive
ARG YTARCHIVE_VERSION
RUN wget -O /tmp/ytarchive.zip https://github.com/Kethsar/ytarchive/releases/download/v${YTARCHIVE_VERSION}/ytarchive_linux_amd64.zip && `
  unzip /tmp/ytarchive.zip -d /usr/local/bin && `
  rm /tmp/ytarchive.zip && `
  chmod +x /usr/local/bin/ytarchive

# twspace-crawler
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && `
  apt-get install -y nodejs && `
  npm install --global yarn twspace-crawler

ARG YT_DLP_VERSION
ARG BGUTIL_YTDLP_POT_PROVIDER_VERSION
ENV HOME=/home/abc
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN pipx install tubeup streamlink yt-dlp[default]==$YT_DLP_VERSION
RUN pipx inject yt-dlp bgutil-ytdlp-pot-provider==$BGUTIL_YTDLP_POT_PROVIDER_VERSION
RUN git clone --single-branch --branch $BGUTIL_YTDLP_POT_PROVIDER_VERSION https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git && `
  cd bgutil-ytdlp-pot-provider/server/ && `
  yarn install --frozen-lockfile && `
  npx tsc
COPY --link rootfs/ /
WORKDIR $HOME
RUN chsh -s /bin/bash abc
RUN chsh -s /bin/bash root
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && `
  ~/.fzf/install --no-completion --key-bindings --update-rc
RUN git clone https://github.com/rockandska/fzf-obc ~/.local/opt/fzf-obc && `
  /bin/sh -c 'echo "source ~/.local/opt/fzf-obc/bin/fzf-obc.bash" >> ~/.bashrc'
CMD ["/usr/bin/execlineb", "-P", "-c", "emptyenv export HOME /home/abc s6-setuidgid abc /bin/bash"]
