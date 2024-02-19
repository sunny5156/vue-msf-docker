FROM centos:7.6.1810
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
    && curl -s --location https://rpm.nodesource.com/setup_12.x | bash - \
    && yum -y install wget epel-release \
    cc gcc gcc-c++ zlib zlib-devel  \
    ncurses-devel sqlite-devel net-tools python3 \
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
RUN grep '#! /usr/bin/python' -rl /usr/libexec/urlgrabber-ext-down | xargs sed -i "s/#! \/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
    && grep '#!/usr/bin/python' -rl /usr/bin/yum  | xargs sed -i "s/#!\/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
    && cd /usr/bin \
    && rm -f python pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip

# -----------------------------------------------------------------------------
# Devel libraries for delelopment tools like php & nginx ...
# -----------------------------------------------------------------------------
RUN yum -y install \
	lrzsz psmisc lemon \
    tar gzip bzip2 bzip2-devel unzip zip file \
    perl perl-WWW-Curl perl-devel perl-ExtUtils-Embed perl-CPAN autoconf \
    pcre pcre-devel openssh-server openssh sudo \
    vim git telnet expat expat-devel \
    ca-certificates m4 \
    gd gd-devel libjpeg libjpeg-devel libpng libpng-devel libevent libevent-devel \
    freetype freetype-devel libtool-tldl libtool-ltdl-devel libxml2 libxml2-devel unixODBC unixODBC-devel libyaml libyaml-devel\
    libxslt libxslt-devel libmcrypt libmcrypt-devel freetds freetds-devel \
    curl-devel gettext-devel \
    openldap openldap-devel libc-client-devel \
    jemalloc jemalloc-devel inotify-tools nodejs apr-util yum-utils tree js\
    oniguruma oniguruma-devel \
    iftop htop \
    which rpm-build libssl-dev \
    openssl openssl-devel \
    && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all
    
RUN rpm --import /etc/pki/rpm-gpg/RPM*

# -----------------------------------------------------------------------------
# Install Python PIP & Supervisor distribute
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && pip install --upgrade pip \
	# && curl -s https://pypi.org/simple/pip/ \
	&& yum install -y python-setuptools \
    # && yum clean all \
    # && easy_install pip \
    && pip install supervisor


# -----------------------------------------------------------------------------
# Update yarn and Update npm , install apidoc nodemon
# ----------------------------------------------------------------------------- 

RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo \
	&& yum install -y yarn \
    && npm i npm@latest -g 
    # && npm install apidoc nodemon -g　

# -----------------------------------------------------------------------------
# Configure, timezone/sshd/passwd/networking , Config root , add super
# -----------------------------------------------------------------------------
# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several problems.
RUN ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
	&& echo "root:123456" | chpasswd \
	&& ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \ 
	&& ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	&& ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
	&& grep "GSSAPIAuthentication yes" -rl /etc/ssh/ssh_config | xargs sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" \
    && useradd super \
    && echo "super:123456" | chpasswd \
    && echo "super  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers 


# -----------------------------------------------------------------------------
# Install Nginx
# ----------------------------------------------------------------------------- 
ENV nginx_version 1.20.1
ENV NGINX_INSTALL_DIR ${HOME}/nginx
RUN cd ${SRC_DIR} \
    && wget -q -O nginx-${nginx_version}.tar.gz  http://nginx.org/download/nginx-${nginx_version}.tar.gz \
    && tar zxvf nginx-${nginx_version}.tar.gz  \
    && cd nginx-${nginx_version} \
    && ./configure --user=super --group=super --prefix=${NGINX_INSTALL_DIR} --with-http_v2_module --with-http_ssl_module --with-http_sub_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/nginx-*


