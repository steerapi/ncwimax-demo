#!/bin/bash
#set up 2 nodes [1,1] and [1,2]
#[1,1] = server
#[1,2] = client

echo ">>> Setting up node. Please wait... <<<"
omf-5.3 tell -a offh -t node1-1.sb4.orbit-lab.org,node1-2.sb4.orbit-lab.org
sleep 10
omf-5.3 load -i ncwimax-demo.ndz -t node1-1.sb4.orbit-lab.org,node1-2.sb4.orbit-lab.org
omf-5.3 tell -a offh -t node1-1.sb4.orbit-lab.org,node1-2.sb4.orbit-lab.org
sleep 10
omf-5.3 tell -a on -t node1-1.sb4.orbit-lab.org,node1-2.sb4.orbit-lab.org
sleep 10
echo ">>> Done setting up node. <<<"
