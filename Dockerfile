#
# Use a temporary image to compile and test the libraries
#
FROM nextcloud:stable-apache as builder

SHELL ["/bin/bash", "-c"]

# Build and install dlib on builder
RUN apt-get update ; \
    apt-get install -y build-essential wget cmake libx11-dev libopenblas-dev liblapack-dev

ARG DLIB_BRANCH=v19.19
RUN wget -c -q https://github.com/davisking/dlib/archive/$DLIB_BRANCH.tar.gz \
    && tar xf $DLIB_BRANCH.tar.gz \
    && mv dlib-* dlib \
    && cd dlib/dlib \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON --config Release .. \
    && make \
    && make install

# Build and install PDLib on builder
ARG PDLIB_BRANCH=master
RUN apt-get install unzip
RUN wget -c -q https://github.com/matiasdelellis/pdlib/archive/$PDLIB_BRANCH.zip \
    && unzip $PDLIB_BRANCH \
    && mv pdlib-* pdlib \
    && cd pdlib \
    && phpize \
    && ./configure \
    && make \
    && make install

# Enable PDlib on builder
RUN echo -e '[pdlib]\nextension="pdlib.so"' >> /usr/local/etc/php/conf.d/pdlib.ini

# Install bzip2 needed to extract models

RUN apt-get install -y libbz2-dev && docker-php-ext-install bz2

# Test PDlib instalation on builder

RUN apt-get install -y git
RUN git clone https://github.com/matiasdelellis/pdlib-min-test-suite.git \
    && cd pdlib-min-test-suite \
    && make

#
# If pass the tests, we are able to create the final image.
#
FROM nextcloud:stable-apache

SHELL ["/bin/bash", "-c"]

# Install dependencies to image

RUN apt-get update ; \
    apt-get install -y libopenblas-base libbz2-dev
    
RUN docker-php-ext-install bz2

# Install dlib and PDlib to image

COPY --from=builder /usr/local/lib/libdlib.so* /usr/local/lib/

# If is necesary take the php extention folder (/usr/local/lib/php/extensions/no-debug-non-zts-20180731) uncommenting the next line
# RUN php -i | grep extension_dir
COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20200930/pdlib.so /usr/local/lib/php/extensions/no-debug-non-zts-20200930/

# Enable PDlib on final image
RUN echo -e '[pdlib]\nextension="pdlib.so"' >> /usr/local/etc/php/conf.d/pdlib.ini

# Increase memory limits
RUN echo memory_limit=4G > /usr/local/etc/php/conf.d/zzz-memory-limit.ini

# Pdlib is already installed now on final image without all build dependencies.
# You could test again if everything is correct, uncommenting the next lines.
#
# RUN apt-get install -y git wget
# RUN git clone https://github.com/matiasdelellis/pdlib-min-test-suite.git \
#    && cd pdlib-min-test-suite \
#    && make

#
# At this point you meet all the dependencies to install the application
# You can skip this step and install the application from the application store
#
#ARG FR_BRANCH=master
#RUN apt-get install -y wget unzip nodejs npm
#RUN wget -c -q -O facerecognition https://github.com/matiasdelellis/facerecognition/archive/$FR_BRANCH.zip \
#  && unzip facerecognition \
#  && mv facerecognition-*  /usr/src/nextcloud/facerecognition \
#  && cd /usr/src/nextcloud/facerecognition \
#  && make
