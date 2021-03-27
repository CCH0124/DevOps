#!/bin/sh
echo Swarm Init...
docker swarm init --listen-addr 192.168.100.200:2377 --advertise-addr 192.168.100.200:2377
docker swarm join-token --quiet worker > /vagrant/worker_token
