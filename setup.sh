#!/usr/bin/env bash

source .env

set -x

docker network create --driver=overlay traefik-public
docker network create --driver=overlay datadog

docker secret create web_certificate cert/"${DOMAIN?Variable not set}".pem
docker secret create web_private_key cert/"${DOMAIN?Variable not set}".key
docker secret create htpasswd htpasswd

docker config create traefik_tls.yml conf/traefik_tls.yml