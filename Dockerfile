FROM almalinux:8.8  AS builder

# FROM centos:centos7
MAINTAINER sunny5156 <sunny5156@qq.com>

# -----------------------------------------------------------------------------
# Try to fix Centos7 docker Dbus 
# -----------------------------------------------------------------------------

#RUN yum clean all && yum swap -y fakesystemd systemd

# -----------------------------------------------------------------------------
# Make src dir
# -----------------------------------------------------------------------------
ENV HOME /vue-msf
ENV SRC_DIR $HOME/src
RUN mkdir -p ${SRC_DIR}


# -----------------------------------------------------------------------------
# Install Development tools {epel-release}
# -----------------------------------------------------------------------------
RUN rpm --import /etc/pki/rpm-gpg/RPM* \
    && curl -s --location https://rpm.nodesource.com/setup_16.x | bash - \
    && yum -y install wget epel-release \
    gcc gcc-c++ cmake zlib zlib-devel  \
    sqlite-devel net-tools python38 \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all

   
# -----------------------------------------------------------------------------
# Change yum repos
# -----------------------------------------------------------------------------
# RUN cd /etc/yum.repos.d \
#    #&& mv CentOS-Base.repo CentOS-Base.repo.bak \
#    && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
#    #&& wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
#    && yum clean all

# -----------------------------------------------------------------------------
# python3 yum error ,change python pip link
# -----------------------------------------------------------------------------
# RUN sed -i "s|failovermethod=priority|#failovermethod=priority|g" /etc/yum.repos.d/nodesource-el8.repo \
#     # grep '#! /usr/bin/python' -rl /usr/libexec/urlgrabber-ext-down | xargs sed -i "s/#! \/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
#     # && grep '#!/usr/bin/python' -rl /usr/bin/yum  | xargs sed -i "s/#!\/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
#     && cd /usr/bin \
#     # && rm -f python pip \
#     && ln -s /usr/bin/python3.8 /usr/bin/python \
#     && ln -s /usr/bin/pip3.8 /usr/bin/pip




# -----------------------------------------------------------------------------
# Devel libraries for delelopment tools like php & nginx ...
# -----------------------------------------------------------------------------
RUN sed -i "s|failovermethod=priority|#failovermethod=priority|g" /etc/yum.repos.d/nodesource-el8.repo \
    && yum -y install \
	lrzsz psmisc lemon \
    tar gzip \
    bzip2 \
    # bzip2-devel \
    unzip zip \
    # file \
    perl \
    # perl-WWW-Curl perl-devel perl-ExtUtils-Embed perl-CPAN  \
    pcre pcre-devel \
    openssh openssh-server \
    sudo \
    vim git git-core \
    expat expat-devel \
    # ca-certificates \
    # m4 \
    gd gd-devel \
    libjpeg libjpeg-devel \
    libpng libpng-devel \
    libevent libevent-devel \
    freetype freetype-devel \
    libtool libtool-ltdl-devel \
    libxml2 libxml2-devel \
    unixODBC unixODBC-devel \
    libxslt libxslt-devel \
    libmcrypt libmcrypt-devel \
    freetds freetds-devel \
    curl-devel gettext-devel \
    openldap openldap-devel \
    libc-client-devel \
    jemalloc jemalloc-devel \
    inotify-tools \
    nodejs apr-util \
    # yum-utils \
    tree \
    iftop htop \
    net-snmp-devel diffutils\
    libzip libzip-devel \
    openssl openssl-devel \
    automake autoconf \
    boost-devel \
    iproute \
    && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all
    
RUN rpm --import /etc/pki/rpm-gpg/RPM* \
    && yum --enablerepo=powertools install -y \
    libyaml libyaml-devel \
    oniguruma oniguruma-devel \
    libmemcached libmemcached-devel \
    libmcrypt libmcrypt-devel \
    libicu libicu-devel 
    # gmp gmp-devel  #大数据 parquet 
    # && find / -name "libicu*" 


# -----------------------------------------------------------------------------
# python3 yum error ,change python pip link Python PIP & Supervisor distribute
# -----------------------------------------------------------------------------
RUN cd /usr/bin \
    # grep '#! /usr/bin/python' -rl /usr/libexec/urlgrabber-ext-down | xargs sed -i "s/#! \/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
    # && grep '#!/usr/bin/python' -rl /usr/bin/yum  | xargs sed -i "s/#!\/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
    # && rm -f python pip \
    && ln -s /usr/bin/python3.8 /usr/bin/python \
    && ln -s /usr/bin/pip3.8 /usr/bin/pip \
    && pip install supervisor==4.2.5


# -----------------------------------------------------------------------------
# Update yarn and Update npm , install apidoc nodemon
# ----------------------------------------------------------------------------- 

RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
    && yum install -y yarn 
    # && npm i npm@latest -g 
    # && npm install apidoc nodemon -g　

# -----------------------------------------------------------------------------
# Configure, timezone/sshd/passwd/networking , Config root , add super
# -----------------------------------------------------------------------------
# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several problems.
RUN ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
	&& echo "root:123456" | chpasswd \
    \
	##&& ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \ 
	##&& ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	##&& ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    # && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
    # && ssh-keygen -t ecdsa -f  /etc/ssh/ssh_host_ecdsa_key \
    # && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
    && ssh-keygen -q -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N '' \ 
	&& ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	&& ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
    \
	&& sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/ssh_config \
    && adduser super \
    && echo "super:123456" | chpasswd \
    && echo "super  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers 


