FROM centos:7.9.2009
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
RUN date 
ADD config/yum.repo/Centos-7.repo /etc/yum.repos.d/CentOS-Base.repo

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
    cpp gcc gcc-c++  cmake make boost boost-devel wget  mariadb-devel memcached-devel libmemcached-devel  libcurl-devel \
    libicu-devel libzip-devel libzip2-devel  libbzip2-devel  \
    elfutils-libelf-devel libdwarf-devel libcap-devel binutils-devel \
    libvpx-devel  gmp-devel libmagicwand-devel  ImageMagick-devel tbb-devel \
    sqlite-devel  readline readline-devel lz4-devel libedit-devel  ocaml gperf \
    && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all

RUN yum install -y epel-release
RUN yum install --enablerepo epel -y libmcrypt libmcrypt-devel gperftools gperftools-devel

    
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
    && ldconfig -v \
    && rm -rf ${SRC_DIR}/libmcrypt-2.5.7*

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
# Install cmake 3.10.3
# ----------------------------------------------------------------------------- 
# ENV cmake_version=3.10.3
# RUN cd ${SRC_DIR} \
#     && curl -L -o cmake-${cmake_version}.tar.gz https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}.tar.gz  \
#     && tar -zxf cmake-${cmake_version}.tar.gz \
#     && cd cmake-${cmake_version} \
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
# ENV phpversion 5.6.29
# ENV PHP_INSTALL_DIR ${HOME}/php
# RUN cd ${SRC_DIR} \
#     && yum install net-snmp-devel -y \
#     #&& cp /usr/local/openssl/lib/pkgconfig/*.pc /usr/local/lib/pkgconfig/ \
#     && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/" \
#     && wget -q -O php-${phpversion}.tar.gz https://www.php.net/distributions/php-${phpversion}.tar.gz \
#     && tar xzf php-${phpversion}.tar.gz \
#     && cd php-${phpversion} \
#     # && make clean \
#     && ./configure \
#     #    --disable-shared \
#     #    --enable-static \
#        --prefix=${PHP_INSTALL_DIR} \
#        --with-config-file-path=${PHP_INSTALL_DIR}/etc \
#        --with-config-file-scan-dir=${PHP_INSTALL_DIR}/etc/php.d \
#        --sysconfdir=${PHP_INSTALL_DIR}/etc \
#        --with-libdir=lib64 \
#        --enable-fd-setsize=65536 \
#     #    --with-zip \
#        --enable-exif \
#        --enable-ftp \
#        --enable-mbstring \
#        --enable-fpm \
#        --enable-bcmath \
#        --enable-pcntl \
#        --enable-soap \
#        --enable-sockets \
#        --enable-shmop \
#        --enable-gd-native-ttf \
#     #    --enable-gd \
#        --enable-ctype \
#        --enable-calendar \
#        --enable-zend-multibyte \
#        --enable-zip \
#     #    --with-fpm-user=www \
#     #    --with-fpm-group=www \
#     #    --enable-intl \/ #magento
#        --enable-opcache \
#        --enable-wddx \
#        --with-gettext \
#        --with-xsl \
#        --with-xmlrpc \
#        --with-snmp \
#        --with-ldap \
#        --with-ldap-sasl \
#        --with-mysqli  \
#        --with-mysql  \
#        --with-pdo-mysql \
#        --with-pdo-odbc=unixODBC,/usr \
#        --with-jpeg \
#        --with-zlib-dir \
#        --with-freetype \
#        --with-zlib \
#        --with-bz2 \
#        --with-openssl \
#        --with-curl=/usr/bin/curl \
#     #  --with-icu-dir=/usr/lib/icu/ \ #magento
#        --with-mhash \
#        --with-regex \
#        --with-gd \
#        --with-readline \
#     && make --quiet 1>/dev/null \
#     && make install \
#     && rm -rf ${PHP_INSTALL_DIR}/lib/php.ini \
#     && cp -f php.ini-development ${PHP_INSTALL_DIR}/lib/php.ini \
#     ## && cp -rf ${SRC_DIR}/php-${phpversion}/ext/intl  ${SRC_DIR}/ \  # magento
#     && rm -rf ${SRC_DIR}/php* \
#     && rm -rf ${SRC_DIR}/libmcrypt*
# -----------------------------------------------------------------------------
# Install HHVM 3.9.10
# -----------------------------------------------------------------------------
# ENV hhvmversion 3.9.10
# RUN cd ${SRC_DIR} \
#     && wget -q -O hhvm-HHVM-${hhvmversion}.tar.gz https://github.com/facebook/hhvm/archive/HHVM-${hhvmversion}.tar.gz \
#     && tar zxf  hhvm-HHVM-${hhvmversion}.tar.gz \
#     && cd hhvm-HHVM-${hhvmversion} \
#     && git submodule update --init --recursive \
#     && cmake . \
#     # && ./configure\
#     && make >/dev/null \
#     && make install 
#     # && rm -rf ${SRC_DIR}/yaml-*

# git clone https://github.com/facebook/hhvm

# # 安装 Boost 1.69.0
# ENV BOOST_VERSION=1.69.0
# ENV BOOST_ROOT=/usr/local/boost_${BOOST_VERSION}

# RUN cd ${SRC_DIR} && \
# # https://sf-west-interserver-1.dl.sourceforge.net/project/boost/boost/1.75.0/boost_1_75_0.tar.gz?viasf=1
#     wget https://sf-west-interserver-1.dl.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_$(echo ${BOOST_VERSION} | tr '.' '_').tar.gz && \
#     tar -zxf boost_*.tar.gz && \
#     cd boost_$(echo ${BOOST_VERSION} | tr '.' '_') && \
#     ./bootstrap.sh --prefix=${BOOST_ROOT} && \
#     ./b2 install --with-system --with-program_options --with-filesystem --with-context -j$(nproc)

