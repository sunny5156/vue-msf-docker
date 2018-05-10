1 、安装说明
Docker支持以下的CentOS版本：
CentOS 7 (64-bit)
CentOS 6.5 (64-bit) 或更高的版本

前提条件
目前，CentOS 仅发行版本中的内核支持 Docker。
Docker 运行在 CentOS 7 上，要求系统为64位、系统内核版本为 3.10 以上。
Docker 运行在 CentOS-6.5 或更高的版本的 CentOS 上，要求系统为64位、系统内核版本为 2.6.32-431 或者更高版本。

2、使用 yum 安装（CentOS 7下）
Docker 要求 CentOS 系统的内核版本高于 3.10 ，查看本页面的前提条件来验证你的CentOS 版本是否支持 Docker 。

#查看你当前的内核版本
uname -r

#安装 Docker
yum -y install docker

#启动 Docker 后台服务
service docker start

#测试运行 hello-world,由于本地没有hello-world这个镜像，所以会下载一个hello-world的镜像，并在容器内运行。
docker run hello-world
3、使用脚本安装 Docker
1、使用 sudo 或 root 权限登录 Centos。
2、确保 yum 包更新到最新。

#确保 yum 包更新到最新
sudo yum update

#执行 Docker 安装脚本,执行这个脚本会添加 docker.repo 源并安装 Docker。
curl -fsSL https://get.docker.com/ | sh

#启动 Docker 进程
sudo service docker start

#验证 docker 是否安装成功并在容器中执行一个测试的镜像
sudo docker run hello-world

到此，docker 在 CentOS 系统的安装完成。

