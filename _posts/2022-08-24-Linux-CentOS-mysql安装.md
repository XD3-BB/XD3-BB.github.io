---
layout: post
tags: [运维, linux, CentOS, mysql, mysql5.7, 主主互备, 主从备份]
---

mysql数据库安装操作

## 一、清理数据

### 1、首先检查是否安装过mysql

rpm -qa | grep mysql 

若有则清理干净再安装

whereis mysql

找到文件夹目录，再把它删除。

rpm -e --nodeps mysql-xxxx

### 2、检查你系统是否自带mariadb，输入如下检查。

rpm -qa | grep mariadb 

如果有则需要把它卸载掉，因为会和Mysql引起冲突，输入如下卸载掉。

rpm -e --nodeps mariadb-libs

## 二、下载地址或者使用本地安装包

安装目录选择在/usr/local

cd /usr/local

### 1、下载

wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.39-linux-glibc2.12-x86_64.tar.gz

### 2、解压

tar -xzvf mysql-5.7.39-linux-glibc2.12-x86_64.tar.gz

### 3、修改文件目录

mv mysql-5.7.39-linux-glibc2.12-x86_64 mysql

### 4、更改mysql目录下所有的目录及文件夹所属组合用户

groupadd mysql  

useradd -r -g mysql mysql

chown -R mysql:mysql mysql/

chmod -R 777 mysql/

### 5、编辑配置文件

 vi /usr/local/mysql/my.cnf 

修改配置文件为如下：

```
[client]
#password=88888888
socket=/usr/local/mysql/mysql.sock

[mysql]
socket=/usr/local/mysql/mysql.sock
# 设置mysql客户端默认字符集
default-character-set=utf8

[mysqld]
pid-file=/usr/local/mysql/mysql.pid
log-error = /usr/local/mysql/log/mysql-error.log
#设置3306端口
port = 3306
# 设置mysql的安装目录
basedir=/usr/local/mysql
# 设置mysql数据库的数据的存放目录
datadir=/usr/local/mysql/data
#sock
socket=/usr/local/mysql/mysql.sock
# 允许最大连接数
max_connections=200
# 服务端使用的字符集默认为8比特编码的latin1字符集
character-set-server=utf8mb4
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
#允许时间类型的数据为零(去掉NO_ZERO_IN_DATE,NO_ZERO_DATE)
sql_mode=ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
#ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
lower_case_table_names=1
```

### 6、编译安装

创建data文件夹

mkdir /usr/local/mysql/data

执行安装，账号默认root**（需要注意最后行显示的是root的密码）**

/usr/local/mysql/bin/mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data --basedir=/usr/local/mysql 

添加文件夹

mkdir /usr/local/mysql/log

touch /usr/local/mysql/log/mysql-error.log

chmod -R 777 /usr/local/mysql/log

### 7、服务及mysql命令软链接

ln -s /usr/local/mysql/bin/mysql /usr/bin

ln -s /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql

### 8、启动服务并登入更改root密码

service mysql start

ln -s /usr/local/mysql/mysql.sock /tmp/mysql.sock

mysql -u root -p **刚刚编译生成的默认密码**

set password for root@localhost = password('**新密码**');

flush privileges;

### 9、设置远程登入：

use mysql;

update user set host='%' where host='localhost';

flush privileges; 

## 三、主从互备

### 1、修改配置文件

主库配置文件

vim /etc/my.cnf

```
[mysqld]
server_id=1
log-bin=mysql-bin
log-bin-index=master-bin.index
relay-log=relay-log
relay-log-index=relay-log.index
```

从库配置文件

vim /etc/my.cnf

```
[mysqld]
server_id=2
log-bin=mysql-bin
log-bin-index=master-bin.index
relay-log=relay-log
relay-log-index=relay-log.index
```

上面修改配置文件需重启服务

service mysql restart

### 2、登录主库设置授权从库

[root@servername fold]# mysql -u root -p

Enter password:（**密码输入不可见**）

mysql> grant replication slave on *.* to 'root'@'**从库的ip地址**' identified by '**从库主库连接密码**';

mysql>flush privileges;

查看master的状态

mysql>show master status;

![image-20220824221121472](C:\Users\19604\AppData\Roaming\Typora\typora-user-images\image-20220824221121472.png)

 主库进行锁表

mysql>flush tables with read lock;

### 3、从库配置操作

[root@servername fold]# mysql -u root -p

Enter password:（**密码输入不可见**）

mysql> change master to master_host='**主库ip地址**',master_user='root', master_password='**从库主库连接密码**',master_log_file='**主库File**',master_log_pos=（**主库position**）;

mysql>start slave;

查看连接状态

mysql>show slave status\G;

```
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 119.3.131.252
                   Master_User: root
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000007
           Read_Master_Log_Pos: 154
                Relay_Log_File: relay-log.000002
                 Relay_Log_Pos: 320
         Relay_Master_Log_File: mysql-bin.000007
              Slave_IO_Running: Yes				#此处两个地方
             Slave_SQL_Running: Yes				#全部为Yes即成功
               Replicate_Do_DB: 
           Replicate_Ignore_DB: 
            Replicate_Do_Table: 
        Replicate_Ignore_Table: 
       Replicate_Wild_Do_Table: 
   Replicate_Wild_Ignore_Table: 
          			Last_Errno: 0
          			Last_Error: 
         		  Skip_Counter: 0
     	   Exec_Master_Log_Pos: 154
      		   Relay_Log_Space: 521
       		   Until_Condition: None
        		Until_Log_File: 
        		 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File: 
            Master_SSL_CA_Path: 
    	  	   Master_SSL_Cert: 
     		 Master_SSL_Cipher: 
        		Master_SSL_Key: 
    	 Seconds_Behind_Master: 0
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error: 
                Last_SQL_Errno: 0
                Last_SQL_Error: 
   Replicate_Ignore_Server_Ids: 
       		  Master_Server_Id: 2
         		   Master_UUID: 8823ac3e-0983-11ed-97a9-fa163e59f44f
       		  Master_Info_File: /usr/local/mysql/data/master.info
              		 SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
          	Master_Retry_Count: 86400
        		   Master_Bind: 
       Last_IO_Error_Timestamp: 
      Last_SQL_Error_Timestamp: 
                Master_SSL_Crl: 
            Master_SSL_Crlpath: 
            Retrieved_Gtid_Set: 
             Executed_Gtid_Set: 
                 Auto_Position: 0
          Replicate_Rewrite_DB: 
                  Channel_Name: 
            Master_TLS_Version: 
1 row in set (0.00 sec)

ERROR: 
No query specified
```

### 4、解锁主库（别漏了）

mysql> unlock tables;

##  四、主主互备

主主互备、即将主从互备反过来，重新执行一遍流程即可