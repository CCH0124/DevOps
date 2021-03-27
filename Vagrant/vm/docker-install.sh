#!/bin/sh
curl -sSL https://get.docker.com/ | sudo sh
sudo usermod -aG docker $USER
sudo swapoff -a && sudo sysctl -w vm.swappiness=0
sudo sed '/vagrant--vg-swap/d' -i /etc/fstab
