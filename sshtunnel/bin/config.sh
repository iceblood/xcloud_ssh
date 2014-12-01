#!/bin/sh
source /opt/app/sshtunnel/etc/config.txt
echo $Server
echo $Port
echo $User
echo $Pass
echo $gfwlist
echo $usegfwlist
echo $useadblock

Parameter_num=$#
if [ ${Parameter_num} -eq 7 ];then
server="$1"
port="$2"
user="$3"
password="$4"
gfwlist="$5"
usegfwlist="$6"
useadblock="$7"
echo Server=${server}>/opt/app/sshtunnel/etc/config.txt
echo Port=${port}>>/opt/app/sshtunnel/etc/config.txt
echo User=${user}>>/opt/app/sshtunnel/etc/config.txt
echo Pass=${password}>>/opt/app/sshtunnel/etc/config.txt
echo gfwlist=${gfwlist}>>/opt/app/sshtunnel/etc/config.txt
echo usegfwlist=${usegfwlist}>>/opt/app/sshtunnel/etc/config.txt
echo useadblock=${useadblock}>>/opt/app/sshtunnel/etc/config.txt

if [ ${usegfwlist} -eq 1 ];then
sed -i "s/.*actionsfile gfw\.action/actionsfile gfw\.action/g"  /opt/app/sshtunnel/etc/config/privoxy.config
else
sed -i "s/actionsfile gfw\.action/#actionsfile gfw\.action/g"  /opt/app/sshtunnel/etc/config/privoxy.config
fi

if [ ${useadblock} -eq 1 ];then
sed -i "s/.*actionsfile user\.action/actionsfile user\.action/g"  /opt/app/sshtunnel/etc/config/privoxy.config
sed -i "s/.*filterfile user\.filter/filterfile user\.filter/g"  /opt/app/sshtunnel/etc/config/privoxy.config
else
sed -i "s/actionsfile user\.action/#actionsfile user\.action/g"  /opt/app/sshtunnel/etc/config/privoxy.config
sed -i "s/filterfile user\.filter/#filterfile user\.filter/g"  /opt/app/sshtunnel/etc/config/privoxy.config
fi

fi