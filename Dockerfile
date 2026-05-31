# escape=`

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

# Stage 4: uv binary from official distroless image
FROM ghcr.io/astral-sh/uv:0.11.17 AS uv-dist

# Stage 5: Python tools
FROM ubuntu:24.04 AS stage5
COPY --link --from=uv-dist /uv /uvx /bin/
ARG YT_DLP_VERSION
ARG BGUTIL_YTDLP_POT_PROVIDER_VERSION
ENV UV_COMPILE_BYTECODE=1
ENV UV_TOOL_BIN_DIR=/usr/local/bin
RUN --mount=type=cache,target=/root/.cache/uv \
  uv tool install --force --no-cache-dir --with bgutil-ytdlp-pot-provider==$BGUTIL_YTDLP_POT_PROVIDER_VERSION tubeup streamlink yt-dlp[default,curl-cffi]==$YT_DLP_VERSION

# Stage 6: Final user setup
FROM ubuntu:24.04 AS stage6
COPY --link --from=stage5 / /
ARG UID=1000
ARG GID=1000
COPY --link --chown=${UID}:${GID} rootfs/ /
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
