#!/usr/bin/env bash

STACK_NAME=bhyoo

function deploy() {
  docker-compose -f "$1" config > /tmp/tmp.yml
  docker stack deploy --with-registry-auth -c /tmp/tmp.yml "$2"
  rm /tmp/tmp.yml
}

deploy 'registry.yml' "$STACK_NAME"
deploy 'traefik.yml' "$STACK_NAME"

deploy 'datadog.yml' 'datadog'
deploy 'postgresql.yml' "$STACK_NAME"

deploy 'portainer.yml' "$STACK_NAME"
deploy 'blackd.yml' "$STACK_NAME"
deploy 'pilgrim.yml' "$STACK_NAME"
