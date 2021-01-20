#!/bin/bash
# shellcheck disable=SC2015

test -f /var/tmp/disable-loki-docker-log-driver.trigger && exit 0

test -f /var/lib/docker/plugins/*/config.json && \
  grep -q loki-docker-driver /var/lib/docker/plugins/*/config.json && {
    grep -q loki /etc/docker/daemon.json || \
    cp /var/local/osshelp/docker-daemon.json /etc/docker/daemon.json
  }

exit 0