# -----------------------------------------------------------------------------
# Install openssl  1.1.1n
# ----------------------------------------------------------------------------- 
# ENV opensslversion 1.1.1n
# ADD ./openssl/openssl.spec ${SRC_DIR}/
# RUN cd ${SRC_DIR}\
#     # && yum -y install which  perl  perl-WWW-Curl  rpm-build \
#     && wget https://www.openssl.org/source/openssl-${opensslversion}.tar.gz \
#     && mkdir -p ${HOME}/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} \
#     && cp ${SRC_DIR}/openssl.spec ${HOME}/rpmbuild/SPECS/openssl.spec \
#     && cp ./openssl-${opensslversion}.tar.gz ${HOME}/rpmbuild/SOURCES/ \
#     && cd ${HOME}/rpmbuild/SPECS \
#     && rpmbuild -D "version 1.1.1n" -ba openssl.spec \
#     && yum remove -y openssl openssl-devel \
#     && rpm -ivvh ${HOME}/rpmbuild/RPMS/x86_64/openssl-${opensslversion}-1.el7.x86_64.rpm --nodeps --force \
#     && rpm -ivvh ${HOME}/rpmbuild/RPMS/x86_64/openssl-devel-${opensslversion}-1.el7.x86_64.rpm --nodeps --force  \
#     && rm -rf ${HOME}/rpmbuild ${SRC_DIR}/openssl* \
#     && yum remove -y rpm-build \
#     && yum clean all
    # && && echo "/usr/local/openssl/ssl/lib" >> /etc/ld.so.conf

    

# -----------------------------------------------------------------------------
# Install Redis
# -----------------------------------------------------------------------------
ENV redis_version 6.2.1
ENV REDIS_INSTALL_DIR ${HOME}/redis
RUN cd ${SRC_DIR} \
    && wget -q -O redis-${redis_version}.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xzf redis-${redis_version}.tar.gz \
    && cd redis-${redis_version} \
    && make 1>/dev/null \
    && make PREFIX=$REDIS_INSTALL_DIR install \
    && rm -rf ${SRC_DIR}/redis-*

# -----------------------------------------------------------------------------
# Install hiredis
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O hiredis-0.14.0.tar.gz https://github.com/redis/hiredis/archive/v0.14.0.tar.gz \
    && tar zxvf hiredis-0.14.0.tar.gz \
    && cd hiredis-0.14.0 \
    && make \
    && make install \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf \
    && ldconfig \
    && rm -rf $SRC_DIR/hiredis-*

# -----------------------------------------------------------------------------
# Install ImageMagick
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O ImageMagick.tar.gz https://www.imagemagick.org/download/ImageMagick.tar.gz \
    && tar zxf ImageMagick.tar.gz \
    && rm -rf ImageMagick.tar.gz \
    && ImageMagickPath=`ls` \
    && cd ${ImageMagickPath} \
    && ./configure \
    && make \
    && make install \
    && rm -rf $SRC_DIR/ImageMagick*

# -----------------------------------------------------------------------------
# Install libmemcached using by php-memcached
# -----------------------------------------------------------------------------
ENV LIB_MEMCACHED_INSTALL_DIR /usr/local/
RUN cd ${SRC_DIR} \
    && wget -q -O libmemcached-1.0.18.tar.gz https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz \
    && tar xzf libmemcached-1.0.18.tar.gz \
    && cd libmemcached-1.0.18 \
    && ./configure --prefix=$LIB_MEMCACHED_INSTALL_DIR --with-memcached 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/libmemcached*

# -----------------------------------------------------------------------------
# Install libmcrypt using by php-mcrypt
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O libmcrypt-2.5.7.tar.gz https://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/Production/libmcrypt-2.5.7.tar.gz \
    && tar xzf libmcrypt-2.5.7.tar.gz \
    && cd libmcrypt-2.5.7 \
    && ./configure 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf \
    && echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local.conf \
    && echo "/usr/local/src/libmcrypt-2.5.7/lib/.libs" >> /etc/ld.so.conf.d/local.conf \
    && chmod gu+x /etc/ld.so.conf.d/local.conf \
    && ldconfig -v

# -----------------------------------------------------------------------------
# Install re2c for PHP
# -----------------------------------------------------------------------------
RUN cd $SRC_DIR \
    #&& wget -q -O re2c-1.0.1.tar.gz https://sourceforge.net/projects/re2c/files/1.0.1/re2c-1.0.1.tar.gz/download \
    && wget -q -O re2c-1.0.3.tar.gz https://github.com/skvadrik/re2c/releases/download/1.0.3/re2c-1.0.3.tar.gz \
    && tar xzf re2c-1.0.3.tar.gz \
    && cd re2c-1.0.3 \
    && ./configure \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/re2c*

