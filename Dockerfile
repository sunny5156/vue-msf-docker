FROM centos:centos7
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
    && curl -s --location https://rpm.nodesource.com/setup_10.x | bash - \
    && yum -y update \
    && yum groupinstall -y "Development tools" \
    && yum install -y cc gcc gcc-c++ zlib zlib-devel bzip2-devel openssl openssl-devel ncurses-devel sqlite-devel wget net-tools \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all
    
# -----------------------------------------------------------------------------
# Change yum repos
# -----------------------------------------------------------------------------
RUN cd /etc/yum.repos.d \
   #&& mv CentOS-Base.repo CentOS-Base.repo.bak \
   && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
   #&& wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
   && yum clean all

# -----------------------------------------------------------------------------
# Install Python PIP & Supervisor
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
	&& curl -s https://pypi.org/simple/pip/ \
	&& yum install -y python-setuptools \
    && yum clean all \
    && easy_install pip \
    && pip install supervisor distribute

# -----------------------------------------------------------------------------
# Devel libraries for delelopment tools like php & nginx ...
# -----------------------------------------------------------------------------
RUN yum -y install \
	lrzsz psmisc epel-release lemon \
    tar gzip bzip2 bzip2-devel unzip file perl-devel perl-ExtUtils-Embed perl-CPAN \
    pcre pcre-devel openssh-server openssh sudo \
    screen vim git telnet expat expat-devel\
    ca-certificates m4\
    gd gd-devel libjpeg libjpeg-devel libpng libpng-devel libevent libevent-devel \
    net-snmp net-snmp-devel net-snmp-libs \
    freetype freetype-devel libtool-tldl libtool-ltdl-devel libxml2 libxml2-devel unixODBC unixODBC-devel libyaml libyaml-devel\
    libxslt libxslt-devel libmcrypt libmcrypt-devel freetds freetds-devel \
    curl-devel gettext-devel \
    openldap openldap-devel libc-client-devel \
    jemalloc jemalloc-devel inotify-tools nodejs apr-util yum-utils tree js\
    && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all
    
RUN rpm --import /etc/pki/rpm-gpg/RPM*


RUN yum -y install htop

# -----------------------------------------------------------------------------
# Update npm 
# ----------------------------------------------------------------------------- 
RUN npm i npm@latest -g
 

# -----------------------------------------------------------------------------
# Update yarn 
# ----------------------------------------------------------------------------- 

RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo \
	&& yum install -y yarn
# -----------------------------------------------------------------------------
# Configure, timezone/sshd/passwd/networking
# -----------------------------------------------------------------------------
# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several problems.
RUN ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
	&& echo "root:123456" | chpasswd \
	&& ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \ 
	&& ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	&& ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
	&& grep "GSSAPIAuthentication yes" -rl /etc/ssh/ssh_config | xargs sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g"
	
# -----------------------------------------------------------------------------
# Install Libzip
# ----------------------------------------------------------------------------- 	
#RUN cd ${SRC_DIR} \  
#	&& yum remove -y libzip libzip-devel \
#	&& wget -q -O libzip-1.2.0.tar.gz https://nih.at/libzip/libzip-1.2.0.tar.gz \
#	&& tar -zxvf libzip-1.2.0.tar.gz \
#	&& cd libzip-1.2.0 \
#	&& echo -e "/usr/local/lib64\n/usr/local/lib\n/usr/lib\n/usr/lib64" >>/etc/ld.so.conf \
#   && ldconfig -v \
#	&& ./configure \
#	&& make \
#	&& make install \
#	&& rm -rf $SRC_DIR/libzip-1.2.0 \
#	&& cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h

# -----------------------------------------------------------------------------
# Install Nginx
# ----------------------------------------------------------------------------- 
ENV nginx_version 1.13.5
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
# Install Redis
# -----------------------------------------------------------------------------
ENV redis_version 4.0.12
ENV REDIS_INSTALL_DIR ${HOME}/redis
RUN cd ${SRC_DIR} \
    && wget -q -O redis-${redis_version}.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xzf redis-${redis_version}.tar.gz \
    && cd redis-${redis_version} \
    && make 1>/dev/null \
    && make PREFIX=$REDIS_INSTALL_DIR install \
    && rm -rf ${SRC_DIR}/redis-*

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