# -----------------------------------------------------------------------------
# Install Nginx
# ----------------------------------------------------------------------------- 
ENV nginxVersion 1.21.5
ENV NGINX_INSTALL_DIR ${HOME}/nginx
RUN cd ${SRC_DIR} \
    && wget -q -O nginx-${nginxVersion}.tar.gz  http://nginx.org/download/nginx-${nginxVersion}.tar.gz \
    && tar zxvf nginx-${nginxVersion}.tar.gz  \
    && cd nginx-${nginxVersion} \
    && ./configure --user=super --group=super --prefix=${NGINX_INSTALL_DIR} --with-http_v2_module --with-http_ssl_module --with-http_sub_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre >/dev/null \
    && make >/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/nginx-*


# -----------------------------------------------------------------------------
# Install openssl  1.1.1n
# ----------------------------------------------------------------------------- 
# ENV opensslversion 1.1.1n
# ADD ./openssl/openssl.spec ${SRC_DIR}/
# RUN cd ${SRC_DIR}\
#     && yum -y install which  perl  perl-WWW-Curl  rpm-build \
#     && wget https://www.openssl.org/source/openssl-${opensslversion}.tar.gz \
#     && mkdir -p ${HOME}/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} \
#     && cp ${SRC_DIR}/openssl.spec ${HOME}/rpmbuild/SPECS/openssl.spec \
#     && cp ./openssl-${opensslversion}.tar.gz ${HOME}/rpmbuild/SOURCES/ \
#     && cd ${HOME}/rpmbuild/SPECS \
#     && rpmbuild -D "version 1.1.1n" --nodebuginfo -ba openssl.spec \
#     && yum remove -y openssl openssl-devel \
#     && rpm -ivvh ${HOME}/rpmbuild/RPMS/x86_64/openssl-${opensslversion}-1.el7.x86_64.rpm --nodeps --force \
#     && rpm -ivvh ${HOME}/rpmbuild/RPMS/x86_64/openssl-devel-${opensslversion}-1.el7.x86_64.rpm --nodeps --force  \
#     && rm -rf ${HOME}/rpmbuild ${SRC_DIR}/openssl* \
#     && yum remove -y rpm-build \
#     && yum clean all
#     # && && echo "/usr/local/openssl/ssl/lib" >> /etc/ld.so.conf

    

# -----------------------------------------------------------------------------
# Install Redis
# -----------------------------------------------------------------------------
ENV redisVersion 6.2.1
ENV REDIS_INSTALL_DIR ${HOME}/redis
RUN cd ${SRC_DIR} \
    && wget -q -O redis-${redisVersion}.tar.gz http://download.redis.io/releases/redis-${redisVersion}.tar.gz \
    && tar xzf redis-${redisVersion}.tar.gz \
    && cd redis-${redisVersion} \
    && make >/dev/null \
    && make PREFIX=$REDIS_INSTALL_DIR install \
    && rm -rf ${SRC_DIR}/redis-*

# -----------------------------------------------------------------------------
# Install ImageMagick
# -----------------------------------------------------------------------------
ENV imageMagickVersion 7.1.1-16
RUN cd ${SRC_DIR} \
    # && wget -q -O ImageMagick.tar.gz https://imagemagick.org/archive/ImageMagick.tar.gz \
    # && wget -q -O ImageMagick.tar.gz https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz \
    && wget -q -O ImageMagick.tar.gz https://codeload.github.com/ImageMagick/ImageMagick/tar.gz/refs/tags/${imageMagickVersion} \
    && tar zxf ImageMagick.tar.gz \
    && rm -rf ImageMagick.tar.gz \
    && ImageMagickPath=`ls | grep ImageMagick-` \
    && cd ${ImageMagickPath} \
    && ./configure >/dev/null \
    && make >/dev/null \
    && make install \
    && rm -rf $SRC_DIR/ImageMagick*

# -----------------------------------------------------------------------------
# Install hiredis
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && wget -q -O hiredis-0.14.0.tar.gz https://github.com/redis/hiredis/archive/v0.14.0.tar.gz \
#     && tar zxvf hiredis-0.14.0.tar.gz \
#     && cd hiredis-0.14.0 \
#     && make >/dev/null \
#     && make install \
#     && echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf \
#     && ldconfig \
#     && rm -rf $SRC_DIR/hiredis-*

# -----------------------------------------------------------------------------
# Install libmemcached using by php-memcached
# -----------------------------------------------------------------------------
# ENV LIB_MEMCACHED_INSTALL_DIR /usr/local/
# RUN cd ${SRC_DIR} \
#     && wget -q -O libmemcached-1.0.18.tar.gz https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz \
#     && tar xzf libmemcached-1.0.18.tar.gz \
#     && cd libmemcached-1.0.18 \
#     && sed -i "s|if (opt_servers == false)|if (!opt_servers)|g" clients/memflush.cc \
#     && ./configure --prefix=$LIB_MEMCACHED_INSTALL_DIR --with-memcached 1>/dev/null \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf ${SRC_DIR}/libmemcached*

# -----------------------------------------------------------------------------
# Install libmcrypt using by php-mcrypt
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && wget -q -O libmcrypt-2.5.7.tar.gz https://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/Production/libmcrypt-2.5.7.tar.gz \
#     && tar xzf libmcrypt-2.5.7.tar.gz \
#     && cd libmcrypt-2.5.7 \
#     && ./configure 1>/dev/null \
#     && make 1>/dev/null \
#     && make install \
#     # && echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf \
#     && echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local.conf \
#     && echo "/usr/local/src/libmcrypt-2.5.7/lib/.libs" >> /etc/ld.so.conf.d/local.conf \
#     && chmod gu+x /etc/ld.so.conf.d/local.conf \
#     && ldconfig -v