# .开启libzip-1.2.0.tar.gz

# RUN cd $SRC_DIR \
#     yum remove libzip libzip-devel \
#     && wget  -q -O libzip-1.2.0.tar.gz https://hqidi.com/big/libzip-1.2.0.tar.gz \
#     && tar -zxvf libzip-1.2.0.tar.gz \
#     && cd libzip-1.2.0 \
#     && ./configure \
#     && make && make install \
#     export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"

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
RUN cd ${SRC_DIR} \
    && curl -L -o cmake-3.19.1.tar.gz https://github.com/Kitware/CMake/releases/download/v3.19.1/cmake-3.19.1.tar.gz  \
    && tar -zxf cmake-3.19.1.tar.gz \
    && cd cmake-3.19.1 \
    && export OPENSSL_ROOT_DIR=/usr/local/openssl \
    && export OPENSSL_CRYPTO_LIBRARY=/usr/local/openssl/lib \
    && export OPENSSL_INCLUDE_DIR=/usr/local/openssl/include \
    && ./bootstrap \
    && make \
    && make install \
    && ldconfig \
    && make clean \
    && rm -rf ${SRC_DIR}/cmake*
    #&& cmake –-version 


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
 

# ADD rh-bak.zip /opt/

# RUN cd /opt \
#     && unzip rh-bak.zip 

# RUN cd /usr/local/git/grpc/third_party/protobuf \
#     && yum install -y automake  libtool \
#     # && source scl_source enable devtoolset-10 \
#     && export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc \
#     && export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp \
#     && export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++ \
#     && ls -alh /usr/local/git/grpc/third_party/protobuf/ \
#     && ./autogen.sh \
#     && export CFLAGS="$CFLAGS -fPIC" \
#     && export CXXFLAGS="$CXXFLAGS -fPIC" \
#     && ./configure --disable-shared \
#     && make \
#     && make install \
#     && ldconfig \
#     && make clean

# RUN git clone --depth 1 -b v1.34.x https://github.com/grpc/grpc.git /usr/local/git/grpc \
#     && cd /usr/local/git/grpc \
#     && git submodule update --init --recursive \
#     && mkdir -p cmake/build \
#     && cd cmake/build \
#     && cmake ../.. \
#     && make 

# shared
# RUN git clone --depth 1 -b v1.34.x https://github.com/grpc/grpc.git /usr/local/git/grpc \
#     && yum install -y automake  libtool \
#     && cd /usr/local/git/grpc \
#     && git submodule update --init --recursive \
#     && cd third_party/protobuf \
#     && export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc \
#     && export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp \
#     && export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++ \
#     && ./autogen.sh \
#     && ./configure \
#     && make \
#     && make install \
#     && ldconfig \
#     && cd /usr/local/git/grpc \
#     # && git submodule update --init --recursive \
#     && mkdir -p cmake/build \
#     && cd cmake/build \
#     && cmake ../.. -DBUILD_SHARED_LIBS=ON -DgRPC_INSTALL=ON \
#     && make  \
#     && make install \
#     && ldconfig 

# RUN cd /usr/local/git/grpc/third_party/protobuf \
#     && yum install -y automake  libtool \
#     && ls -alh /usr/local/git/grpc/third_party/protobuf/ \
#     && mkdir -p cmake/build \
#     && cd cmake/build \
#     && cmake ../.. -DBUILD_SHARED_LIBS=ON -DgRPC_INSTALL=ON -Dprotobuf_BUILD_TESTS=OFF \
#     # && make -j4 \
#     && make \
#     && make install \
#     && ldconfig \
#     && make clean 

