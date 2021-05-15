#!/usr/bin/env bash

source .env

set -x

docker network create --driver=overlay traefik-public
docker network create --driver=overlay datadog

docker secret create custom_certificate cert/"${DOMAIN?Variable not set}".pem
docker secret create custom_private_key cert/"${DOMAIN?Variable not set}".key
docker secret create custom_ca cert/"${DOMAIN?Variable not set}".ca
docker secret create htpasswd secrets/htpasswd
docker secret create postgres_user secrets/postgres_user
docker secret create postgres_passwd secrets/postgres_passwd

docker config create traefik_tls.yml conf/traefik_tls.yml