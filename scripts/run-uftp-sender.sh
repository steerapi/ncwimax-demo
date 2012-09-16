#!/bin/bash
ssh root@node1-1 'killall uftp'
ssh root@node1-1 'dd if=/dev/urandom of=output.dat bs=10000000 count=1'
ssh root@node1-1 'uftp -S 240 -H 10.41.14.2 output.dat -R 6000 -U -T -b 1400 -m 60 -W 5000%'
