#!/bin/bash
#Petit script pour installer tout le binz
#zf180523.1825
# source: https://hub.docker.com/r/library/couchdb/ et http://couchdb.apache.org/

sudo apt-get update
./install_docker.sh
sudo usermod -aG docker ubuntu

echo "vous devez faire un logoff/logon pour que cela soit en fonction !"





