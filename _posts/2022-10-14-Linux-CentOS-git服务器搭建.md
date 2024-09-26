---
layout: post
tags: [运维, linux, CentOS, git, git服务器, 自动部署]
---

文章来源： https://www.runoob.com/git/git-server.html

## 1、安装Git[root用户]

```
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-devel
yum install git
```

创建一个git用户组和用户，用来运行git服务：

```
groupadd git
useradd git -g git
passwd git
//设置密码
```

## 2、创建证书登录[root用户]

将我们的公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。

公钥位于本地的C:\Users\用户名\ .ssh\id_rsa.pub文件

```
cd /home/git/
mkdir .ssh
chmod 755 .ssh
touch .ssh/authorized_keys
chmod 644 .ssh/authorized_keys
chown git:git .ssh/
```



## 3、初始化Git仓库[root用户]

首先我们选定一个目录作为Git仓库，假定是/usr/local/gitRepo/demo.git，在/usr/local/gitRepo目录下输入命令：

```
cd /usr/local
mkdir gitRepo
chown git:git gitRepo/
cd gitRepo

git init --bare demo.git

//Initialized empty Git repository in /usr/local/gitRepo/demo.git/
```

以上命令Git创建一个空仓库，服务器上的Git仓库通常都以.git结尾。然后，把仓库所属用户改为git：

```
chown -R git:git demo.git
```

## 4、克隆仓库[Git用户]

```
git clone git@127.0.0.1:/usr/local/gitRepo/demo.git

Cloning into 'runoob'...
warning: You appear to have cloned an empty repository.
Checking connectivity... done.
```

192.168.45.4 为 Git 所在服务器 ip ，你需要将其修改为你自己的 Git 服务 ip。

这样我们的 Git 服务器安装就完成。

## 5、整点好玩的  git仓库触发提交[Git用户]

修改云端仓库hooks中的post-receive函数

```
cd /usr/local/gitRepo/demo.git/hooks
vim post-receive
```

```
#!/bin/sh
read local_ref local_sha remote_ref remote_sha
DIR=`pwd`
DIR=${DIR%.*}
branch=${remote_ref##*/}
cd ${DIR}
unset GIT_DIR
echo "${branch}开始拉取，项目文件夹`pwd`"
chmod 755 restart-demo.sh
./restart-demo.sh ${branch}
```

```
chmod 755 post-receive
```

服务器拉取项目

```
mkdir /usr/local/gitRepo/demo
cd /usr/local/gitRepo/
git init demo
cd demo
git config --local user.name "xc"
git config --local user.email '1960481101@qq.com'
ssh-keygen -t rsa
```

找到生成的文件的公钥/home/git/.ssh/id_rsa.pub，添加到 /home/git/.ssh/authorized_keys,然后克隆项目

```
cd /usr/local/gitRepo/demo
git remote add origin git@127.0.0.1:/usr/local/gitRepo/demo.git
git pull
```

项目中创建脚本  restart-demo.sh

脚本在项目最外侧，方便,mvn位置自己改

```
#! /bin/bash
date

updateBranch=master

branch=$1
if [ "$branch" ! = "$updateBranch" ]; then
  echo "分支为${updateBranch}才进行更新"
  exit 1
fi

repoPath=$(pwd)
profile=$branch
cd $repoPath
git reset --hard origin/$branch
git checkout -f -b cache origin/$branch
git branch -D $branch
git checkout -f -b $branch origin/$branch
git branch -D cache
git pull --no-edit

/usr/local/custom/maven/bin/mvn clean package -P$profile

cd target
file=$(ls *.jar | awk '{print $1}')
sp_pid=$(ps -ef | grep $file | grep -v grep | awk '{print $2}')
if [ -z "$sp_pid" ]; then
  echo "[ not find sp-tomcat pid ]"
else
  echo "find result: $sp_pid "
  kill -9 $sp_pid
fi
logPath=$repoPath/${file%.*}.out
nohup java -jar $file >$logPath 2>&1 &
echo "--启动ok,日志见$logPath--"

```

将项目代码文件夹其拥有者设置为git

注意，项目中所有输出路径都需要用户git有操作权限