# RUN cd /usr/local/git/grpc  \
#     && export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc \
#     && export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp \
#     && export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++ \
#     && mkdir -p cmake/build \
#     && cd cmake/build \
#     && cmake ../.. -DBUILD_SHARED_LIBS=ON -DgRPC_INSTALL=ON \
#     # && make -j4 \
#     && make \
#     && make install \
#     && ldconfig \
#     && make clean 






# RUN openssl version -a \
#     && whereis openssl \
#     && ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1 \
#     && ln -s /usr/local/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1 \
#     # && ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl \
#     && ln -s /usr/local/openssl/include/openssl /usr/include/openssl \
#     && ln -s /usr/local/openssl/lib/libssl.so /usr/lib \
#     && echo "/usr/local/openssl/ssl/lib" >> /etc/ld.so.conf

RUN yum install -y mysql-server mysql mysql-devel  readline readline-devel 



# -----------------------------------------------------------------------------
# Install openssl  1.1.1n
# ----------------------------------------------------------------------------- 
# RUN cd ${SRC_DIR}\
#     # && yum -y install which  perl  perl-WWW-Curl  rpm-build \
#     && yum remove -y openssl openssl-devel \
#     && yum install -y openssl openssl-devel
#     # && && echo "/usr/local/openssl/ssl/lib" >> /etc/ld.so.conf


# -----------------------------------------------------------------------------
# Install PHP
# -----------------------------------------------------------------------------
ENV phpversion 5.3.29
ENV PHP_INSTALL_DIR ${HOME}/php
RUN cd ${SRC_DIR} \
    && yum install net-snmp-devel -y \
    #&& cp /usr/local/openssl/lib/pkgconfig/*.pc /usr/local/lib/pkgconfig/ \
    && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/" \
    && wget -q -O php-${phpversion}.tar.gz https://www.php.net/distributions/php-${phpversion}.tar.gz \
    && tar xzf php-${phpversion}.tar.gz \
    && cd php-${phpversion} \
    # && make clean \
    && ./configure \
    #    --disable-shared \
    #    --enable-static \
       --prefix=${PHP_INSTALL_DIR} \
       --with-config-file-path=${PHP_INSTALL_DIR}/etc \
       --with-config-file-scan-dir=${PHP_INSTALL_DIR}/etc/php.d \
       --sysconfdir=${PHP_INSTALL_DIR}/etc \
       --with-libdir=lib64 \
       --enable-fd-setsize=65536 \
    #    --with-zip \
       --enable-exif \
       --enable-ftp \
       --enable-mbstring \
       --enable-fpm \
       --enable-bcmath \
       --enable-pcntl \
       --enable-soap \
       --enable-sockets \
       --enable-shmop \
       --enable-gd-native-ttf \
    #    --enable-gd \
       --enable-ctype \
       --enable-calendar \
       --enable-zend-multibyte \
       --enable-zip \
    #    --with-fpm-user=www \
    #    --with-fpm-group=www \
    #    --enable-intl \/ #magento
       --enable-wddx \
       --with-gettext \
       --with-xsl \
       --with-xmlrpc \
       --with-snmp \
       --with-ldap \
       --with-ldap-sasl \
       --with-mysqli  \
       --with-mysql  \
       --with-pdo-mysql \
       --with-pdo-odbc=unixODBC,/usr \
       --with-jpeg \
       --with-zlib-dir \
       --with-freetype \
       --with-zlib \
       --with-bz2 \
       --with-openssl \
       --with-curl=/usr/bin/curl \
    #  --with-icu-dir=/usr/lib/icu/ \ #magento
       --with-mhash \
       --with-regex \
       --with-gd \
       --with-readline \
    && make --quiet 1>/dev/null \
    && make install \
    && rm -rf ${PHP_INSTALL_DIR}/lib/php.ini \
    && cp -f php.ini-development ${PHP_INSTALL_DIR}/lib/php.ini \
    ## && cp -rf ${SRC_DIR}/php-${phpversion}/ext/intl  ${SRC_DIR}/ \  # magento
    && rm -rf ${SRC_DIR}/php* \
    && rm -rf ${SRC_DIR}/libmcrypt*

