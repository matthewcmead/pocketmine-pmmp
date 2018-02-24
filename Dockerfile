FROM ubuntu:xenial

MAINTAINER matthewcmead@gmail.com

RUN apt-get update -y \
&&  apt-get upgrade -y \
&&  apt-get install -y \
      vim \
      sudo \
      wget \
      perl \
      gcc \
      g++ \
      make \
      automake \
      libtool \
      autoconf \
      m4 \
      gcc-multilib \
      git \
&&  apt-get install -y \
      language-pack-en-base \
      software-properties-common \
      python-software-properties \
      libghc-zlib-dev \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*

RUN mkdir /data \
&&  useradd -d /data -s /bin/bash --uid 1000 minecraft \
&&  chown -R minecraft:minecraft /data

USER minecraft
WORKDIR /data

RUN wget -q -O /data/install.sh https://get.pmmp.io \
&&  chmod 755 /data/install.sh \
&&  /data/install.sh -v development \
&&  rm -f /data/install.sh \
&&  mkdir -p /data/worlds \
&&  for x in phpize php-config; do sed -i 's/\/var\/jenkins_home\/workspace\/PHP-7.2-Linux-x86_64\/bin/\/data\/bin/g' /data/bin/php7/bin/$x; done \
&&  sed -i 's/extension_dir=""/extension_dir="\/data\/bin\/php7\/lib\/php\/extensions\/no-debug-zts-20170718"/' /data/bin/php7/bin/php.ini


RUN mkdir /data/dependency-libs \
&&  cd /data/dependency-libs \
&&  git clone https://github.com/pmmp/leveldb-mcpe \
&&  cd leveldb-mcpe \
&&  make \
&&  cd .. \
&&  mkdir -p leveldb-mcpe-final/lib/x86_64-linux-gnu \
&&  mv leveldb-mcpe/out-static/lib* leveldb-mcpe-final/lib/x86_64-linux-gnu \
&&  mv leveldb-mcpe/out-shared/*.so* leveldb-mcpe-final/lib/x86_64-linux-gnu \
&&  mv leveldb-mcpe/include leveldb-mcpe-final \
&&  rm -rf leveldb-mcpe \
&&  mv leveldb-mcpe-final leveldb-mcpe

RUN cd /data/dependency-libs \
&&  git clone https://github.com/reeze/php-leveldb.git \
&&  cd php-leveldb \
&&  /data/bin/php7/bin/phpize \
&&  ./configure --with-php-config=/data/bin/php7/bin/php-config --with-leveldb=/data/dependency-libs/leveldb-mcpe \
&&  make \
&&  make install \
&&  cd .. \
&&  rm -rf php-leveldb \
&&  echo "extension=leveldb.so" >>/data/bin/php7/bin/php.ini

RUN mkdir /data/default_config

COPY default_config/ /data/default_config
COPY entrypoint.sh /data

VOLUME /data/worlds
VOLUME /data/config

ENTRYPOINT [ "/data/entrypoint.sh" ]

EXPOSE 19132
EXPOSE 19132/udp
