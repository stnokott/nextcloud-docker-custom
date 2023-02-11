FROM nextcloud:stable-apache

# Dependencies for additional preview generation formats
# (see https://github.com/pulsejet/memories/wiki/File-Type-Support)
RUN apt-get update ; \
    apt-get install -y libmagickcore-6.q16-6-extra ffmpeg

# Increase memory limits
RUN echo memory_limit=2048M > /usr/local/etc/php/conf.d/zzz-memory-limit.ini
