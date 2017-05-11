#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "root please"
	exit
fi

if [ $# -gt 0 ]; then
	ns=$1
	ip=$2
	adapter=$3
else
	read -p 'namespace: ' ns
	read -p 'ip (xxx.xxx.xxx only) ' ip
	read -p 'adapter (opt): ' adapter
fi

if [ -z $adapter ]; then
	adapter=$ns
fi

function netns {
	ip netns exec $ns $1
}

# make a namespace
ip netns add $ns
# create pair of veth links
ip link add $adapter"0" type veth peer name $adapter"1"
ip link set $adapter"0" up
# put adapter 1 in the namespace
ip link set $adapter"1" netns $ns up
# set up ip to route between
ip addr add $ip'.1/24' dev $adapter'0'
ip netns exec $ns ip addr add $ip'.2/24' dev $adapter'1'
ip netns exec $ns ip route add default via $ip'.1' dev $adapter'1'
# give the namespace a loopback adapter
netns "ip addr add 127.0.0.1/8 dev lo"
netns "ip link set lo up"

# optional: change the dns server used by the network namespace
mkdir -p /etc/netns/$ns
