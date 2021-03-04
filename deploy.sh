#!/usr/bin/env bash

STACK_NAME=bhyoo

function deploy() {
  docker-compose -f "$1" config > /tmp/tmp.yml
  docker stack deploy --prune -c /tmp/tmp.yml "$STACK_NAME"
  rm /tmp/tmp.yml
}

deploy 'traefik.yml'
deploy 'portainer.yml'
deploy 'registry.yml'
deploy 'pilgrim.yml'
