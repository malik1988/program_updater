#!/bin/sh
# 配置文件路径
URL_CONFIG="http://127.0.0.1:8081/api/config/file?app=camera&env=product&type=0&version=1.0.0&key=default.conf"
get_config()
{
    wget "$URL_CONFIG" -O /tmp/camera_ctl.conf
}
get_config
result=$?
while true
do
    if [ "$result" != "0" ];then
        get_config
    else
        /opt/ipnc/camera_ctl
        if [ "$?" = "4" ];then
            # 程序已经运行
            killall camera_ctl
        fi
    fi
    result=$?
    sleep 5
done