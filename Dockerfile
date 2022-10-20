FROM nextcloud:stable-apache

# SVG support
RUN apt-get update && apt-get install -y libmagickcore-6.q16-6-extra

# Face Recognition dependencies (https://github.com/matiasdelellis/facerecognition)
RUN apt-get update && apt-get install -y git libopenblas-dev liblapack-dev cmake libx11-dev libbz2-dev && \
  docker-php-ext-install bz2 && \
  git clone https://github.com/davisking/dlib.git && \
  cd dlib/dlib && \
  mkdir build && \
  cd build && \
  cmake -DBUILD_SHARED_LIBS=ON .. && \
  make && \
  make install && \
  cd ../../.. && \
  rm -rf dlib && \
  git clone https://github.com/goodspb/pdlib.git && \
  cd pdlib && \
  phpize && \
  cat configure | sed 's/std=c++11/std=c++14/g' > configure_new && \
  chmod +x configure_new && \
  ./configure_new && \
  make && \
  make install && \
  cd .. && \
  rm -rf pdlib && \
  echo -e '[pdlib]\nextension="pdlib.so"' >> /usr/local/etc/php/php.ini-development && \
  echo -e '[pdlib]\nextension="pdlib.so"' >> /usr/local/etc/php/php.ini-production && \
  echo -e '[pdlib]\nextension="pdlib.so"' >> /usr/local/etc/php/php.ini
 
