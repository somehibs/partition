#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "root please"
	exit
fi

if [ $# -gt 0 ]; then
	adapter=$3
else
	read -p 'adapter (opt): ' adapter
fi

sudo iptables -t nat -A PREROUTING -i $adapter'0' -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353
sudo iptables -t nat -A PREROUTING -i $adapter'0' -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040

