#!/bin/bash
# $1 = iperf [1 run 0 no]
# $2 = uftp [1 run 0 no]

echo ">>> Running Throughput and Loss Experiment. <<<"
#if [ $1 -eq 1 ]
#then
#reciever
ssh root@node1-2 'killall iperf'
ssh root@node1-2 'iperf -B 10.41.14.2 -usl 1400 -x CMSV -y c'
#sender
#ssh root@node1-1 'killall iperf'
#ssh root@node1-1 'sleep 1 && iperf -c 10.41.14.2 -ul 1400 -b 6m -t 30 -i 0.5 -x CMSV -y c'
#fi
