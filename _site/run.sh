#!/bin/bash

# 获取第一个参数
ACTION=$1

# 获取 Jekyll 进程的 PID
PID=$(pgrep -f jekyll)

if [ "$ACTION" = "start" ]; then
    if [ -n "$PID" ]; then
        # 如果 Jekyll 进程已经存在，杀掉它
        kill "$PID"
        echo "Jekyll exists, PID: $PID, now killed."
    fi
    nohup jekyll serve > /dev/null 2>&1 &
    echo "Jekyll started"
elif [ "$ACTION" = "stop" ]; then
    if [ -n "$PID" ]; then
        # 杀掉 Jekyll 服务进程
        kill "$PID"
        echo "Jekyll killed, PID: $PID"
    else
        echo "Jekyll is not running."
    fi
else
    echo "Invalid parameters. Please use 'start' or 'stop'."
fi
