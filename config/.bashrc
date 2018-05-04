# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions
PATH=$PATH:$HOME/bin:$HOME/php/bin:$HOME/nginx/sbin:$HOME/memcached/bin:$HOME/redis/bin
export PATH

alias supervisorctl='php /vue-msf/supervisor/msf.php;supervisorctl -c /vue-msf/supervisor/supervisord.conf'
alias logn="tail -F /vue-msf/data/nginx/logs/* /vue-msf/data/nginx/logs/*"
alias logp="tail -F /vue-msf/data/php/log/*"
alias logr="tail -F /vue-msf/data/www/runtime/*/*.log"
