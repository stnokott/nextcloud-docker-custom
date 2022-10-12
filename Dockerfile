FROM nextcloud:stable-apache

RUN apt-get update && apt-get install -y libmagickcore-6.q16-6-extra
