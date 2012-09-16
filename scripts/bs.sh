#!/bin/bash
# $1 = harq
# $2 = arq
# 64-QAM (CTC) 5/6 at 21dBm

#set attenuator to normal
echo ">>> Reset attenuator <<<"
wget -qO- 'http://internal2dmz.orbit-lab.org:5052/instr/set?portA=2&portB=9&att=0'

echo ""
echo ">>> Config base station parameters <<<"

echo ">>> Reset BS params to default <<<"
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/default'`
reboot=0

echo ">>> Change UL profile to QPSK1/2 only <<<"
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/ulprofile?ulprof1=13&ulprof2=255&ulprof3=255&ulprof4=255&ulprof5=255&ulprof6=255&ulprof7=255&ulprof8=255&ulprof9=255&ulprof10=255' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  echo "reboot"
  reboot=1
fi

echo ">>> Change DL profile to 64-QAM(CTC) only <<<"
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/dlprofile?dlprof1=255&dlprof2=255&dlprof3=255&dlprof4=255&dlprof5=255&dlprof6=255&dlprof7=255&dlprof8=21&dlprof9=255&dlprof10=255?dlprof11=255&dlprof12=255' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  reboot=1
fi

echo ">>> Change BS TX Power to 21dBm<<<"
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/set?bs_tx_power=21' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  reboot=1
fi

if [ $1 -eq 1 ]
then
echo ">>> Enable HARQ <<<"
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/harq?enable=true' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  reboot=1
fi
else
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/harq?enable=false' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  reboot=1
fi  
fi

if [ $2 -eq 1 ]
then
echo ">>> Enable ARQ <<<"
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/arq?enable=true' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  reboot=1
fi
else
cmd=`wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/arq?enable=false' | grep 'reboot'`
chk=`echo $cmd | wc -w`
if [ $chk -gt 0 ]; then 
  reboot=1
fi
fi

if [ $reboot -eq 1 ];
then
echo ""
echo ">>> Restart base station and nodes. Node status report may change during this time. This can take up to 3 minutes. <<<"
wget -qO- 'http://wimaxrf:5052/wimaxrf/bs/restart'
ssh root@node1-1 reboot
ssh root@node1-2 reboot
sleep 120
fi
