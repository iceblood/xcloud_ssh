#!/bin/sh
cd /opt/app/sshtunnel/bin/
server="$1"
rm -f /opt/app/sshtunnel/etc/config/gfwlist.txt
rm -f /opt/app/sshtunnel/etc/config/gfwlist.tmp
./wget-ssl -t3 -O /opt/app/sshtunnel/etc/config/gfwlist.txt $server #https://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt
sck=$(du -k /opt/app/sshtunnel/etc/config/gfwlist.txt|awk '{print $1}')
if [ $sck -le 50 ];then  
    rm -f /opt/app/sshtunnel/etc/config/gfwlist.txt
else
    ./base64.sh -d  /opt/app/sshtunnel/etc/config/gfwlist.txt > /opt/app/sshtunnel/etc/config/gfwlist.tmp
    ln -s /proc/self/fd /dev/
    ./autoproxy2privoxy /opt/app/sshtunnel/etc/config/gfwlist.tmp > /opt/app/sshtunnel/etc/config/gfw.action
fi
rm -f /opt/app/sshtunnel/etc/config/gfwlist.txt
rm -f /opt/app/sshtunnel/etc/config/gfwlist.tmp