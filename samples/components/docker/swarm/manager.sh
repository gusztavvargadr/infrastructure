#!/bin/bash

# TODO: check if already member

if [ ! -f '/vagrant/.vagrant/docker-swarm-join-ip' ];
then
  hostname -I | awk '{print $1}' > /vagrant/.vagrant/docker-swarm-join-ip

  docker swarm init --advertise-addr eth0
  docker swarm join-token manager -q > /vagrant/.vagrant/docker-swarm-join-token-manager
  docker swarm join-token worker -q > /vagrant/.vagrant/docker-swarm-join-token-worker

  docker stack deploy -c /vagrant/stacks/core/docker-compose.yml core
else
  docker swarm join --token `cat /vagrant/.vagrant/docker-swarm-join-token-manager` `cat /vagrant/.vagrant/docker-swarm-join-ip`:2377
fi
