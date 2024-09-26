---
layout: post
tags: [运维, linux, CentOS, nginx]
---

官网挑选版本下载

http://nginx.org/en/download.html

## 一、安装依赖

yum -y install gcc pcre-devel zlib-devel openssl openssl-devel

## 二、下载

wget http://nginx.org/download/nginx-1.22.0.tar.gz

## 三、解压

tar -zxvf nginx-1.22.0.tar.gz

## 四、编译安装

mv nginx-1.22.0 nginx

cd nginx

./configure

make & make install 

## 五、启动

cd /usr/local/nginx/sbin

./nginx 

## 附：常用命令

```
#用某个路径下的配置启动
nginx -c /usr/local/nginx/conf/nginx.conf 
#快速关闭
nginx -s stop
#安全关闭
nginx -s quit
#重载配置
nginx -s reload
#重新打开一个日志文件
nginx -s reopen
#验证配置是否正确，后接路径，不接代表默认配置
nginx -t /home/test/conf/nginx.conf
```

