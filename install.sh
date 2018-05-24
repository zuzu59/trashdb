#!/bin/bash
#Petit script pour installer tout le binz
#zf180524.1049
# source: https://doc.ubuntu-fr.org/docker

sudo apt-get update
sudo apt-get install python-minimal
./install_docker.sh
sudo usermod -aG docker ubuntu

echo ""
echo "vous devez faire un logoff/logon pour que les modifications de groups fonctionne !"
echo ""
