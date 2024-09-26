---
layout: post
tags: [运维, linux, CentOS, 服务]
---

脚本内的地址需要写全路径，且需以

**#! /bin/bash**

开头



创建 你的服务.service 文件

```
[Unit]
Description=test
After=network.target

[Service]
Type=forking
ExecStart=启动操作时执行的脚本
ExecReload=重新启动操作时执行的脚本
ExecStop=关闭操作时执行的脚本
PrivateTmp=true

 [Install]
WantedBy=multi-user.target
```



复制脚本到系统服务中 /usr/lib/systemd/system/

systemctl daemon-reload 

systemctl start 你的服务

设置开机自启

systemctl enable 你的服务