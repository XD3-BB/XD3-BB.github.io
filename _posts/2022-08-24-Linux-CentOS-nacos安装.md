---
layout: post
tags: [运维, linux, CentOS, nacos]
---

nacos注册中心，需要安装maven作为前置

nacos查看版本

https://github.com/alibaba/nacos/releases

## 一、下载

wget https://github.com/alibaba/nacos/releases/download/1.4.3/nacos-server-1.4.3.tar.gz

## 二、解压

tar -zxvf nacos-server-1.4.3.tar.gz

## 三、数据源配置

vim nacos/conf/application.properties

```
#几个重要配置
#数据库连接类型
spring.datasource.platform=mysql
#数据库链接数量
db.num=1
#数据库连接路径
db.url.0=jdbc:mysql://127.0.0.1:3306/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
#数据库账号
db.user.0=root
#数据库密码
db.password.0=password
#是否开启用户认证，开启后，项目启动连接nacos时，需要配置连接账号密码（nacos登录账号密码）
nacos.core.auth.enabled=true
```

### 四、nacos启动

sh nacos/bin/startup.sh -m standalone

查看启动状态

tail -100f nacos/logs/start.out