# ENV BOOST_INCLUDEDIR=${BOOST_ROOT}/include \
#     BOOST_LIBRARYDIR=${BOOST_ROOT}/lib

RUN cd ${SRC_DIR} \
    && wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/google-glog/glog-0.3.3.tar.gz \
    && tar -zxf glog-0.3.3.tar.gz \
    && cd ${SRC_DIR}/glog-0.3.3\
    && ./configure \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/glog-0.3.3*

RUN cd ${SRC_DIR} \
    && wget https://src.fedoraproject.org/lookaside/extras/oniguruma/onig-5.9.5.tar.gz/970f98a4cd10021b545d84e34c34aae4/onig-5.9.5.tar.gz \
    && tar -zxf onig-5.9.5.tar.gz \
    && cd ${SRC_DIR}/onig-5.9.5 \
    && ./configure \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/onig-5.9.5*

RUN cd ${SRC_DIR} \
    && wget http://caml.inria.fr/pub/distrib/ocaml-4.02/ocaml-4.02.0.tar.gz \
    && tar -zxf ocaml-4.02.0.tar.gz \
    && cd ${SRC_DIR}/ocaml-4.02.0 \
    && ./configure -no-graph \
            -no-debugger \
            -no-ocamldoc \
    && make world.opt \
    && make install \
    && rm -rf ${SRC_DIR}/ocaml-4.02.0*

# RUN cd ${SRC_DIR} && \
# git clone -b HHVM-3.9.10 https://github.com/facebook/hhvm.git

# RUN cd ${SRC_DIR}/hhvm/ && \
# git submodule update --init --recursive && \
# env BOOST_ROOT=/usr/include/boost ./configure


# ENV hhvmversion 3.9.10
ENV hhvmversion 3.14.3
RUN cd ${SRC_DIR} \
    && git clone -b HHVM-${hhvmversion} https://github.com/facebook/hhvm ./hhvm-HHVM-${hhvmversion} \
    && cd hhvm-HHVM-${hhvmversion} \
    && git submodule update --init --recursive \
    && env BOOST_ROOT=/usr/include/boost ./configure \
    && ldconfig \
    && cmake \
    -DCMAKE_INSTALL_PREFIX=/vue-msf/hhvm \
    -DCMAKE_INSTALL_SYSCONFDIR=/vue-msf/hhvm/etc \
    . \
    && make \
    && ./hphp/hhvm/hhvm --version \
    && make install \
    && rm -rf ${SRC_DIR}/hhvm-HHVM-${hhvmversion}*

RUN  yum install -y automake libtool
    
RUN cd ${SRC_DIR} \
    && git clone -b 1.1.9  https://github.com/mongodb/libbson.git \
    && cd libbson/ \
    && sh ./autogen.sh \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/libbson*

RUN cd ${SRC_DIR} \
    && git clone -b 1.2.0  https://github.com/mongodb/mongo-hhvm-driver.git\
    && cd mongo-hhvm-driver \
    && git submodule sync && git submodule update --init --recursive \
    && /vue-msf/hhvm/bin/hphpize \
    && cmake . \
    && make configlib \
    && make -j 4 \
    && make install \
    && rm -rf ${SRC_DIR}/mongo-hhvm-driver*

RUN cd ${SRC_DIR} \
    && export PATH=$PATH:/vue-msf/hhvm/bin \
    && git clone https://github.com/mongofill/mongofill-hhvm.git \
    && cd mongofill-hhvm \
    && grep "git://" -rl .gitmodules | xargs sed -i "s|git://|https://|g" \
    && sh build.sh \
    && cp mongo.so /vue-msf/hhvm/lib64/hhvm/extensions/20150212 \
    && rm -rf ${SRC_DIR}/mongofill-hhvm*

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
RUN  yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/git-core-2.23.0-1.ep7.x86_64.rpm  subversion \
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
ADD config/.bashrc /home/super/
ADD config/.bash_profile /home/super/
ADD config /vue-msf/
ADD Zend.zip /vue-msf/hhvm/lib64/hhvm
ADD Smarty.zip /vue-msf/hhvm/lib64/hhvm
RUN chmod a+x /run.sh \
	# && chmod a+x ${PHP_INSTALL_DIR}/bin/checkstyle \
    # && chmod a+x ${PHP_INSTALL_DIR}/bin/mergeCoverReport \
    && cd /vue-msf/hhvm/lib64/hhvm \
    && unzip Smarty.zip && rm -rf Smarty.zip  \
    && unzip Zend.zip && rm -rf Zend.zip  \
    && mkdir -p /var/log/hhvm/


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
RUN echo -e 'PATH=$PATH:/vue-msf/hhvm/bin \nPATH=$PATH:/vue-msf/php/bin \nPATH=$PATH:/vue-msf/php/sbin \nPATH=$PATH:/vue-msf/nginx/bin/ \nPATH=$PATH:/vue-msf/sbin/ \nPATH=$PATH:/vue-msf/redis/bin/:/usr/libexec/git-core \nexport PATH \n' >> /etc/profile \
    && source /etc/profile

# -----------------------------------------------------------------------------
# clean tmp file
# -----------------------------------------------------------------------------
# RUN rm -rf ${SRC_DIR}/* \
# 	&& rm -rf /tmp/*

EXPOSE 22 80 443 8080 8000
ENTRYPOINT ["/run.sh"]