# -----------------------------------------------------------------------------
# Install yaml and PHP yaml extension
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O yaml-1.2.0.tgz https://pecl.php.net/get/yaml-1.2.0.tgz \
    && tar xzf yaml-1.2.0.tgz \
    && cd yaml-1.2.0 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-yaml=/usr/local --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make >/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/yaml-*

# -----------------------------------------------------------------------------
# Install PHP mongodb extensions
# -----------------------------------------------------------------------------
ENV mongodb_ext_version 1.1.0
RUN cd ${SRC_DIR} \
    && ln -s /usr/openssl/include/openssl /usr/local/include \
    && wget -q -O mongodb-${mongodb_ext_version}.tgz https://pecl.php.net/get/mongodb-${mongodb_ext_version}.tgz \
    && tar zxf mongodb-${mongodb_ext_version}.tgz \
    && cd mongodb-${mongodb_ext_version} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/mongodb-*



# RUN cd ${SRC_DIR} \
#     && wget http://pear.php.net/go-pear.phar --no-check-certificate\
#     && ${PHP_INSTALL_DIR}/bin/php go-pear.phar \
#     && rm -rf go-pear.phar 

# -----------------------------------------------------------------------------
# Install PHP Rabbitmq extensions
# -----------------------------------------------------------------------------
ENV rabbitmqcversion 0.6.0
RUN cd ${SRC_DIR} \
	&& wget -q -O rabbitmq-c-${rabbitmqcversion}.tar.gz https://github.com/alanxz/rabbitmq-c/releases/download/v${rabbitmqcversion}/rabbitmq-c-${rabbitmqcversion}.tar.gz \
	&& tar zxf rabbitmq-c-${rabbitmqcversion}.tar.gz \
	&& cd rabbitmq-c-${rabbitmqcversion} \
	&& ./configure --prefix=/usr/local/rabbitmq-c-${rabbitmqcversion} \
	&& make \
    && make install 

# -----------------------------------------------------------------------------
# Install PHP amqp extensions
# -----------------------------------------------------------------------------
ENV amqpversion 1.6.0 
RUN cd ${SRC_DIR} \
    && wget -q -O amqp-${amqpversion}.tgz https://pecl.php.net/get/amqp-${amqpversion}.tgz\
    && tar zxf amqp-${amqpversion}.tgz \
    && cd amqp-${amqpversion} \
    && cp ${SRC_DIR}/rabbitmq-c-${rabbitmqcversion}/librabbitmq/amqp_ssl_socket.h . \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c-${rabbitmqcversion} 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/amqp-*  ${SRC_DIR}/rabbitmq-c-0.8.0*

# -----------------------------------------------------------------------------
# Install PHP redis extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O redis-3.1.2.tgz https://pecl.php.net/get/redis-3.1.2.tgz \
    && tar zxf redis-3.1.2.tgz \
    && cd redis-3.1.2 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/redis-*

# -----------------------------------------------------------------------------
# Install PHP imagick extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O imagick-3.4.3.tgz https://pecl.php.net/get/imagick-3.4.3.tgz \
    && tar zxf imagick-3.4.3.tgz \
    && cd imagick-3.4.3 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-imagick 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/imagick-*

# -----------------------------------------------------------------------------
# Install PHP xdebug extensions
# -----------------------------------------------------------------------------
#ENV xdebugversion 2.7.0
#RUN cd ${SRC_DIR} \
#    && wget -q -O xdebug-${xdebugversion}.tgz https://pecl.php.net/get/xdebug-${xdebugversion}.tgz \
#    && tar zxf xdebug-${xdebugversion}.tgz \
#    && cd xdebug-${xdebugversion} \
#    && ${PHP_INSTALL_DIR}/bin/phpize \
#    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
#    && make clean \
#    && make 1>/dev/null \
#    && make install \
#    && rm -rf ${SRC_DIR}/xdebug-*

# -----------------------------------------------------------------------------
# Install PHP igbinary extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O igbinary-2.0.8.tgz https://pecl.php.net/get/igbinary-2.0.8.tgz \
    && tar zxf igbinary-2.0.8.tgz \
    && cd igbinary-2.0.8 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/igbinary-*
    
