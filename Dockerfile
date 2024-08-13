FROM ubuntu AS build
ENV DEBIAN_FRONTEND noninteractive
# Add yt-dlp repository
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:tomtomtom/yt-dlp
# Install packages
RUN apt-get update
RUN apt-get install -y screen vim rclone rsync ffmpeg bash aria2 yt-dlp less bwm-ng htop
# Clean up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

FROM ubuntu
ARG UID=1000
ARG GID=1000
COPY --from=build / /
ENV SHELL /bin/bash
ENTRYPOINT bash --login
RUN groupadd -g "${GID}" user \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" user
USER user
