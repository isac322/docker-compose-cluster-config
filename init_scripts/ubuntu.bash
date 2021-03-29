#!/usr/bin/env bash

function ensure_env() {
    if [ -z "${!1}" ]; then
      echo "Please pass $1 as environment variable"
      exit 1
    fi
}

ensure_env "USER_NAME"

function modify_sshd_config() {
  local val="$1"
  shift
  local cfg_path='/etc/ssh/sshd_config'

  local exprs=()
  for key in "$@"; do
    if grep -qE "^\s*#\s*${key}\s+${val}\s*$" "$cfg_path"; then
      exprs+=(-e "s/^\s*#\s*${key}\s+.+$/${key} ${val}/")
    elif grep -qE "^\s*${key}\s+.+\s*$" "$cfg_path"; then
      exprs+=(-e "s/^\s*${key}\s+(.+)$/${key} ${val}\t# \1/")
    else
      exprs+=(-e "s/^\s*#\s*${key}\s+(.+)$/${key} ${val}\t# \1/")
    fi
  done

  sed -i -E "${exprs[@]}" "$cfg_path"
}

set -ex

apt update
apt purge snapd ufw -y
apt full-upgrade -y
apt install zsh vim curl iptables-persistent -y
apt autoremove -y
apt autoclean -y

systemctl enable netfilter-persistent.service

useradd -m -U -s "$(which zsh)" "$USER_NAME"
echo "Password for root"
passwd "${USER_NAME}"
echo "Password for ${USER_NAME}"
passwd root
echo -e "${USER_NAME}\tALL=(ALL)\tALL\n" > /etc/sudoers.d/bhyoo

curl -sfL https://get.k3s.io | sh -

sh reset_ip6tables.sh
sh reset_iptables.sh

sh setup_iptables.sh
sh setup_ip6tables.sh

netfilter-persistent save

# setup sshd
modify_sshd_config 'no' 'PermitEmptyPasswords' 'PermitRootLogin' 'PasswordAuthentication'
modify_sshd_config 'yes' 'PubkeyAuthentication' 'StrictModes'
modify_sshd_config '5' 'MaxAuthTries'

mkdir -p "/home/${USER_NAME}/.ssh"
chmod 700 "/home/${USER_NAME}/.ssh"
touch "/home/${USER_NAME}/.ssh/authorized_keys"
chmod 600 "/home/${USER_NAME}/.ssh/authorized_keys"
chown -R "${USER_NAME}":"${USER_NAME}" "/home/${USER_NAME}/.ssh"

su "$USER_NAME" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"