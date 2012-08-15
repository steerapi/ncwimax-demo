#!/bin/bash
#set up 2 nodes [1,1] and [1,2]
#[1,1] = server
#[1,2] = client
omf_tell offh all
omf_load [[1,1],[1,2]] ncwimax-demo.ndz
omf_tell offh all
sleep 60
omf_tell on [[1,1],[1,2]]
sleep 60
