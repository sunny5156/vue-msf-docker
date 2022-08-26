FROM almalinux:8
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
    && curl -s --location https://rpm.nodesource.com/setup_14.x | bash - \
    && yum -y install wget epel-release \
    gcc gcc-c++ cmake zlib zlib-devel  \
    sqlite-devel net-tools python36 \
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
RUN sed -i "s|failovermethod=priority|#failovermethod=priority|g" /etc/yum.repos.d/nodesource-el8.repo \
    # grep '#! /usr/bin/python' -rl /usr/libexec/urlgrabber-ext-down | xargs sed -i "s/#! \/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
    # && grep '#!/usr/bin/python' -rl /usr/bin/yum  | xargs sed -i "s/#!\/usr\/bin\/python/#!\/usr\/bin\/python2/g" \
    && cd /usr/bin \
    # && rm -f python pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip

# -----------------------------------------------------------------------------
# Devel libraries for delelopment tools like  & nginx ...
# -----------------------------------------------------------------------------
RUN yum -y install \
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
    libicu libicu-devel \
    && find / -name "libicu*" 

# -----------------------------------------------------------------------------
# Install Python PIP & Supervisor distribute
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    # && pip install --upgrade pip \
    && pip install supervisor==4.2.2

# -----------------------------------------------------------------------------
# Update yarn and Update npm , install apidoc nodemon
# ----------------------------------------------------------------------------- 

RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo \
	&& yum install -y yarn \
    && npm i npm@latest -g 
    # && npm install apidoc nodemon -g/

# -----------------------------------------------------------------------------
# Configure, timezone/sshd/passwd/networking , Config root , add super
# -----------------------------------------------------------------------------
# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several problems.
RUN ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
	&& echo "root:123456" | chpasswd \
	&& ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \ 
	&& ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	&& ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
	&& sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/ssh_config \
    && useradd super \
    && echo "super:123456" | chpasswd \
    && echo "super  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers 


# -----------------------------------------------------------------------------
# Install Nginx
# ----------------------------------------------------------------------------- 
ENV nginx_version 1.21.5
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
ENV redis_version 6.2.1
ENV REDIS_INSTALL_DIR ${HOME}/redis
RUN cd ${SRC_DIR} \
    && wget -q -O redis-${redis_version}.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xzf redis-${redis_version}.tar.gz \
    && cd redis-${redis_version} \
    && make >/dev/null \
    && make PREFIX=$REDIS_INSTALL_DIR install \
    && rm -rf ${SRC_DIR}/redis-*

# -----------------------------------------------------------------------------
# Install ImageMagick
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && wget -q -O ImageMagick.tar.gz https://www.imagemagick.org/download/ImageMagick.tar.gz \
#     # && wget -q -O ImageMagick.tar.gz https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz \
#     && tar zxf ImageMagick.tar.gz \
#     && rm -rf ImageMagick.tar.gz \
#     && ImageMagickPath=`ls | grep ImageMagick-` \
#     && cd ${ImageMagickPath} \
#     && ./configure >/dev/null \
#     && make >/dev/null \
#     && make install \
#     && rm -rf $SRC_DIR/ImageMagick*


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
# Install java 1.8
# -----------------------------------------------------------------------------
#ADD files/jdk1.8.0_181.zip ${SRC_DIR}/
RUN cd ${SRC_DIR} \
    && wget -q -O jdk-11.zip http://10.100.0.9/docker-images-config/jdk-11.zip \
    && mkdir $HOME/java \
    && mv jdk-11.zip  $HOME/java \
    && cd $HOME/java \
    && unzip jdk-11.zip \
    && chmod a+x -R $HOME/java


# -----------------------------------------------------------------------------
# Install maven 3.5.4
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
    && wget -q -O maven.zip http://10.100.0.9/docker-images-config/maven.zip \
    && mv maven.zip  $HOME/ \
    && cd $HOME/ \
    && unzip maven.zip \
    && chmod a+x -R $HOME/maven



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



# -----------------------------------------------------------------------------
# Update Git and Config git
# -----------------------------------------------------------------------------
# RUN cd ${SRC_DIR} \
#     && yum -y remove git subversion \
#     && wget -q -O git-2.20.1.tar.gz https://github.com/git/git/archive/v2.20.1.tar.gz \
#     && tar zxf git-2.20.1.tar.gz \
#     && cd git-2.20.1 \
#     && make configure \
#     && ./configure --without-iconv --prefix=/usr/local/ --with-curl=/usr/bin/curl \
#     && make \
#     && make install \
#     && rm -rf $SRC_DIR/git-2* 
    
# -----------------------------------------------------------------------------
# Install gocronx
# -----------------------------------------------------------------------------
RUN mkdir -p ${HOME}/gocronx/
ADD gocronx ${HOME}/gocronx/ 
RUN chmod a+x -R ${HOME}/gocronx/
    
# -----------------------------------------------------------------------------
# Copy Config
# -----------------------------------------------------------------------------
ADD run.sh /
ADD config /vue-msf/
ADD config/.bash_profile /home/super/
ADD config/.bashrc /home/super/
ADD config/.vimrc /home/super/


ADD config/.bash_profile /root/
ADD config/.bashrc /root/
ADD config/.vimrc /root/

#	&& chmod a+x ${PHP_INSTALL_DIR}/bin/checkstyle \
#    && chmod a+x ${PHP_INSTALL_DIR}/bin/mergeCoverReport

ADD rpm/js-1.8.5-31.el8.x86_64.rpm /vue-msf/src/


RUN chmod a+x /run.sh \
    && yum install -y procps /vue-msf/src/js-1.8.5-31.el8.x86_64.rpm \
    && ln -s /usr/libexec/git-core/git-remote-http /bin/ \
    && ln -s /usr/libexec/git-core/git-remote-https /bin/ \
    && git config --global user.email "vue-msf@admin.com" \
    && git config --global user.name "vue-msf" \
    && curl -s -L http://github.com/micha/jsawk/raw/master/jsawk > /usr/local/bin/jsawk \
	&& chmod 755 /usr/local/bin/jsawk \
    && rm -rf ${SRC_DIR}/* \
    && yum --enablerepo=powertools install -y \
    libicu libicu-devel 



# -----------------------------------------------------------------------------
# Profile
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
    && echo -e 'PATH=$PATH:/vue-msf/nginx/bin/ \nPATH=$PATH:/vue-msf/sbin/ \nPATH=$PATH:/vue-msf/redis/bin/:/usr/libexec/git-core \nJAVA_HOME=/vue-msf/java \nexport JAVA_BIN=/vue-msf/java/bin \nexport PATH=$PATH:$JAVA_HOME/bin \nexport CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar \nexport JAVA_HOME JAVA_BIN PATH CLASSPATH \nexport CLASSPATH=.:$JAVA_HOME/bin:$JAVA_HOME/jre/bin \n#set maven enviroment\n \
export MAVEN_HOME=/vue-msf/maven \n \
export PATH=$PATH:$MAVEN_HOME/bin \n' >> /etc/profile \
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

# -----------------------------------------------------------------------------
# clean tmp file
# -----------------------------------------------------------------------------
RUN rm -rf ${SRC_DIR}/* \
	&& rm -rf /tmp/*

EXPOSE 22 80 443 8080 8000
ENTRYPOINT ["/run.sh"]
