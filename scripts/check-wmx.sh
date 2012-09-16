#!/bin/bash

cmd=`ssh root@node1-2 'wimaxcu status' | grep 'Connected'`
chk=`echo $cmd | tr -d '\n'`
if [ '$chk' ]; then 
then
  echo "connect"
fi
