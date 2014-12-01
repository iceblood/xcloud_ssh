#!/bin/sh
urls="$1"
eval ethip=$(/sbin/ifconfig br-lan|grep inet|grep -v inet6|awk '{print $2}'|tr -d 'addr:')
echo {+forward-override{forward-socks5 ${ethip}:1880 .}}>/opt/app/sshtunnel/etc/config/temp.action
echo -e "${urls}">>/opt/app/sshtunnel/etc/config/temp.action