# -----------------------------------------------------------------------------
# Install re2c for PHP
# -----------------------------------------------------------------------------
ENV re2cVersion 1.0.3
RUN cd $SRC_DIR \
    && wget -q -O re2c-${re2cVersion}.tar.gz https://github.com/skvadrik/re2c/releases/download/${re2cVersion}/re2c-${re2cVersion}.tar.gz \
    && tar xzf re2c-${re2cVersion}.tar.gz \
    && cd re2c-${re2cVersion} \
    && ./configure >/dev/null \
    && make >/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/re2c*


# -----------------------------------------------------------------------------
# Install Libzip
# ----------------------------------------------------------------------------- 

# RUN cd ${SRC_DIR} \  
#   && yum remove -y libzip libzip-devel \
#   && wget -q -O libzip-1.2.0.tar.gz https://nih.at/libzip/libzip-1.2.0.tar.gz \
#   && tar -zxvf libzip-1.2.0.tar.gz \
#   && cd libzip-1.2.0 \
#   && ./configure \
#   && make \
#   && make install \
#   && export PKG_CONFIG_PATH="/usr/lib64/pkgconfig/" \
#   && rm -rf $SRC_DIR/libzip-1.2.0*

# -----------------------------------------------------------------------------
# Install icu4c magento 
# ----------------------------------------------------------------------------- 
# RUN cd ${SRC_DIR} \
#     #&& yum reinstall libcurl-devel -y \
#     && yum install -y https://rpms.remirepo.net/enterprise/7/remi/x86_64/libicu62-62.2-1.el7.remi.x86_64.rpm \
#     && yum install https://rpms.remirepo.net/enterprise/7/remi/x86_64/libicu62-devel-62.2-1.el7.remi.x86_64.rpm -y \
#     && wget https://github.com/unicode-org/icu/releases/download/release-62-2/icu4c-62_2-src.tgz \
#     && tar xf icu4c-62_2-src.tgz \
#     && cd icu/source \
#     && ./configure --prefix=/usr \
#     && make && make install \
#     && rm -rf $SRC_DIR/icu*

# -----------------------------------------------------------------------------
# Install libsodium  magento
# ----------------------------------------------------------------------------- 
# RUN cd ${SRC_DIR} \
#     && wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz \
#     && tar -zxf libsodium-1.0.18-stable.tar.gz \
#     && cd libsodium-stable \
#     && ./configure --prefix=/usr \
#     && make && make check \
#     && sudo make install \
#     && sudo ldconfig \
#     && rm -rf $SRC_DIR/libsodium*



# -----------------------------------------------------------------------------
# Install cmake 3.19.1
# ----------------------------------------------------------------------------- 
# RUN cd ${SRC_DIR} \
#     && curl -L -o cmake-3.19.1.tar.gz https://github.com/Kitware/CMake/releases/download/v3.19.1/cmake-3.19.1.tar.gz  \
#     && tar -zxf cmake-3.19.1.tar.gz \
#     && cd cmake-3.19.1 \
#     && export OPENSSL_ROOT_DIR=/usr/local/openssl \
#     && export OPENSSL_CRYPTO_LIBRARY=/usr/local/openssl/lib \
#     && export OPENSSL_INCLUDE_DIR=/usr/local/openssl/include \
#     && ./bootstrap \
#     && make \
#     && make install \
#     && ldconfig \
#     && make clean \
#     && rm -rf ${SRC_DIR}/cmake*
#     #&& cmake –-version 


# RUN cd ${SRC_DIR} \
#     # && source scl_source enable devtoolset-10 \
#     # && git clone --depth 1 -b v1.34.x https://github.com/grpc/grpc.git \
#     && git clone --depth 1 -b v1.33.x https://github.com/grpc/grpc.git \
#     && cd grpc \
#     && git submodule update --init  --recursive \
#     && yum install automake libtool -y \
#     && cd third_party/protobuf \
#     && ./autogen.sh \
#     && ./configure \
#     && make -j4 \
#     && make install \
#     && ldconfig \
#     && make clean 

# -----------------------------------------------------------------------------
# Install grpc 
# ----------------------------------------------------------------------------- 
# RUN cd ${SRC_DIR} \ 
#     && git clone --depth 1 -b v1.34.x https://github.com/grpc/grpc.git /usr/local/git/grpc \
#     && cd /usr/local/git/grpc \
#     && git submodule update --init --recursive \
#     && mkdir -p cmake/build \
#     && cd cmake/build \
#     && cmake ../.. \
#     # && make -j4
#     && make
 
