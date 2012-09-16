#!/bin/bash

ssh root@node1-1 'ls | grep amazingnc | wc -l'
ssh root@node1-2 'ls | grep amazingnc | wc -l'
