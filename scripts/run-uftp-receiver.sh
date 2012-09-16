#!/bin/bash

echo ">>> Running File Transfer Experiment. This may take up to 10 minutes. <<<"
ssh root@node1-2 'killall uftpd'
ssh root@node1-2 'uftpd -H 10.14.1.1 -B 10000000 -D /tmp/'