# -----------------------------------------------------------------------------
# Install PHP
# -----------------------------------------------------------------------------
ENV phpversion 7.2.18
ENV PHP_INSTALL_DIR ${HOME}/php
RUN cd ${SRC_DIR} \
#    && ls -l \
    && wget -q -O php-${phpversion}.tar.gz https://www.php.net/distributions/php-${phpversion}.tar.gz \
    && tar xzf php-${phpversion}.tar.gz \
    && cd php-${phpversion} \
    && ./configure \
       --prefix=${PHP_INSTALL_DIR} \
       --with-config-file-path=${PHP_INSTALL_DIR}/etc \
       --with-config-file-scan-dir=${PHP_INSTALL_DIR}/etc/php.d \
       --sysconfdir=${PHP_INSTALL_DIR}/etc \
       --with-libdir=lib64 \
       --enable-fd-setsize=65536 \
       --enable-mysqlnd \
       --enable-zip \
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
       --enable-gd-native-ttf \
       --enable-wddx \
       --enable-opcache \
       --with-gettext \
       --with-xsl \
       --with-libexpat-dir \
       --with-xmlrpc \
       --with-snmp \
       --with-ldap \
       --enable-mysqlnd \
       --with-mysqli=mysqlnd \
       --with-pdo-mysql=mysqlnd \
       --with-pdo-odbc=unixODBC,/usr \
       --with-gd \
       --with-jpeg-dir \
       --with-png-dir \
       --with-zlib-dir \
       --with-freetype-dir \
       --with-zlib \
       --with-bz2 \
       --with-openssl \
       --with-curl=/usr/bin/curl \
       --with-mcrypt \
       --with-mhash \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${PHP_INSTALL_DIR}/lib/php.ini \
    && cp -f php.ini-development ${PHP_INSTALL_DIR}/lib/php.ini \
    && rm -rf ${SRC_DIR}/php* ${SRC_DIR}/libmcrypt*

# -----------------------------------------------------------------------------
# Install yaml and PHP yaml extension
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O yaml-2.0.3.tgz https://pecl.php.net/get/yaml-2.0.3.tgz \
    && tar xzf yaml-2.0.3.tgz \
    && cd yaml-2.0.3 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-yaml=/usr/local --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make >/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/yaml-*

# -----------------------------------------------------------------------------
# Install PHP mongodb extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O mongodb-1.6.1.tgz https://pecl.php.net/get/mongodb-1.6.1.tgz \
    && tar zxf mongodb-1.6.1.tgz \
    && cd mongodb-1.6.1 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make \
    && make install \
    && rm -rf ${SRC_DIR}/mongodb-*

# -----------------------------------------------------------------------------
# Install PHP Rabbitmq extensions
# -----------------------------------------------------------------------------

RUN cd ${SRC_DIR} \
	&& wget -q -O rabbitmq-c-0.7.1.tar.gz https://github.com/alanxz/rabbitmq-c/releases/download/v0.7.1/rabbitmq-c-0.7.1.tar.gz \
	&& tar zxf rabbitmq-c-0.7.1.tar.gz \
	&& cd rabbitmq-c-0.7.1 \
	&& ./configure --prefix=/usr/local/rabbitmq-c-0.7.1 \
	&& make && make install

# -----------------------------------------------------------------------------
# Install PHP amqp extensions
# -----------------------------------------------------------------------------

RUN echo '/usr/local/rabbitmq-c-0.7.1' | /vue-msf/php/bin/pecl install amqp

# -----------------------------------------------------------------------------
# Install PHP redis extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O redis-4.2.0.tgz https://pecl.php.net/get/redis-4.2.0.tgz \
    && tar zxf redis-4.2.0.tgz \
    && cd redis-4.2.0 \
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
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    --with-imagick 1>/dev/null \
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
# Install PHP memcached extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O memcached-3.1.3.tgz https://pecl.php.net/get/memcached-3.1.3.tgz \
    && tar xzf memcached-3.1.3.tgz \
    && cd memcached-3.1.3 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --enable-memcached --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
       --with-libmemcached-dir=${LIB_MEMCACHED_INSTALL_DIR} --disable-memcached-sasl 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/memcached-*

