#!/bin/sh

iptables -t nat -A PREROUTING -i br-lan -p tcp --dport 80 -j REDIRECT --to-ports 8118
iptables -t nat -A PREROUTING -i br-lan -p udp --dport 53 -j REDIRECT --to-ports 5353
iptables -t nat -A PREROUTING -i br-lan -p tcp --dport 443 -j REDIRECT --to-ports 1082

mkdir -p /tmp/run
PIDFILE="/tmp/run/sshtunnel"

#start-stop-daemon -K -n privoxy
#start-stop-daemon -K -n chinadns
#start-stop-daemon -K -n redsocks2
#start-stop-daemon -K -n sshtunnel.sh
#start-stop-daemon -K -n sshpass

eval ethip=$(/sbin/ifconfig br-lan|grep inet|grep -v inet6|awk '{print $2}'|tr -d 'addr:')
#echo $ethip
sed -i "s/ip = .*/ip = $ethip;/g"  /opt/app/sshtunnel/etc/config/redsocks2.conf
sed -i "s/forward-socks5 .*:1880/forward-socks5 $ethip:1880/g"  /opt/app/sshtunnel/etc/config/gfw.action
sed -i "s/forward-socks5 .*:1880/forward-socks5 $ethip:1880/g"  /opt/app/sshtunnel/etc/config/temp.action
start-stop-daemon -S -x ./privoxy -- --pidfile /tmp/run/privoxy.pid /opt/app/sshtunnel/etc/config/privoxy.config
start-stop-daemon -S -b -x ./chinadns -- -l /opt/app/sshtunnel/etc/config/chinadns_iplist.txt -c /opt/app/sshtunnel/etc/config/chinadns_chnroute.txt -p 5353
start-stop-daemon -S -b -x ./redsocks2 -- -c /opt/app/sshtunnel/etc/config/redsocks2.conf

retrydelay="10"
server="$1"
port="$2"
user="$3"
password="$4"

while true
do
	local L_ConnCheck=`./sshpass  -p $password ./ssh -l$user $server -p $port -o StrictHostKeyChecking=no echo ok`
	logger -p daemon.info -t "sshtunnel[$$][$server]" "connection started"
	start-stop-daemon -S -b -x ./sshpass -- -p $password ./ssh -NT -D $ethip:1880 -l $user $server -p $port -o StrictHostKeyChecking=no 
 	
	while [  ${L_ConnCheck} = "ok" ]
	do
		#echo live
		L_ConnCheck=`./sshpass  -p $password ./ssh -l$user $server -p $port -o StrictHostKeyChecking=no echo ok`
		sleep "$retrydelay" & wait
		 
	done
		#echo error
		logger -p daemon.info -t "sshtunnel[$$][$server]" "ssh cannot connect, reconnecting..."
		#start-stop-daemon -K -n ssh
		kill -9 $(ps |grep -E './ssh'|grep -Ev './sshpass|./sshtunnel'|awk '{print $1}')
		sleep "$retrydelay" & wait
done
