#!/bin/bash
if [ ! -n "$1" ] ;then
 echo "缺少平台" 
 exit
fi
if [ ! -n "$2" ] ;then
 echo "缺少版本号" 
 exit
fi
BASE_DIR=/vue-msf/data/www
PROJECT=$1
PROJECT_DIR=$(echo $BASE_DIR/$PROJECT | tr '[A-Z]' '[a-z]') 
VERSION=$2

if [ ! -d ${BASE_DIR} ]; then
	mkdir -p ${BASE_DIR}
fi

curl -k -X POST -c ${BASE_DIR}/cookie.txt --url  http://git.sfc.com/user/login --data 'user_name=xast' --data 'password=xast123456'
curl -o ${BASE_DIR}/$PROJECT-$VERSION.zip -b ${BASE_DIR}/cookie.txt http://git.sfc.com/suntek/$PROJECT/archive/$VERSION.zip

#删除文件
rm -rf ${BASE_DIR}/cookie.txt

unzip -o -q ${BASE_DIR}/$PROJECT-$VERSION.zip -d ${BASE_DIR}

#chown super.super -R /vue-msf/data/www
touch /home/super/.publish

#生成supervisor conf

WORK_CONF="[program:${PROJECT}]\ncommand=/vue-msf/php/bin/php ${PROJECT_DIR}/Code/Backend/server.php \nprocess_name=${PROJECT} \nnumprocs=1 \ndirectory=/vue-msf/php/\numask=022\npriority=999\nautostart=true\nautorestart=true\nstartsecs=10\nstartretries=2\nexitcodes=0,2\nstopsignal=TERM\nstopwaitsecs=10\nuser=super\nredirect_stderr=true\nstdout_logfile=NONE\nredirect_stdout=true\nstderr_logfile=NONE"

echo -e $WORK_CONF >/vue-msf/supervisor/conf.d/${PROJECT}.conf

if [ -f /vue-msf/data/www/vendor.zip ]; then
	
	unzip -o -q /vue-msf/data/www/vendor.zip -d ${PROJECT_DIR}/Code/Backend/ 
	#cd ${PROJECT_DIR}/Code/Backend/ 
	#composer dump-autoload
	rm -rf /vue-msf/data/www/vendor.zip
	#supervisorctl -c /vue-msf/supervisor/supervisord.conf update
	
fi