# -----------------------------------------------------------------------------
# Install PHP yac extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O yac-2.0.2.tgz https://pecl.php.net/get/yac-2.0.2.tgz \
    && tar zxf yac-2.0.2.tgz\
    && cd yac-2.0.2 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config \
    && make 1>/dev/null \
    && make install \
    && rm -rf $SRC_DIR/yac-*

# -----------------------------------------------------------------------------
# Install PHP swoole extensions
# -----------------------------------------------------------------------------

#RUN /vue-msf/php/bin/pecl install swoole_serialize-0.1.1

ENV swooleVersion 4.4.12
RUN cd ${SRC_DIR} \
    && wget -q -O swoole-${swooleVersion}.tar.gz https://github.com/swoole/swoole-src/archive/v${swooleVersion}.tar.gz \
    && tar zxf swoole-${swooleVersion}.tar.gz \
    && cd swoole-src-${swooleVersion}/ \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config --enable-async-redis --enable-openssl --enable-mysqlnd \
    && make clean 1>/dev/null \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/swoole*


# -----------------------------------------------------------------------------
# Install PHP inotify extensions
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O inotify-2.0.0.tgz https://pecl.php.net/get/inotify-2.0.0.tgz \
    && tar zxf inotify-2.0.0.tgz \
    && cd inotify-2.0.0 \
    && ${PHP_INSTALL_DIR}/bin/phpize \
    && ./configure --with-php-config=${PHP_INSTALL_DIR}/bin/php-config 1>/dev/null \
    && make clean \
    && make 1>/dev/null \
    && make install \
    && rm -rf ${SRC_DIR}/inotify-*

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
    && curl -sS https://getcomposer.org/installer | ${PHP_INSTALL_DIR}/bin/php \
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
# Update Git
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && yum -y remove git subversion \
    && wget -q -O git-2.20.1.tar.gz https://github.com/git/git/archive/v2.20.1.tar.gz \
    && tar zxf git-2.20.1.tar.gz \
    && cd git-2.20.1 \
    && make configure \
    && ./configure --without-iconv --prefix=/usr/local/ --with-curl=/usr/bin/curl \
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
RUN yum -y install git-core \
	&& ln -s /usr/libexec/git-core/git-remote-http /bin/ \
	&& ln -s /usr/libexec/git-core/git-remote-https /bin/

# -----------------------------------------------------------------------------
# Set GIT user info
# -----------------------------------------------------------------------------
RUN git config --global user.email "vue-msf@admin.com" \
	&& git config --global user.name "vue-msf"

# -----------------------------------------------------------------------------
# Install Node and apidoc and nodemon
# -----------------------------------------------------------------------------
RUN npm install apidoc nodemon -g

# -----------------------------------------------------------------------------
# jsawk
# -----------------------------------------------------------------------------
RUN curl -s -L http://github.com/micha/jsawk/raw/master/jsawk > /usr/local/bin/jsawk \
	&& chmod 755 /usr/local/bin/jsawk

# -----------------------------------------------------------------------------
# Add user super
# -----------------------------------------------------------------------------
RUN useradd super \
    && echo "super:123456" | chpasswd \
    && echo "super   ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers 

# -----------------------------------------------------------------------------
# Copy Config
# -----------------------------------------------------------------------------
ADD run.sh /
ADD config /vue-msf/
ADD config/.bash_profile /home/super/
ADD config/.bashrc /home/super/
RUN chmod a+x /run.sh \
	&& chmod a+x ${PHP_INSTALL_DIR}/bin/checkstyle \
    && chmod a+x ${PHP_INSTALL_DIR}/bin/mergeCoverReport

# -----------------------------------------------------------------------------
# Profile
# ----------------------------------------------------------------------------- 
RUN echo -e 'PATH=$PATH:/vue-msf/php/bin \nPATH=$PATH:/vue-msf/php/sbin \nPATH=$PATH:/vue-msf/nginx/bin/ \nPATH=$PATH:/vue-msf/sbin/ \nPATH=$PATH:/vue-msf/redis/bin/:/usr/libexec/git-core \nexport PATH \n' >> /etc/profile \
    && source /etc/profile

# -----------------------------------------------------------------------------
# clean tmp file
# -----------------------------------------------------------------------------
RUN rm -rf ${SRC_DIR}/* \
	&& rm -rf /tmp/*



EXPOSE 22 80 443 8080 8000
ENTRYPOINT ["/run.sh"]