# -----------------------------------------------------------------------------
# Install grpc 
# ----------------------------------------------------------------------------- 
# ENV GRPCVERSION 1.34.2
# RUN cd ${SRC_DIR} \ 
#     && git clone --depth 1 -b v1.34.x https://github.com/grpc/grpc.git /usr/local/git/grpc \
#     # && wget -q -O grpc-${GRPCVERSION}.tar.gz  https://github.com/grpc/grpc/archive/refs/tags/v${GRPCVERSION}.tar.gz \
#     # && tar -zxf grpc-${GRPCVERSION}.tar.gz \
#     # && cd grpc-${GRPCVERSION}\
#     && cd /usr/local/git/grpc \
#     && git submodule update --init --recursive >/dev/null \
#     && cd third_party/protobuf \
#     && ./autogen.sh >/dev/null \
#     && ./configure >/dev/null \
#     && make >/dev/null \
#     && make install >/dev/null\
#     && ldconfig \
#     && cd /usr/local/git/grpc \
#     # && git submodule update --init --recursive \
#     && mkdir -p cmake/build \
#     && cd cmake/build \
#     && cmake ../.. -DBUILD_SHARED_LIBS=ON -DgRPC_INSTALL=ON >/dev/null \
#     && make >/dev/null \
#     && make install >/dev/null \
#     && ldconfig 

# -----------------------------------------------------------------------------
# Install PHP oniguruma
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && wget https://github.com/kkos/oniguruma/archive/v6.9.4.tar.gz -O oniguruma-6.9.4.tar.gz \
#     && tar -zxf oniguruma-6.9.4.tar.gz \
#     && cd oniguruma-6.9.4 \
#     && ./autogen.sh && ./configure --prefix=/usr \
#     && make >/dev/null \
#     && make install \
#     && rm -rf oniguruma-*


# -----------------------------------------------------------------------------
# Install PHP
# -----------------------------------------------------------------------------
ENV phpVersion 8.1.18
ENV PHP_INSTALL_DIR ${HOME}/php
RUN cd ${SRC_DIR} \
    && export PKG_CONFIG_PATH="/usr/lib64/pkgconfig" \
    # && export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:"/usr/local/lib/pkgconfig/" \
    && wget -q -O php-${phpVersion}.tar.gz https://www.php.net/distributions/php-${phpVersion}.tar.gz \
    && tar xzf php-${phpVersion}.tar.gz \
    && cd php-${phpVersion} \
    # && make clean \
    && ./configure \
    #    --disable-shared \
    #    --enable-static \
       --prefix=${PHP_INSTALL_DIR} \
    #    --openssldir=/usr \
       --with-config-file-path=${PHP_INSTALL_DIR}/etc \
       --with-config-file-scan-dir=${PHP_INSTALL_DIR}/etc/php.d \
       --sysconfdir=${PHP_INSTALL_DIR}/etc \
       --with-libdir=lib64 \
       --enable-fd-setsize=65536 \
       --enable-mysqlnd \
       --with-zip \
       --enable-exif \
       --enable-ftp \
       --enable-mbstring \
       --enable-mbregex \
       --enable-fpm \
       --enable-bcmath \
       --enable-pcntl \
       --enable-soap \
       --enable-sockets \
       --enable-shmop \
       --enable-sysvmsg \
       --enable-sysvsem \
       --enable-sysvshm \
       --enable-opcache \
       # magento
       --enable-intl \ 
       --with-gettext \
       --with-xsl \
       --with-xmlrpc \
       --with-snmp \
       --with-ldap \
       --enable-mysqlnd \
       --with-mysqli=mysqlnd \
       --with-pdo-mysql=mysqlnd \
       --with-pdo-odbc=unixODBC,/usr \
       --enable-gd \
       --with-webp \
       --with-jpeg \
       --with-zlib-dir \
       --with-freetype \
       --with-zlib \
       --with-bz2 \
       --with-openssl \
    #    --with-openssl-dir \ 
       --with-curl=/usr/bin/curl \
    #    --with-curl  \
       --with-imap \
       --with-imap-ssl \
       --with-kerberos \
       #magento
       --with-icu-dir=/usr/lib/icu/ \ 
       --with-mhash \
       --enable-inline-optimization \
    #    --with-gmp  \  #大数据 parquet
    # && make --quiet prof-gen LIBS="-lssl -lcrypto -llber -lzip" 1>/dev/null \
    && make --quiet prof-gen LIBS="-lssl -lcrypto" 1>/dev/null \
    && make install \
    && rm -rf ${PHP_INSTALL_DIR}/lib/php.ini \
    && cp -f php.ini-development ${PHP_INSTALL_DIR}/lib/php.ini \
    # && cp -rf ${SRC_DIR}/php-${phpVersion}/ext/intl  ${SRC_DIR}/ \  # magento
    # && rm -rf ${SRC_DIR}/php-* \
    && rm -rf ${SRC_DIR}/libmcrypt*

