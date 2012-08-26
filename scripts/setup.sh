#!/bin/bash
# $1 nc [1 on 0 off]

echo ">>> Setting up WiMAX Link. <<<"

#wimax
#server
ssh root@node1-1 'route add 10.41.14.2 gw 10.14.0.1'
#client
ssh root@node1-2 'wimaxcu dconnect'
ssh root@node1-2 'wimaxcu scan'
ssh root@node1-2 'wimaxcu connect network 51'
ssh root@node1-2 'dhclient wmx0'
ssh root@node1-2 'route del default gw 10.41.0.1'
ssh root@node1-2 'route add 10.14.1.1 gw 10.41.0.1'

#nc
if [ $1 -eq 1 ]
then
echo ">>> Setting up NC. <<<"
# server
ssh root@node1-1 'killall ncencoder'
ssh root@node1-1 'iptables -F'
ssh root@node1-1 'iptables -A OUTPUT ! -p 252 -d 10.41.14.2 -j NFQUEUE --queue-num 1'
ssh root@node1-1 'iptables -A INPUT -s 10.41.14.2 -p 252 -j NFQUEUE --queue-num 0'
# client
ssh root@node1-2 'killall ncdecoder'
ssh root@node1-2 'iptables -F'
ssh root@node1-2 'iptables -A INPUT -p 252 -s 10.14.1.1 -j NFQUEUE --queue-num 0'
fi