# -----------------------------------------------------------------------------
# Install PHP xlswriter extensions
# -----------------------------------------------------------------------------
# ENV xlswriterversion 1.5.1
# RUN cd ${SRC_DIR} \
#     && wget -q -O xlswriter-${xlswriterversion}.tgz https://pecl.php.net/get/xlswriter-${xlswriterversion}.tgz \
#     && tar zxf xlswriter-${xlswriterversion}.tgz \
#     && cd xlswriter-${xlswriterversion} \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --enable-reader 1>/dev/null \
#     && make clean \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf ${SRC_DIR}/xlswriter-*


# -----------------------------------------------------------------------------
# Install PHP memcached extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O memcached-2.2.0.tgz https://pecl.php.net/get/memcached-2.2.0.tgz \
    && tar xzf memcached-2.2.0.tgz \
    && cd memcached-2.2.0 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --enable-memcached --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
       --with-libmemcached-dir=${LIB_MEMCACHED_INSTALL_DIR} --disable-memcached-sasl 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/memcached-*

# -----------------------------------------------------------------------------
# Install PHP memcache extensions
# -----------------------------------------------------------------------------
# ENV memcache_ext_version 1.6.12
# ENV LIB_MEMCACHE_INSTALL_DIR /usr/local/
# RUN cd ${SRC_DIR} \
#     && wget -q -O memcache-${memcache_ext_version}.tgz https://pecl.php.net/get/memcache-${memcache_ext_version}.tgz \
#     && tar xzf memcache-${memcache_ext_version}.tgz \
#     && cd memcache-${memcache_ext_version} \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --enable-memcache --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
#        --with-libmemcache-dir=${LIB_MEMCACHE_INSTALL_DIR} --disable-memcache-sasl 1>/dev/null \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf ${SRC_DIR}/memcached-*

# -----------------------------------------------------------------------------
# Install PHP yac extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O yac-0.9.2.tgz https://pecl.php.net/get/yac-0.9.2.tgz \
    && tar zxf yac-0.9.2.tgz\
    && cd yac-0.9.2 \
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
# RUN cd ${SRC_DIR} \
#     && wget -q -O libsodium-2.0.23.tgz https://pecl.php.net/get/libsodium-2.0.23.tgz \
#     && tar zxf libsodium-2.0.23.tgz\
#     && cd libsodium-2.0.23 \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf $SRC_DIR/libsodium-*


# -----------------------------------------------------------------------------
# Install PHP swoole extensions
# -----------------------------------------------------------------------------

#RUN /vue-msf/php/bin/pecl install swoole_serialize-0.1.1

# ENV swooleVersion 4.8.2
# RUN cd ${SRC_DIR} \
#     && ls /usr/local/include/ \
#     && wget -q -O swoole-${swooleVersion}.tar.gz https://github.com/swoole/swoole-src/archive/v${swooleVersion}.tar.gz \
#     && tar zxf swoole-${swooleVersion}.tar.gz \
#     && cd swoole-src-${swooleVersion}/ \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --enable-async-redis --enable-openssl --with-openssl-dir=/usr/local/openssl/ --enable-mysqlnd \
#     && make clean 1>/dev/null \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf ${SRC_DIR}/swoole*


# -----------------------------------------------------------------------------
# Install PHP inotify extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O inotify-0.1.6.tgz https://pecl.php.net/get/inotify-0.1.6.tgz \
    && tar zxf inotify-0.1.6.tgz \
    && cd inotify-0.1.6 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/inotify-*

# -----------------------------------------------------------------------------
# Install PHP SkyAPM-php-sdk extensions
# -----------------------------------------------------------------------------

