#!/bin/bash

test -f /var/tmp/disable-loki-docker-log-driver.trigger && exit 0

docker plugin ls | grep -q loki || {
  docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
  cp /var/local/osshelp/docker-daemon.json /etc/docker/daemon.json
  systemctl restart docker
}
