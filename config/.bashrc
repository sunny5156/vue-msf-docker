# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions
PATH=$PATH:$HOME/bin:$HOME/php/bin:$HOME/nginx/sbin:$HOME/memcached/bin:$HOME/redis/bin
export PATH

alias supervisorctl='supervisorctl -c /vue-msf/supervisor/supervisord.conf'
