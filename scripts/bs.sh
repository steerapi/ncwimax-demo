#!/bin/bash
# $1 = harq
# $2 = arq
# 64-QAM (CTC) 5/6 at 20dBm

#set attenuator to normal
echo ">>> Reset attenuator <<<"
wget -qO- 'http://internal2dmz.orbit-lab.org:5052/instr/set?portA=2&portB=9&att=0'

echo ">>> Config base station parameters <<<"
wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/default'

wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/ulprofile?ulprof1=13&ulprof2=255&ulprof3=255&ulprof4=255&ulprof5=255&ulprof6=255&ulprof7=255&ulprof8=255&ulprof9=255&ulprof10=255'

wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/dlprofile?dlprof1=255&dlprof2=255&dlprof3=255&dlprof4=255&dlprof5=255&dlprof6=255&dlprof7=255&dlprof8=21&dlprof9=255&dlprof10=255?dlprof11=255&dlprof12=255'

wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/set?bs_tx_power=21'

if [ $1 -eq 1 ]
then
wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/harq?enable=true'
fi
if [ $2 -eq 1 ]
then
wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/arq?enable=true'
fi

echo ">>> Restart base station. Please wait 2 minutes <<<"
wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/restart'
ssh root@node1-1 reboot
ssh root@node1-2 reboot
sleep 120