# -----------------------------------------------------------------------------
# Install yaml and PHP yaml extension
# -----------------------------------------------------------------------------
ENV yamlExtVersion 2.2.2
RUN cd ${SRC_DIR} \
    && wget -q -O yaml-${yamlExtVersion}.tgz https://pecl.php.net/get/yaml-${yamlExtVersion}.tgz \
    && tar xzf yaml-${yamlExtVersion}.tgz \
    && cd yaml-${yamlExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-yaml=/usr/local --with-php-config=${PHP_INSTALL_DIR}/bin/php-config >/dev/null \
    && make >/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/yaml-*

RUN cd ${SRC_DIR} \
    && wget http://pear.php.net/go-pear.phar --no-check-certificate\
    && ${PHP_INSTALL_DIR}/bin/php go-pear.phar \
    && rm -rf go-pear.phar 

# -----------------------------------------------------------------------------
# Install PHP Rabbitmq extensions
# -----------------------------------------------------------------------------
ENV rabbitmqcExtVersion 0.13.0
RUN cd ${SRC_DIR} \
	# && wget -q -O rabbitmq-c-${rabbitmqcExtVersion}.tar.gz https://github.com/alanxz/rabbitmq-c/releases/download/v${rabbitmqcExtVersion}/rabbitmq-c-${rabbitmqcExtVersion}.tar.gz \
	&& wget -q -O rabbitmq-c-${rabbitmqcExtVersion}.tar.gz https://github.com/alanxz/rabbitmq-c/archive/refs/tags/v${rabbitmqcExtVersion}.tar.gz \
	&& tar zxf rabbitmq-c-${rabbitmqcExtVersion}.tar.gz \
	&& cd rabbitmq-c-${rabbitmqcExtVersion} \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..\
	# && ./configure --prefix=/usr/local/rabbitmq-c-${rabbitmqcExtVersion} >/dev/null \
    && cmake --build . --target install \
	&& make  >/dev/null \
    && make install 
    # && ldconfig


# -----------------------------------------------------------------------------
# Install PHP amqp extensions
# -----------------------------------------------------------------------------
ENV amqpExtVersion 1.11.0
RUN cd ${SRC_DIR} \
    # && yum install -y librabbitmq-devel \ 
    && wget -q -O amqp-${amqpExtVersion}.tgz https://pecl.php.net/get/amqp-${amqpExtVersion}.tgz\
    && tar zxf amqp-${amqpExtVersion}.tgz \
    && cp -r /usr/local/lib64/* /usr/local/lib \
    # && ldconfig \
    && cd amqp-${amqpExtVersion} \
    # && cp ${SRC_DIR}/rabbitmq-c-${rabbitmqcExtVersion}/librabbitmq/amqp_ssl_socket.h . \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-amqp --with-librabbitmq-dir=/usr/local  1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/amqp-*  ${SRC_DIR}/rabbitmq-c-*

# -----------------------------------------------------------------------------
# Install PHP redis extensions
# -----------------------------------------------------------------------------
ENV redisExtVersion 5.3.7
RUN cd ${SRC_DIR} \
    && wget -q -O redis-${redisExtVersion}.tgz https://pecl.php.net/get/redis-${redisExtVersion}.tgz \
    && tar zxf redis-${redisExtVersion}.tgz \
    && cd redis-${redisExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/redis-*

# -----------------------------------------------------------------------------
# Install PHP imagick extensions
# -----------------------------------------------------------------------------
ENV imagickExtVersion 3.7.0
RUN cd ${SRC_DIR} \
    && wget -q -O imagick-${imagickExtVersion}.tgz https://pecl.php.net/get/imagick-${imagickExtVersion}.tgz \
    && tar zxf imagick-${imagickExtVersion}.tgz \
    && cd imagick-${imagickExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-imagick 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/imagick-*

# -----------------------------------------------------------------------------
# Install PHP xdebug extensions
# -----------------------------------------------------------------------------
#ENV xdebugExtVersion 2.7.0
#RUN cd ${SRC_DIR} \
#    && wget -q -O xdebug-${xdebugExtVersion}.tgz https://pecl.php.net/get/xdebug-${xdebugExtVersion}.tgz \
#    && tar zxf xdebug-${xdebugExtVersion}.tgz \
#    && cd xdebug-${xdebugExtVersion} \
#    && ${PHP_INSTALL_DIR}/bin/phpize \
#    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
#    && make clean \
#    && make 1>/dev/null \
#    && make install \
#    && rm -rf ${SRC_DIR}/xdebug-*

# -----------------------------------------------------------------------------
# Install PHP igbinary extensions
# -----------------------------------------------------------------------------
ENV igbinaryExtVersion 3.2.10
RUN cd ${SRC_DIR} \
    && wget -q -O igbinary-${igbinaryExtVersion}.tgz https://pecl.php.net/get/igbinary-${igbinaryExtVersion}.tgz \
    && tar zxf igbinary-${igbinaryExtVersion}.tgz \
    && cd igbinary-${igbinaryExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/igbinary-*
    
# -----------------------------------------------------------------------------
# Install PHP xlswriter extensions
# -----------------------------------------------------------------------------
ENV xlswriterExtVersion 1.5.2
RUN cd ${SRC_DIR} \
    && wget -q -O xlswriter-${xlswriterExtVersion}.tgz https://pecl.php.net/get/xlswriter-${xlswriterExtVersion}.tgz \
    && tar zxf xlswriter-${xlswriterExtVersion}.tgz \
    && cd xlswriter-${xlswriterExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --enable-reader 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/xlswriter-*


# -----------------------------------------------------------------------------
# Install PHP memcached extensions
# -----------------------------------------------------------------------------
ENV memcachedExtVersion 3.2.0
RUN cd ${SRC_DIR} \
    && mkdir -p /usr/lib/x86_64-linux-gnu/include/libmemcached \
    && ln -s /usr/include/libmemcached/memcached.h /usr/lib/x86_64-linux-gnu/include/libmemcached/memcached.h \
    && wget -q -O memcached-${memcachedExtVersion}.tgz https://pecl.php.net/get/memcached-${memcachedExtVersion}.tgz \
    && tar xzf memcached-${memcachedExtVersion}.tgz \
    && cd memcached-${memcachedExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --enable-memcached --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
       --with-libmemcached-dir="/usr/lib/x86_64-linux-gnu" --disable-memcached-sasl 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/memcached-*

# -----------------------------------------------------------------------------
# Install PHP yac extensions
# -----------------------------------------------------------------------------
ENV yacExtVersion 2.2.0
RUN cd ${SRC_DIR} \
    && wget -q -O yac-${yacExtVersion}.tgz https://pecl.php.net/get/yac-${yacExtVersion}.tgz \
    && tar zxf yac-${yacExtVersion}.tgz\
    && cd yac-${yacExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make 1>/dev/null \
    && make install \
    && rm -rf $SRC_DIR/yac-*



# -----------------------------------------------------------------------------
# Install PHP intl extensions  magento
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && cd intl\
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --prefix=/usr/lib/icu \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf $SRC_DIR/intl-*


# -----------------------------------------------------------------------------
# Install PHP libsodium extensions magento
# -----------------------------------------------------------------------------
ENV libsodiumExtVersion 2.0.23
RUN cd ${SRC_DIR} \
    && yum install -y  libsodium libsodium-devel \
    && wget -q -O libsodium-${libsodiumExtVersion}.tgz https://pecl.php.net/get/libsodium-${libsodiumExtVersion}.tgz \
    && tar zxf libsodium-${libsodiumExtVersion}.tgz\
    && cd libsodium-${libsodiumExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make 1>/dev/null \
    && make install \
    && rm -rf $SRC_DIR/libsodium-*


# -----------------------------------------------------------------------------
# Install PHP swoole extensions
# -----------------------------------------------------------------------------

ENV swooleExtVersion 4.8.12
RUN cd ${SRC_DIR} \
    && ls /usr/local/include/ \
    && wget -q -O swoole-${swooleExtVersion}.tar.gz https://github.com/swoole/swoole-src/archive/v${swooleExtVersion}.tar.gz \
    && tar zxf swoole-${swooleExtVersion}.tar.gz \
    && cd swoole-src-${swooleExtVersion}/ \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    # && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --enable-async-redis --enable-openssl --with-openssl-dir=/usr/local/openssl/ --enable-mysqlnd --enable-swoole-curl  1>/dev/null\
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --enable-async-redis --enable-openssl --with-openssl-dir=/usr/local/openssl/ --enable-mysqlnd  1>/dev/null\
    && make clean 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/swoole*


# -----------------------------------------------------------------------------
# Install PHP inotify extensions
# -----------------------------------------------------------------------------
ENV inotifyExtVersion 3.0.0
RUN cd ${SRC_DIR} \
    && wget -q -O inotify-${inotifyExtVersion}.tgz https://pecl.php.net/get/inotify-${inotifyExtVersion}.tgz \
    && tar zxf inotify-${inotifyExtVersion}.tgz \
    && cd inotify-${inotifyExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/inotify-*

# -----------------------------------------------------------------------------
# Install PHP mongodb extensions
# -----------------------------------------------------------------------------
ENV mongodbExtVersion 1.13.0
RUN cd ${SRC_DIR} \
    # && export PATH=$PATH:/vue-msf/php/bin \/
    # && ln -s /usr/openssl/include/openssl /usr/local/include \
    && wget -q -O mongodb-${mongodbExtVersion}.tgz https://pecl.php.net/get/mongodb-${mongodbExtVersion}.tgz \
    && tar -zxf mongodb-${mongodbExtVersion}.tgz \
    && cd mongodb-${mongodbExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make clean \
    && make \
    && make install 


# COPY --from=rustimage /vue-msf/local /vue-msf/local

# COPY --from=grpc /vue-msf/src/grpc/cmake /vue-msf/local/cmake/
# COPY --from=grpc /vue-msf/src/grpc/third_party/abseil-cpp/absl /vue-msf/local/include/absl
# COPY --from=grpc /vue-msf/src/grpc/third_party/protobuf /vue-msf/local/cmake/build/third_party/protobuf


# -----------------------------------------------------------------------------
# Install cargo
# -----------------------------------------------------------------------------

RUN yum install -y  clang-devel protobuf-compiler \
    # &&  source "/vuem-msf/.cargo/env" \
    && curl https://sh.rustup.rs -sSf |  sh -s -- -y

# -----------------------------------------------------------------------------
# Install PHP skywalking_agent extensions
# -----------------------------------------------------------------------------
ENV skywalkingAgentExtVersion 0.6.0
RUN cd ${SRC_DIR} \
    # && export PATH=$PATH:/vue-msf/php/bin \/
    # && ln -s /usr/openssl/include/openssl /usr/local/include \
    && source "/vue-msf/.cargo/env" \
    && wget -q -O skywalking_agent-${skywalkingAgentExtVersion}.tgz https://pecl.php.net/get/skywalking_agent-${skywalkingAgentExtVersion}.tgz \
    && tar -zxf skywalking_agent-${skywalkingAgentExtVersion}.tgz \
    && cd skywalking_agent-${skywalkingAgentExtVersion} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make clean \
    && make \
    && make install \
    && rm -rf /vue-msf/.rustup 


# -----------------------------------------------------------------------------
# Install PHP SkyAPM-php-sdk extensions
# -----------------------------------------------------------------------------

# RUN cd ${SRC_DIR} \
#     && yum install rust cargo rustfmt -y \
#     && echo "/vue-msf/local/lib" >> /etc/ld.so.conf.d/local.conf \
#     && echo "/vue-msf/local/lib64" >> /etc/ld.so.conf.d/local.conf \
#     && ldconfig \
#     # && git clone --branch v4-c11 https://github.com/SkyAPM/SkyAPM-php-sdk.git ./skywalking \
#     && git clone --branch v5.0.1 https://github.com/SkyAPM/SkyAPM-php-sdk.git ./skywalking \
#     && cd skywalking \
#     && git submodule update --init \
#     && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/vue-msf/local/lib:/vue-msf/local/lib64  \
#     && export PATH=$PATH:/vue-msf/local/bin \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config >/dev/null \
#     && make 1>/dev/null \
#     && make install \
#     && yum remove boost-devel rust cargo rustfmt -y \
#     && rm -rf $SRC_DIR/skywalking* /usr/local/git/grpc /vue-msf/.cargo

# @sunny5156 GRPC 真确版本
# ENV skyapm_version 4.2.0
# RUN cd ${SRC_DIR} \
#     && ls -alh /vue-msf/local \
#     # && yum install -y rust cargo rustfmt \ll
#     && echo "/vue-msf/local/lib" >> /etc/ld.so.conf.d/local.conf \
#     && echo "/vue-msf/local/lib64" >> /etc/ld.so.conf.d/local.conf \
#     && ldconfig \
#     && mkdir -p /vue-msf/local/cmake/build/third_party/protobuf/ /vue-msf/local/cmake/build/third_party/cares/cares/lib/ \
#     && ln -s /vue-msf/local/lib/libprotobuf.a /vue-msf/local/cmake/build/third_party/protobuf/libprotobuf.a \
#     && ln -s /vue-msf/local/lib/libcares.a /vue-msf/local/cmake/build/third_party/cares/cares/lib/libcares.a \
#     && curl -Lo v${skyapm_version}.tar.gz https://github.com/SkyAPM/SkyAPM-php-sdk/archive/v${skyapm_version}.tar.gz \
#     && tar -zxf v${skyapm_version}.tar.gz \
#     && cd SkyAPM-php-sdk-${skyapm_version} \
#     && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/vue-msf/local/lib:/vue-msf/local/lib64 \
#     && export PATH=$PATH:/vue-msf/local/bin \
#     && export PROTOC=/vue-msf/local/bin/protoc \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-grpc="/vue-msf/local" \
#     && make \
#     && make install \
#     && yum remove boost-devel  -y

# @sunny5156 GRPC 真确版本


# -----------------------------------------------------------------------------
# Install PHP FRICC2 extensions
# -----------------------------------------------------------------------------

RUN cd ${SRC_DIR} \
    && git clone https://github.com/hoowa/FRICC2.git \
    && cd ${SRC_DIR}/FRICC2/fricc2load \
    && chmod +x init_key \
    && ./init_key \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make clean \
    && make \
    && make install \
    && cd ${SRC_DIR}/FRICC2/fricc2 \
    && make \
    && mkdir -p /vue-msf/fricc2 \
    && cp fricc2 /vue-msf/fricc2/ 



# -----------------------------------------------------------------------------
# Install snappy 大数据 parquet 
# -----------------------------------------------------------------------------

# RUN cd ${SRC_DIR} \ 
#     && yum install -y snappy \
#     && git clone --recursive --depth=1 https://github.com/kjdev/php-ext-snappy.git \
#     && cd php-ext-snappy \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
#     && make \
#     && make install \
#     && rm -rf php-ext-snappy

# -----------------------------------------------------------------------------
# Install phpunit
# -----------------------------------------------------------------------------
#RUN cd ${SRC_DIR} \
#    && wget -q -O phpunit.phar https://phar.phpunit.de/phpunit.phar \
#    && mv phpunit.phar ${PHP_INSTALL_DIR}/bin/phpunit \
#    && chmod +x ${PHP_INSTALL_DIR}/bin/phpunit

# -----------------------------------------------------------------------------
# Install php composer
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget  https://getcomposer.org/installer | ${PHP_INSTALL_DIR}/bin/php \
    && ${PHP_INSTALL_DIR}/bin/php installer --2 \
    && chmod +x composer.phar \
    && mv composer.phar ${PHP_INSTALL_DIR}/bin/composer \
    && rm -rf installer 

# -----------------------------------------------------------------------------
# Install PhpDocumentor
# -----------------------------------------------------------------------------
#RUN ${PHP_INSTALL_DIR}/bin/pear clear-cache
#RUN ${PHP_INSTALL_DIR}/bin/pear update-channels
#RUN ${PHP_INSTALL_DIR}/bin/pear upgrade
#RUN ${PHP_INSTALL_DIR}/bin/pear install -a PhpDocumentor
#RUN ${PHP_INSTALL_DIR}/bin/pear install  http://pear.phpdoc.org/get/phpDocumentor-2.0.0b6.tgz

#RUN cd ${PHP_INSTALL_DIR} \
#    && bin/php bin/composer self-update \
#    && bin/pear install PHP_CodeSniffer-2.3.4 \
#    && rm -rf /tmp/*

# -----------------------------------------------------------------------------
# Install jq
# -----------------------------------------------------------------------------
ENV jqVersion 1.6
RUN cd ${SRC_DIR} \
    && wget -q -O jq-${jqVersion}.tar.gz https://github.com/stedolan/jq/releases/download/jq-${jqVersion}/jq-${jqVersion}.tar.gz \
    # && wget -q -O jq-${jqVersion}.tar.gz https://github.com/stedolan/jq/archive/jq-${jqVersion}.tar.gz \
    && tar -zxf jq-${jqVersion}.tar.gz \
    # && ls -alh \
    && cd ./jq-${jqVersion} \
    && ./configure --disable-maintainer-mode \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/jq-* 

# -----------------------------------------------------------------------------
# Install Apache ab
# -----------------------------------------------------------------------------
#RUN cd ${HOME} \
#    && yum -y remove httpd \
#    && yum clean all \
#    && mkdir httpd \
#    && cd httpd \
#    && yumdownloader httpd-tools \
#    && rpm2cpio httpd-tools* | cpio -idmv \
#    && mkdir -p ${HOME}/bin  \
#    && mv -f ./usr/bin/ab ${HOME}/bin \
#    && cd ${HOME} && rm -rf ${HOME}/httpd

#RUN echo "swoole.use_shortname = 'Off'" >> /vue-msf/php/etc/php.d/swoole.ini 

# -----------------------------------------------------------------------------
# Update Git and Config git
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && yum -y remove git subversion \
#     && wget -q -O git-2.20.1.tar.gz https://github.com/git/git/archive/v2.20.1.tar.gz \
#     && tar zxf git-2.20.1.tar.gz \
#     && cd git-2.20.1 \
#     && make configure \
#     # && ./configure --without-iconv --prefix=/usr/local/ --with-curl=/usr/bin/curl  --with-openssl=/usr/local/openssl/ \
#     && ./configure --without-iconv --prefix=/usr/local/ --with-curl=/usr/bin/curl  \
#     && make \
#     && make install \
#     && rm -rf $SRC_DIR/git-2* 


# -----------------------------------------------------------------------------
# Install  ffmpeg  x264
# -----------------------------------------------------------------------------

RUN  yum install -y  http://mirrors.ustc.edu.cn/rpmfusion/free/el/rpmfusion-free-release-8.noarch.rpm \
        && yum install -y  --enablerepo=powertools SDL2 \
        && yum install -y ffmpeg x264
# -----------------------------------------------------------------------------
# Install gocronx
# -----------------------------------------------------------------------------
RUN mkdir -p ${HOME}/gocronx/
ADD gocronx ${HOME}/gocronx/ 
RUN chmod a+x -R ${HOME}/gocronx/
    
# -----------------------------------------------------------------------------
# Copy Config   Git-Core  jsawk
# -----------------------------------------------------------------------------
ADD run.sh /
ADD config /vue-msf/
ADD config/.bash_profile /home/super/
ADD config/.bashrc /home/super/
ADD config/.vimrc /home/super/

ADD config/.bash_profile /root/
ADD config/.bashrc /root/
ADD config/.vimrc /root/

# COPY config/motd /etc/motd

ADD rpm/js-1.8.5-31.el8.x86_64.rpm /vue-msf/src/

RUN chmod a+x /run.sh \
    && yum install -y procps /vue-msf/src/js-1.8.5-31.el8.x86_64.rpm \
	&& chmod a+x ${PHP_INSTALL_DIR}/bin/checkstyle \
    && chmod a+x ${PHP_INSTALL_DIR}/bin/mergeCoverReport \
    && ln -s /usr/libexec/git-core/git-remote-http /bin/ \
    && ln -s /usr/libexec/git-core/git-remote-https /bin/ \
    && git config --global user.email "vue-msf@admin.com" \
    && git config --global user.name "vue-msf" \
    && curl -s -L http://github.com/micha/jsawk/raw/master/jsawk > /usr/local/bin/jsawk \
	&& chmod 755 /usr/local/bin/jsawk \
    && rm -rf ${SRC_DIR}/* \
    && yum --enablerepo=powertools install -y \
    libicu libicu-devel \
    && yum clean all


# -----------------------------------------------------------------------------
# Set  Centos limits Profile
# -----------------------------------------------------------------------------

ARG base_image_project
ARG base_image_version

RUN echo -e "# Default limit for number of user's processes to prevent \n\
# accidental fork bombs. \n\
# See rhbz #432903 for reasoning. \n\
* soft nofile 65535 \n\
* hard nofile 65535 \n\
* hard nproc 65535 \n\
* soft nproc 65535 " > /etc/security/limits.d/20-nproc.conf \
    && echo -e 'PATH=$PATH:/vue-msf/php/bin \nPATH=$PATH:/vue-msf/php/sbin \nPATH=$PATH:/vue-msf/nginx/bin/ \nPATH=$PATH:/vue-msf/sbin/ \nPATH=$PATH:/vue-msf/redis/bin \nexport PATH \n' >> /etc/profile \
    && source /etc/profile \
    && export build_time=$(date '+%Y/%m/%d %H:%M:%S') \
    && echo -e "${base_image_project}:${base_image_version}" > /.base_image_version \
    && echo -e "\n\
\033[46;30m  _      __     _____  ______              \033[0m \n\
\033[46;30m | | /| / /__  / / _/ /_  __/__ ___ ___ _  \033[0m \n\
\033[46;30m | |/ |/ / _ \/ / _/   / / / -_) _  /  ' \ \033[0m \n\
\033[46;30m |__/|__/\___/_/_/    /_/  \__/\_,_/_/_/_/ \033[0m \n\n\n\
welcome sfc xi'an wolf team ! \n\
\033[45;30mBASE_IMAGE:\033[0m ${base_image_project}:${base_image_version} \n\
\033[45;30mBUILD_TIME:\033[0m ${build_time}" > /etc/motd

# 压缩合并
FROM almalinux:8.8 

COPY --from=builder / / 

# -----------------------------------------------------------------------------
# clean tmp file
# -----------------------------------------------------------------------------
# RUN rm -rf ${SRC_DIR}/* \
# 	&& rm -rf /tmp/*

EXPOSE 22 80 443 8080 8000
ENTRYPOINT ["/run.sh"]
