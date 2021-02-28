#!/usr/bin/env bash

function deploy() {
  docker-compose -f "$1" config > /tmp/tmp.yml
  docker stack deploy -c /tmp/tmp.yml "${1%.yml}"
  rm /tmp/tmp.yml
}

deploy 'traefik.yml'
deploy 'portainer.yml'
