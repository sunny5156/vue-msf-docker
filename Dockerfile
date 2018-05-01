FROM centos:centos7

MAINTAINER sunny5156 <sunny5156@qq.com>

# -----------------------------------------------------------------------------
# Make src dir
# -----------------------------------------------------------------------------
ENV HOME /vue-msf
ENV SRC_DIR $HOME/src
RUN mkdir -p ${SRC_DIR}
#ADD src ${SRC_DIR}

# -----------------------------------------------------------------------------
# Install Development tools
# -----------------------------------------------------------------------------
RUN rpm --import /etc/pki/rpm-gpg/RPM* \
    && curl --silent --location https://raw.githubusercontent.com/nodesource/distributions/master/rpm/setup_7.x | bash - \
    && yum -y update \
    && yum groupinstall -y "Development tools" \
    && yum install -y gcc gcc-c++ zlib-devel bzip2-devel openssl which \
    openssl-devel ncurses-devel sqlite-devel wget \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all

# -----------------------------------------------------------------------------
# Change yum repos
# -----------------------------------------------------------------------------
#RUN cd /etc/yum.repos.d
#RUN mv CentOS-Base.repo CentOS-Base.repo.bk
#RUN wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
#RUN mv CentOS7-Base-163.repo CentOS-Base.repo && yum clean all
RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo


# -----------------------------------------------------------------------------
# Update Python to 2.7.x
# -----------------------------------------------------------------------------
RUN cd ${SRC_DIR} \
#RUN wget https://bootstrap.pypa.io/ez_setup.py -O - | python 
#ADD config/easy_install/ez_setup.py  ${SRC_DIR}/ez_setup.py
#RUN python ${SRC_DIR}/ez_setup.py 
#easy_install pip \

# -----------------------------------------------------------------------------
# Devel libraries for delelopment tools like php & nginx ...
# -----------------------------------------------------------------------------
RUN yum -y install \
    tar gzip bzip2 unzip file perl-devel perl-ExtUtils-Embed \
    pcre openssh-server openssh sudo \
    screen vim git telnet expat \
    lemon net-snmp net-snmp-devel \
    ca-certificates perl-CPAN m4 \
    gd libjpeg libpng zlib libevent net-snmp net-snmp-devel \
    net-snmp-libs freetype libtool-tldl libxml2 unixODBC \
    libxslt libmcrypt freetds \
    gd-devel libjpeg-devel libpng-devel zlib-devel \
    freetype-devel libtool-ltdl libtool-ltdl-devel \
    libxml2-devel zlib-devel bzip2-devel gettext-devel \
    curl-devel gettext-devel libevent-devel \
    libxslt-devel expat-devel unixODBC-devel \
    openssl-devel libmcrypt-devel freetds-devel \
    pcre-devel openldap openldap-devel libc-client-devel \
    jemalloc jemalloc-devel inotify-tools nodejs apr-util yum-utils tree \
    && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all
    


RUN echo "root:123456" | chpasswd


##ENTRYPOINT ["/run.sh"]

EXPOSE 22 80 443 8080 8000

##CMD ["/usr/sbin/sshd", "-D"]

