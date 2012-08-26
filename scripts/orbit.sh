#!/bin/bash
#set up 2 nodes [1,1] and [1,2]
#[1,1] = server
#[1,2] = client

echo ">>> Setting up node. Please wait 10 minutes. <<<"

omf_tell offh [[1,1],[1,2]]
sleep 180
omf_load [[1,1],[1,2]] ncwimax-demo.ndz
omf_tell offh [[1,1],[1,2]]
sleep 180
omf_tell on [[1,1],[1,2]]
sleep 180
