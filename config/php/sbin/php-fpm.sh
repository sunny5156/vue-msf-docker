#!/bin/sh

# Source networking configuration
. /etc/sysconfig/network

# worker account configuration
. /vue-msf/.bash_profile

# Source function library.
. /etc/rc.d/init.d/functions

ulimit -SHn 65535

function stop_php()
{
	printf "Stoping PHP...\n"
	pid=`ps -ef |grep php-fpm |grep master |awk '{print $2}'`
	/bin/kill ${pid}
}

function start_php()
{
	printf "Starting PHP...\n"
	/vue-msf/php/sbin/php-fpm -c /vue-msf/php/etc/php-fpm.ini
}

function kill_php()
{
	pid=`ps -ef |grep php-fpm |grep master |awk '{print $2}'`
	/bin/kill ${pid}
}

function restart_php()
{
	printf "Restarting PHP...\n"
	stop_php
	sleep 5
	start_php
}

if [ "$1" = "start" ]; then
    start_php
elif [ "$1" = "stop" ]; then
    stop_php
elif [ "$1" = "restart" ]; then
	restart_php
elif [ "$1" = "kill" ]; then
	kill_php
else
    printf "Usage: /vue-msf/php/sbin/php-fpm.sh {start|stop|restart|kill}\n"
fi
