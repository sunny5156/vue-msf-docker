# vue-msf-docker
vue-msf-docker 基于 https://github.com/pinguo/php-msf-docker 修改而来

## supervisor 管理 服务

supervisorctl  

输入命令 supervisorctl 进入 supervisorctl 的 shell 交互界面（还是纯命令行😓），就可以在下面输入命令了。：

``` bash
supervisorctl help # 查看帮助
supervisorctl status # 查看程序状态
supervisorctl stop program_name # 关闭 指定的程序
supervisorctl start program_name # 启动 指定的程序
supervisorctl restart program_name # 重启 指定的程序
supervisorctl tail -f program_name # 查看 该程序的日志
supervisorctl update # 重启配置文件修改过的程序（修改了配置，通过这个命令加载新的配置)
```

## 已安装服务

php-fpm默认不启动,需要自己启动.

``` bash
1.nginx 1.13.5
2.php 7.1.25
3.php-fpm
4.redis 4.0.4 [redis6379,redis6380,redis6381,redis7379,redis7380,redis7381]
5.libmemcached
6.php composer
7.php swoole 1.9.23
8.git
9.ab
```

## Run

``` bash
docker run --privileged --restart=always -it -d  --hostname=vue-msf  --name=vue-msf-docker \
-p 2202:22 \
-p 80:80 \
-p 8000:8000 \
-p 8080:8080 \
-p 443:443 \
-p 6379:6379 \
-p 6380:6380 \
-p 6381:6381 \
-p 7379:7379 \
-p 7380:7380 \
-p 7381:7381 \
-v /d/PDT/data/html:/vue-msf/data/www \
daocloud.io/sunny5156/vue-msf-docker:latest

ps:/d/PDT/data/html 此路径修改成自己的路径
```

## ssh 登陆

``` bash
IP:127.0.0.1
端口:2202
账号:super
密码:123456
```

## 前端模块安装

``` javascript
sudo npm install 
```

## 代码热更新

``` bash
nodemon -L --exec "php" server.php start
```


```
/vue-msf/hhvm/bin/hhvm --hphp   -t hhbc  --input-dir /var/www   --output-dir /vue-msf/data/hhvm/cache/

/vue-msf/hhvm/bin/hhvm --hphp   -t hhbc   -v "AllDynamic=true"   --input-dir /var/www   --output-dir /var/cache/hhvm

/vue-msf/hhvm/bin/hhvm  --config /vue-msf/hhvm/etc/config.hdf --config /vue-msf/hhvm/etc/php.ini --config /vue-msf/hhvm/etc/server.ini --mode server
```

