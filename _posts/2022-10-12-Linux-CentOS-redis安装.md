---
layout: post
tags: [运维, linux, CentOS, redis, redis集群]
---

redis是个好东西啊，编译安装需要gcc

**yum -y install gcc**

## 一、单机redis安装

### 1、下载

wget https://download.redis.io/releases/redis-6.2.7.tar.gz

### 2、解压

tar xzf redis-6.2.7.tar.gz

### 3、改名

mv redis-6.2.7 redis

### 4、编译安装

cd redis 

make && make install

### 5、修改配置

vi redis.conf

```
#注释掉绑定用于远程登陆
#bind 127.0.0.1 -::1
#这里讲原来的no改为yes,目的是为了设置后台运行
daemonize yes
#这里讲原来的yes改为no,目的是为了解决安全模式引起的报错
protected-mode no
#此处本来是注释状态，取消注释后，设置redis永远的登陆密码
requirepass redis连接密码
```

## 二、redis集群配置

redis集群最少要6个redis，资源有限，可以一台机器配置6个redis

### 1、创建配置路径

```
#配置存放路径
mkdir -p /usr/local/redis/6380
mkdir -p /usr/local/redis/6381
mkdir -p /usr/local/redis/6382
mkdir -p /usr/local/redis/6383
mkdir -p /usr/local/redis/6384
mkdir -p /usr/local/redis/6385
#日志存放路径
mkdir -p /usr/local/redis/logs
#redis数据库存放路径
mkdir -p /usr/local/redis/redisdata6380
mkdir -p /usr/local/redis/redisdata6381
mkdir -p /usr/local/redis/redisdata6382
mkdir -p /usr/local/redis/redisdata6383
mkdir -p /usr/local/redis/redisdata6384
mkdir -p /usr/local/redis/redisdata6385
```

### 2、拷贝修改配置

拷贝首份配置

cp /usr/local/redis/redis.conf /usr/local/redis/6380/

修改几个配置

vim /usr/local/redis/6380/redis.conf   

```
#端口
port 6380
#取消绑定
#bind 127.0.0.1  -::1
#开启集群
cluster-enabled yes
cluster-node-timeout 15000
#可后台运行
daemonize yes
#可远程连接
protected-mode no
#文件输出路径改下
cluster-config-file nodes-6380.conf
pidfile /var/run/redis_6380.pid
logfile "/usr/local/redis/logs/redis-6380.log"
dir /usr/local/redis/redisdata6380
#密码及master密码
requirepass redis连接密码
masterauth redis连接密码
```

其他库配置只需将首份配置拷贝，然后全局替换端口

```
cp /usr/local/redis/6380/redis.conf /usr/local/redis/6381/
cp /usr/local/redis/6380/redis.conf /usr/local/redis/6382/
cp /usr/local/redis/6380/redis.conf /usr/local/redis/6383/
cp /usr/local/redis/6380/redis.conf /usr/local/redis/6384/
cp /usr/local/redis/6380/redis.conf /usr/local/redis/6385/
```

```
vim /usr/local/redis/6381/redis.conf   
:%s/6380/6381/g
:wq
vim /usr/local/redis/6382/redis.conf   
:%s/6380/6382/g
:wq
vim /usr/local/redis/6383/redis.conf   
:%s/6380/6383/g
:wq
vim /usr/local/redis/6384/redis.conf   
:%s/6380/6384/g
:wq
vim /usr/local/redis/6385/redis.conf   
:%s/6380/6385/g
:wq
```

### 3、启动服务

```
/usr/local/redis/src/redis-server /usr/local/redis/6380/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/6381/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/6382/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/6383/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/6384/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/6385/redis.conf
```

以上设置，可以将他们放在不同服务器中，比如6380与6381在一台服务器，6382与6383在一台服务器，6384与6385在一台服务器

在其中一台服务器执行以下命令

src/redis-cli --cluster create   **6380redis所在ip:6380**    **6381redis所在ip:6381**      **6382redis所在ip:6382**      **6383redis所在ip:6383 **     **6384redis所在ip:6384**      **6385redis所在ip:6385**  --cluster-replicas 1 -a **redis连接密码**

都在一起可以使用127.0.0.1代替ip

src/redis-cli --cluster create 127.0.0.1:6380 127.0.0.1:6381 127.0.0.1:6382 127.0.0.1:6383 127.0.0.1:6384 127.0.0.1:6385  --cluster-replicas 1 -a redisPass

中间会询问几次，直接输入yes后回车,最后展示如下即表示成功

```
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

集群登录，挑一个节点登录即可

 src/redis-cli -h 127.0.0.1 -p 6380 -c -a 设置的密码

### 4、查看集群状态

cluster nodes

```
5e3d9195c01ce5ab069b3042e2e27171241814dc 127.0.0.1:6381@16381 master - 0 1661353971336 2 connected 5461-10922
601e269d458e6f2a6af9b183316e9cd3fc3bbeb1 127.0.0.1:6383@16383 slave 5e3d9195c01ce5ab069b3042e2e27171241814dc 0 1661353968324 2 connected
afb32dc53068eb5bfe3b544fd3ae5adfad29ea7f 127.0.0.1:6385@16385 slave 9a6b56517eceab367aebc0105238c010792aa36c 0 1661353970333 1 connected
f6b538e2df80fea1e948fda3024647bdccae3f33 127.0.0.1:6382@16382 master - 0 1661353970000 3 connected 10923-16383
b8e79566afa7b55b1a451024f50c142f658ec4a2 127.0.0.1:6384@16384 slave f6b538e2df80fea1e948fda3024647bdccae3f33 0 1661353968000 3 connected
9a6b56517eceab367aebc0105238c010792aa36c 127.0.0.1:6380@16380 myself,master - 0 1661353969000 1 connected 0-5460

```

## 附录

集群重启脚本，仅适用单服务器，按照以上方式配置的集群

```
ports=('6380' '6381' '6382' '6383' '6384' '6385')
path=/usr/local/custom/redis/
dataDirPre=redisdata

pid=`ps -ef | grep redis-server | grep -v grep | awk '{print $2}'`
if [ -z "$pid" ];
	then
		echo "[ not find pid ]"
else
	for id in $pid
		do
			echo "kill -9 pid:" $id
			kill -9 $id
		done
	echo "开始删除数据"
	for port in ${ports[@]}
 		do
			echo $path$port
			echo $path$dataDirPre$port
			rm -rf $path$port/dump.rdb
			rm -rf $path$port/appendonly.aof
			rm -rf $path$port/nodes-*.*
			rm -rf $path$dataDirPre$port/dump.rdb
			rm -rf $path$dataDirPre$port/appendonly.aof
			rm -rf $path$dataDirPre$port/nodes-*.*
		done
	echo "开始创建集群"
	for port in ${ports[@]}
		do
			str=$str" 127.0.0.1:"$port" "
			$path"src/redis-server" $path"/"$port"/redis.conf"
		done
	$path'src/redis-cli' --cluster create $str  --cluster-replicas 1 -a redisPass		
fi
echo "----------------------日志详见/usr/local/custom/redis/logs---------------"
```