# RUN cd ${SRC_DIR} \
#     # && yum install boost boost-devel boost-doc -y \
#     && find / -name 'libgrpc.a' \
#     && yum install boost boost-devel  -y \
#     && curl -Lo v4.1.3.tar.gz https://github.com/SkyAPM/SkyAPM-php-sdk/archive/v4.1.3.tar.gz \
#     && tar -zxf v4.1.3.tar.gz \
#     && whereis libgrpc \
#     && ldconfig && ldconfig -p|grep libgrpc \
#     && cd SkyAPM-php-sdk-4.1.3 \
#     && export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc \
#     && export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp \
#     && export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++ \
#     && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib64  \
#     && ldconfig && ldconfig -p|grep libgrpc \
#     && ${PHP_INSTALL_DIR}/bin/phpize  \
#     && ls -alh /usr/local/git/grpc/cmake/build/ \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-grpc="/usr/local/git/grpc" 1>/dev/null \
#     && make \
#     && make install \
#     && rm -rf /opt/rh /opt/rh-bak.zip ${SRC_DIR}/v4.1.3.tar.gz ${SRC_DIR}/SkyAPM-php-sdk-4.1.3 \
#     && rm -rf /usr/local/git/grpc \
#     && yum remove boost boost-devel  -y 

# RUN cd ${SRC_DIR} \
#     && wget -q -O skywalking-4.2.0.tgz https://pecl.php.net/get/skywalking-4.2.0.tgz \
#     && yum install boost-devel  -y \
#     && tar zxf skywalking-4.2.0.tgz\
#     && cd skywalking-4.2.0 \
#     && export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc \
#     && export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp \
#     && export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++ \
#     && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib64  \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-grpc="/usr/local/git/grpc"  \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf $SRC_DIR/skywalking-* \
#     && yum remove boost-devel  -y

###php 5.3.29 remove
# RUN cd ${SRC_DIR} \
#     && wget -q -O skywalking-4.2.0.tgz https://pecl.php.net/get/skywalking-4.2.0.tgz \
#     && git clone https://github.com/SkyAPM/SkyAPM-php-sdk.git \
#     && yum install boost-devel  -y \
#     # && tar zxf skywalking-4.2.0.tgz\
#     && cd SkyAPM-php-sdk \
#     && export CC=/opt/rh/devtoolset-10/root/usr/bin/gcc \
#     && export CPP=/opt/rh/devtoolset-10/root/usr/bin/cpp \
#     && export CXX=/opt/rh/devtoolset-10/root/usr/bin/c++ \
#     && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib64  \
#     && ${PHP_INSTALL_DIR}/bin/phpize \
#     && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --with-grpc-src="/usr/local/git/grpc"  \
#     && make 1>/dev/null \
#     && make install \
#     && rm -rf $SRC_DIR/skywalking-* \
#     && yum remove boost-devel  -y


# -----------------------------------------------------------------------------
# Install PHP mongo extensions
# -----------------------------------------------------------------------------
ENV mongo_ext_version 1.6.12
RUN cd ${SRC_DIR} \
    && wget -q -O mongo-${mongo_ext_version}.tgz https://pecl.php.net/get/mongo-${mongo_ext_version}.tgz \
    && tar zxf mongo-${mongo_ext_version}.tgz \
    && cd mongo-${mongo_ext_version} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/mongo-*


# -----------------------------------------------------------------------------
# Install PHP oauth extensions
# -----------------------------------------------------------------------------
ENV oauth_ext_version 1.2.3
RUN cd ${SRC_DIR} \
    && wget -q -O oauth-${oauth_ext_version}.tgz https://pecl.php.net/get/oauth-${oauth_ext_version}.tgz \
    && tar zxf oauth-${oauth_ext_version}.tgz \
    && cd oauth-${oauth_ext_version} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/oauth-*

