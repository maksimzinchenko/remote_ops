#!/bin/sh
# Снимает Docker Engine и стирает данные, которые установка оставила на сервере.
# Печатает REMOTE_OPS_STATUS=... — это код результата для приложения, не часть команды.
status() { printf 'REMOTE_OPS_STATUS=%s\n' "$1"; }
note() { printf '%s\n' "$1"; }

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  status remove_unsupported_os
  note "This command supports Linux only."
  note "uname: $(uname -s 2>/dev/null || echo unknown)"
  exit 1
fi

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    sudo -n "$@"
  else
    return 127
  fi
}

if ! as_root true >/dev/null 2>&1; then
  status remove_need_root
  note "Root or passwordless sudo is required to remove Docker."
  note "Current user: $(id -un 2>/dev/null || echo unknown)"
  exit 1
fi

present=0
if command -v docker >/dev/null 2>&1; then
  present=1
  note "Docker client: $(docker --version 2>/dev/null || echo present)"
fi
if [ -d /var/lib/docker ] || [ -d /var/lib/containerd ]; then
  present=1
fi

if [ "$present" -eq 1 ] && command -v docker >/dev/null 2>&1 && as_root docker info >/dev/null 2>&1; then
  note "Stopping containers and deleting images, volumes and build cache."
  as_root docker ps -aq | while read -r id; do
    [ -n "$id" ] && as_root docker rm -f "$id" >/dev/null 2>&1 || true
  done
  as_root docker system prune -af --volumes >/dev/null 2>&1 || true
fi

if command -v systemctl >/dev/null 2>&1; then
  as_root systemctl disable --now docker.service docker.socket containerd.service >/dev/null 2>&1 || true
fi
if [ -f /etc/alpine-release ] && command -v service >/dev/null 2>&1; then
  as_root service docker stop >/dev/null 2>&1 || true
  as_root rc-update del docker boot >/dev/null 2>&1 || true
fi

failed=0
if [ -f /etc/alpine-release ]; then
  note "Removing Alpine docker packages."
  as_root apk del docker docker-cli docker-openrc containerd >/dev/null 2>&1 || true
elif command -v apt-get >/dev/null 2>&1; then
  note "Purging Debian/Ubuntu Docker packages and the Docker apt source."
  as_root apt-get purge -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    docker-ce-rootless-extras docker-model-plugin docker.io docker-doc docker-compose \
    docker-compose-v2 podman-docker >/dev/null 2>&1 || failed=1
  as_root apt-get autoremove -y >/dev/null 2>&1 || true
elif command -v dnf >/dev/null 2>&1; then
  note "Removing RPM Docker packages."
  as_root dnf remove -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    docker-ce-rootless-extras docker docker-engine >/dev/null 2>&1 || failed=1
elif command -v yum >/dev/null 2>&1; then
  note "Removing RPM Docker packages."
  as_root yum remove -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    docker-ce-rootless-extras docker docker-engine >/dev/null 2>&1 || failed=1
elif [ "$present" -eq 1 ]; then
  status remove_unsupported_os
  note "Docker was found, but this distribution has no package remover."
  exit 1
fi

note "Removing images, volumes, installer files and repository leftovers."
as_root rm -rf /var/lib/docker /var/lib/containerd /var/lib/docker-engine
as_root rm -f \
  /etc/apt/sources.list.d/docker.list \
  /etc/apt/sources.list.d/docker.sources \
  /etc/apt/keyrings/docker.asc \
  /etc/apt/keyrings/docker.gpg \
  /etc/yum.repos.d/docker-ce.repo \
  /tmp/remote-ops-get-docker.sh \
  /tmp/get-docker.sh

if command -v docker >/dev/null 2>&1; then
  status remove_failed
  note "Package removal finished, but the docker command is still in PATH."
  note "$(command -v docker)"
  exit 1
fi

if [ "$failed" -eq 1 ]; then
  status remove_failed
  note "The package manager reported an error. Details are in stderr."
  exit 1
fi

if [ "$present" -eq 0 ]; then
  status not_installed
  note "Docker was not on this server. Temporary installer files were removed if present."
  exit 0
fi

status removed
note "Docker Engine, images, volumes and installer leftovers were removed."
exit 0
