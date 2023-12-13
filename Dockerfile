FROM alpine
RUN apk add --no-cache yt-dlp
RUN apk add --no-cache screen vim rclone rsync ffmpeg
