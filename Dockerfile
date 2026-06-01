# Stage 1: Create non-root user
FROM ubuntu:24.04 AS stage1
ARG UID=1000
ARG GID=1000
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN groupadd -g "${GID}" user \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" user

# Stage 2: Install system packages
FROM ubuntu:24.04 AS stage2
COPY --link --from=stage1 / /
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
  aria2 \
  atomicparsley \
  bash \
  bash-completion \
  bc \
  bwm-ng \
  ca-certificates \
  curl \
  fd-find \
  ffmpeg \
  file \
  git \
  htop \
  iotop \
  jq \
  kid3-cli \
  less \
  locales \
  mediainfo \
  mktorrent \
  mkvtoolnix \
  ncdu \
  optipng \
  pngquant \
  python3 \
  python3-pip \
  python-is-python3 \
  rclone \
  ripgrep \
  rsync \
  screen \
  tmux \
  unzip \
  vim-tiny \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

# Stage 3: Node.js and frontend tools
FROM ubuntu:24.04 AS stage3
COPY --link --from=stage2 / /
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y nodejs \
  && npm install --global yarn twspace-crawler

# Stage 4: Python tools via uv
FROM ubuntu:24.04 AS stage4
COPY --link --from=stage3 / /
ARG YT_DLP_VERSION
ARG BGUTIL_YTDLP_POT_PROVIDER_VERSION
ENV UV_COMPILE_BYTECODE=1
ENV UV_TOOL_BIN_DIR=/usr/local/bin
RUN python3 -m pip install uv --break-system-packages
RUN --mount=type=cache,target=/root/.cache/uv \
  uv tool install --force --no-cache-dir --with bgutil-ytdlp-pot-provider==$BGUTIL_YTDLP_POT_PROVIDER_VERSION yt-dlp[default,curl-cffi]==$YT_DLP_VERSION \
  && uv tool install --force --no-cache-dir tubeup \
  && uv tool install --force --no-cache-dir streamlink

# Stage 5: Final user setup
FROM ubuntu:24.04 AS stage5
COPY --link --from=stage4 / /
ARG YT_DLP_VERSION
ARG BGUTIL_YTDLP_POT_PROVIDER_VERSION
ARG UID=1000
ARG GID=1000
COPY --link --chown=${UID}:${GID} rootfs/ /
LABEL org.opencontainers.image.description="Media Toolbox: A Docker-based development environment with audio/video/CLI tools for media processing."
USER user
ENV HOME=/home/user
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
WORKDIR $HOME
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
  && ~/.fzf/install --no-completion --key-bindings --update-rc
RUN git clone https://github.com/rockandska/fzf-obc ~/.local/opt/fzf-obc \
  && /bin/sh -c 'echo "source ~/.local/opt/fzf-obc/bin/fzf-obc.bash" >> ~/.bashrc'
ENV DENO_INSTALL=${HOME}/.deno
ENV PATH=${DENO_INSTALL}/bin:${PATH}
RUN curl -fsSL https://deno.land/install.sh | bash -s -- -y
ENV SHELL=/bin/bash
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "trap : TERM INT; sleep infinity & wait"]