# -----------------------------------------------------------------------------
# Install PHP zendopcache extensions
# -----------------------------------------------------------------------------
ENV zendopcache_ext_version 7.0.5
RUN cd ${SRC_DIR} \
    && wget -q -O zendopcache-${zendopcache_ext_version}.tgz https://pecl.php.net/get/zendopcache-${zendopcache_ext_version}.tgz \
    && tar zxf zendopcache-${zendopcache_ext_version}.tgz \
    && cd zendopcache-${zendopcache_ext_version} \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/zendopcache-*

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
    && curl -sS https://getcomposer.org/installer | ${PHP_INSTALL_DIR}/bin/php -d detect_unicode=Off \
    && chmod +x composer.phar \
    && mv composer.phar ${PHP_INSTALL_DIR}/bin/composer

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
RUN cd ${SRC_DIR} \
    && wget -q -O jq-1.5.tar.gz https://github.com/stedolan/jq/archive/jq-1.5.tar.gz \
    && tar zxf jq-1.5.tar.gz \
    && cd jq-jq-1.5 \
    && ./configure --disable-maintainer-mode \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/jq-* \
    && yum clean all 

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
RUN cd ${SRC_DIR} \
    && yum -y remove git subversion \
    && wget -q -O git-2.20.1.tar.gz https://github.com/git/git/archive/v2.20.1.tar.gz \
    && tar zxf git-2.20.1.tar.gz \
    && cd git-2.20.1 \
    && make configure \
    && ./configure --without-iconv --prefix=/usr/local/ --with-curl=/usr/bin/curl  --with-openssl=/usr/local/openssl/ \
    && make \
    && make install \
    && rm -rf $SRC_DIR/git-2* 
    
# -----------------------------------------------------------------------------
# Install gocronx
# -----------------------------------------------------------------------------
RUN mkdir -p ${HOME}/gocronx/
ADD gocronx ${HOME}/gocronx/ 
RUN chmod a+x -R ${HOME}/gocronx/
    
# -----------------------------------------------------------------------------
# Update Git-Core
# -----------------------------------------------------------------------------
RUN  yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/git-core-2.23.0-1.ep7.x86_64.rpm \
    && ln -s /usr/libexec/git-core/git-remote-http /bin/ \
    && ln -s /usr/libexec/git-core/git-remote-https /bin/ \
    && git config --global user.email "vue-msf@admin.com" \
    && git config --global user.name "vue-msf"

# -----------------------------------------------------------------------------
# jsawk
# -----------------------------------------------------------------------------
RUN curl -s -L http://github.com/micha/jsawk/raw/master/jsawk > /usr/local/bin/jsawk \
	&& chmod 755 /usr/local/bin/jsawk

# -----------------------------------------------------------------------------
# Copy Config
# -----------------------------------------------------------------------------
ADD run.sh /
ADD config/.bash_profile /home/super/
ADD config/.bashrc /home/super/
ADD config /vue-msf/
ADD Zend.zip /vue-msf/php/lib/php/
ADD Smarty.zip /vue-msf/php/lib/php/
RUN chmod a+x /run.sh \
	&& chmod a+x ${PHP_INSTALL_DIR}/bin/checkstyle \
    && chmod a+x ${PHP_INSTALL_DIR}/bin/mergeCoverReport \
    && cd /vue-msf/php/lib/php \
    && unzip Smarty.zip && rm -rf Smarty.zip  \
    && unzip Zend.zip && rm -rf Zend.zip  


# -----------------------------------------------------------------------------
# Set  Centos limits
# -----------------------------------------------------------------------------

RUN echo -e "# Default limit for number of user's processes to prevent \n\
# accidental fork bombs. \n\
# See rhbz #432903 for reasoning. \n\
* soft nofile 65535 \n\
* hard nofile 65535 \n\
* hard nproc 65535 \n\
* soft nproc 65535 " > /etc/security/limits.d/20-nproc.conf


# -----------------------------------------------------------------------------
# Profile
# ----------------------------------------------------------------------------- 
RUN echo -e 'PATH=$PATH:/vue-msf/php/bin \nPATH=$PATH:/vue-msf/php/sbin \nPATH=$PATH:/vue-msf/nginx/bin/ \nPATH=$PATH:/vue-msf/sbin/ \nPATH=$PATH:/vue-msf/redis/bin/:/usr/libexec/git-core \nexport PATH \n' >> /etc/profile \
    && source /etc/profile

# -----------------------------------------------------------------------------
# clean tmp file
# -----------------------------------------------------------------------------
# RUN rm -rf ${SRC_DIR}/* \
# 	&& rm -rf /tmp/*

EXPOSE 22 80 443 8080 8000
ENTRYPOINT ["/run.sh"]
