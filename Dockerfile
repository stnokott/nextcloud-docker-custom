FROM nextcloud:stable-apache

# libimage-exiftool-perl for https://github.com/pulsejet/memories
RUN apt-get update && apt-get install -y libmagickcore-6.q16-6-extra libimage-exiftool-perl
