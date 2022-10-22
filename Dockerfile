FROM nextcloud:stable-apache

# Dependencies for SVG support
RUN apt-get update ; \
    apt-get install -y libmagickcore-6.q16-6-extra

# Increase memory limits
RUN echo memory_limit=1024M > /usr/local/etc/php/conf.d/zzz-memory-limit.ini
