---
layout: post
tags: [运维, linux, CentOS, maven]
---



maven版本查看https://dlcdn.apache.org/maven/maven-3/

安装maven，就四步

## 1、下载

wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz

## 2、解压

tar -zxvf apache-maven-3.8.6-bin.tar.gz

## 3、改名

mv apache-maven-3.8.6 maven

## 4、添加环境变量

放在末尾

vim /etc/profile

```
export MAVEN_HOME=/usr/local/maven/
export PATH=${PATH}:${MAVEN_HOME}/bin
```

