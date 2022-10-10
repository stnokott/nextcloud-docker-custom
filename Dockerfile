FROM nextcloud/stable-apache:latest

RUN apt-get update && apt-get install -y libmagickcore-6.q16-6-extra
