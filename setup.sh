#!/usr/bin/env bash

REQUIRED_PACKAGES=('docker-ce' 'glusterfs-server')
REQUIRED_ENVS=('GLUSTERFS_SERVERS')
REQUIRED_GLUSTER_VOLUME=('agh' 'cert' 'pilgrim' 'portainer' 'traefik' 'registry')

function load_dot_env() {
  test -f .env && source .env
}
load_dot_env

set -x

function is_installed() {
  dpkg -s "$1" &>/dev/null
  return $?
}

function check_required_packages() {
  for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! is_installed "$package"; then
      echo "$package is required. Please install via apt"
      exit 1
    fi
  done
}

function check_required_envs() {
  for env_name in "${REQUIRED_ENVS[@]}"; do
    if [ -z "${!env_name}" ]; then
      echo "Environment variable $env_name is required."
      exit 1
    fi
  done
}

function check_mount_unit_exists() {
  systemctl list-units -t mount | grep -q "mnt-$1.mount"
}

function create_mount_units() {
  for vol_name in "${REQUIRED_GLUSTER_VOLUME[@]}"; do
    check_mount_unit_exists "$vol_name"
    if test $?; then
      VOL_NAME="$vol_name" GLUSTERFS_SERVERS="$GLUSTERFS_SERVERS" envsubst <gluster_template.mount >/etc/systemd/system/"mnt-$vol_name.mount"
    fi
  done

  systemctl daemon-reload
}

function mount_units() {
  for vol_name in "${REQUIRED_GLUSTER_VOLUME[@]}"; do
    systemctl enable --now "mnt-$vol_name.mount"
  done
}

check_required_packages
check_required_envs
create_mount_units
mount_units

docker network create --driver=overlay traefik-public
