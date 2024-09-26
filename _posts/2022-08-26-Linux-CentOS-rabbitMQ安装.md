---
layout: post
tags: [运维, linux, CentOS, rebbitMQ]
---

文档提供RabbitMQ版本3.10.7，Erlang版本25.0.3，Linux版本CenterOS7.9

## 零、版本对应

https://www.rabbitmq.com/which-erlang.html

## 一、EPEL安装

官方文档：

https://docs.fedoraproject.org/en-US/epel/#_quickstart

yum install -y epel-release

## 二、Erlang安装

首先安装依赖：

yum -y install gcc glibc-devel make ncurses-devel openssl-devel xmlto perl wget gtk2-devel binutils-devel

然后，区分安装方式

### 1、yum安装（未经试验）

openssl版本限定只能是1.0.1，且编译时CFLAG参数添加-fPIC

获取需要的版本的rpm包

https://www.erlang-solutions.com/downloads/

然后将链接用于wget

wget https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_25.0.3-1~centos~7_amd64.rpm

此处↓可能会遇到问题①

rpm -Uvh esl-erlang_25.0.3-1~centos~7_amd64.rpm 

rpm --import https://packages.erlang-solutions.com/rpm/erlang_solutions.asc

vi /etc/yum.repos.d/erlang_solutions.repo

```
[erlang-solutions]
name=CentOS $releasever - $basearch - Erlang Solutions
baseurl=https://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
enabled=1
```

sudo yum install erlang

### 2、源码编译安装

这玩意儿不好装啊，环境要求真鸡儿多

#### 1.依赖环境安装

依赖环境一堆，wxWidgets 到这里下载https://www.wxwidgets.org/downloads/

```
yum install unixODBC-devel
yum list *gtk+*
yum install mesa*
bzip2 -dkv wxWidgets-3.2.0.tar.bz2
tar -xvf wxWidgets-3.2.0.tar
cd wxWidgets-3.2.0/
./configure --with-opengl --enable-debug --enable-unicode
#这个好久。
make && make install
#测试
wx-config
```

#### 2.开装

git地址，那需要的版本链接

https://github.com/erlang/otp/releases

wget https://github.com/erlang/otp/releases/download/OTP-25.0.3/otp_src_25.0.3.tar.gz

```
tar -zxvf otp_src_25.0.3.tar.gz
mv otp_src_25.0.3 erlang_opt
cd erlang_opt
mkdir ../erlang
./configure --prefix=/usr/local/custom/erlang
```

有这个info不管他

 wx：Widgets was not compiled with --enable-webview or wxWebView developer package is not installed, wxWebView will NOT be available

直接执行

```
make && make install
```

vim /etc/profile

```
export PATH=$PATH:/usr/local/custom/erlang/bin
```

source /etc/profile

erl

```
Erlang/OTP 25 [erts-13.0.3] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [jit:ns]
Eshell V13.0.3  (abort with ^G)
halt().
#这个Erlang/OTP 25的25就是版本号
```



## 三、安装RabbitMQ

官网选择需要的版本

https://github.com/rabbitmq/rabbitmq-server/releases

wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.10.7/rabbitmq-server-generic-unix-3.10.7.tar.xz

yum install -y xz

 xz -d rabbitmq-server-generic-unix-3.10.7.tar.xz

tar -xvf rabbitmq-server-generic-unix-3.10.7.tar

mv rabbitmq_server-3.10.7/ /usr/local/

mv /usr/local/rabbitmq_server-3.10.7 /usr/local/rabbitmq

echo 'export PATH=$PATH:/usr/local/rabbitmq/sbin' >> /etc/profile

source /etc/profile

```
#启动
rabbitmq-server -detached
#停止
rabbitmqctl stop
#状态
rabbitmqctl status
#开启web插件
rabbitmq-plugins enable rabbitmq_management
```

开启端口15672

登录默认账号：guest/ guest

注意，安全起见rabbitmq3.3.0之后，默认情况下rabbitmq的guest/guest账户将不能实现远程登录，只能在本地登录。

解决方案：创建远程登陆账户

```
#查看用户列表
rabbitmqctl list_users
#新增账户
rabbitmqctl add_user 用户名 密码
#设置角色
#用户角色可以分为超级管理员administrator、监控者monitoring、策略制定者policymaker、普通管理者management等
rabbitmqctl set_user_tags 用户名 administrator
#赋予权限
rabbitmqctl set_permissions -p / 用户名 "." "." ".*"
#忘记密码更新密码
rabbitmqctl  change_password  用户名 新密码
```



## 附录

### 附带学习简单队列git项目

https://download.csdn.net/download/zpcandzhj/10585077

### 可能遇到的问题

①yum安装报了这个

```
错误：依赖检测失败：
        libcrypto.so.10()(64bit) 被 esl-erlang-25.0.3-1.x86_64 需要
        libcrypto.so.10(OPENSSL_1.0.1_EC)(64bit) 被 esl-erlang-25.0.3-1.x86_64 需要
        libcrypto.so.10(OPENSSL_1.0.2)(64bit) 被 esl-erlang-25.0.3-1.x86_64 需要
        libcrypto.so.10(libcrypto.so.10)(64bit) 被 esl-erlang-25.0.3-1.x86_64 需要
        libodbc.so.2()(64bit) 被 esl-erlang-25.0.3-1.x86_64 需要
```

解决：

wget http://www.openssl.org/source/openssl-1.0.1f.tar.gz

tar zxvf openssl-1.0.1f.tar.gz

cd openssl-1.0.1f

./config --prefix=/opt/ssl （下载目录）

vim Makefile

```
#CFLAG参数列表里加上-fPIC
CC= gcc  
CFLAG= -fPIC -DOP........
```

make && make install

此时可能报错

```
POD document had syntax errors at /usr/bin/pod2man line 69.
make: *** [Makefile:641：install_docs] 错误 255
```

找到pod2man对应行数直接注释	

然后指定ssl路径编译安装

 ./configure --with-ssl=/opt/ssl/ --prefix=/opt/erlang

make && make install