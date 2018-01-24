#!/bin/sh

# 更新应用程序错误码
CODE_UPDATE=100
# 版本信息文件
FILE_VERSION="/opt/ipnc/camera_ctl.version"
# 更新信息地址，获取到的是一个json字典，包括版本号和当前程序的md5
URL_UPDATE_INFO="http://update.xx.info.xxx.com/api/project/msg/iot_camera_ihx"
# 更新文件下载地址
URL_UPDATE_FILE="http://update.xx.file.xxx.com/api/project/download/iot_camera_ihx"

get_update()
{
    wget "$URL_UPDATE_INFO" -O /tmp/_up.info
    if [ "$?" != "0" ];then
        return $CODE_UPDATE
    else
        ver_get=`./json.sh /tmp/_up.info -s buildcode`
        md5_get=`./json.sh /tmp/_up.info -s updatecontent|tr [a-z] [A-Z]`
        if [ ! -f $FILE_VERSION ];then
            echo "0" >$FILE_VERSION
        fi
        ver_local=`cat $FILE_VERSION`
        
        # debug
        echo "version: get-$ver_get local-$ver_local"
        if [ "$ver_get" -gt "$ver_local" ]; then
            # get file
            wget "$URL_UPDATE_FILE" -O /tmp/camera_ctl.bin
            if [ "$?" != "0" ];then
                return $CODE_UPDATE
            else
                md5_local=`md5sum /tmp/camera_ctl.bin |cut -d" " -f 1|tr [a-z] [A-Z]`
                echo "md5: get-$md5_get local-$md5_local"
                if [ "$md5_get" = "$md5_local" ]; then
                    killall camera_ctl
                    cp /tmp/camera_ctl.bin /opt/ipnc/camera_ctl
                    chmod a+x /opt/ipnc/camera_ctl
                    echo "$ver_get" > $FILE_VERSION
                    echo "Update Success! Version: $ver_get"
                    return 0
                else
                    echo "md5 check failed"
                    return $CODE_UPDATE
                fi
            fi
        else
            return 0
        fi
    fi
}





while true
do
    get_update
    echo $?
    sleep 10
done