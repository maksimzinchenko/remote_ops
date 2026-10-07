#!/bin/sh
# Установка Docker Engine на Linux, если клиента ещё нет.
# Печатает REMOTE_OPS_STATUS=... — это код результата для приложения, не часть команды.
status() { printf 'REMOTE_OPS_STATUS=%s\n' "$1"; }
note() { printf '%s\n' "$1"; }
export DEBIAN_FRONTEND=noninteractive

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  status unsupported_os
  note "This command supports Linux only."
  note "uname: $(uname -s 2>/dev/null || echo unknown)"
  exit 1
fi

if command -v docker >/dev/null 2>&1; then
  version=$(docker --version 2>/dev/null || true)
  if [ -n "$version" ]; then
    status already_installed
    note "$version"
    note "Docker is already on this server. Installation was skipped."
    exit 0
  fi
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
  status need_root
  note "Root or passwordless sudo is required to install Docker."
  note "Current user: $(id -un 2>/dev/null || echo unknown)"
  exit 1
fi

os_id=""
os_like=""
if [ -r /etc/os-release ]; then
  os_id=$(. /etc/os-release && printf '%s' "$ID")
  os_like=$(. /etc/os-release && printf '%s' "${ID_LIKE:-}")
fi

supported=0
case "$os_id" in
  ubuntu|debian|raspbian|centos|rhel|rocky|fedora|almalinux|amzn|ol) supported=1 ;;
esac
printf '%s' "$os_like" | grep -Eq 'debian|ubuntu|rhel|fedora|centos' && supported=1

if [ -f /etc/alpine-release ]; then
  note "Alpine detected. Installing the distro docker package."
  if ! as_root apk add --no-cache docker docker-cli; then
    status install_failed
    note "apk add docker failed."
    exit 1
  fi
  as_root rc-update add docker boot >/dev/null 2>&1 || true
  if ! as_root service docker start; then
    status installed_no_daemon
    note "Packages were installed, but the Docker service did not start."
    exit 1
  fi
elif [ "$supported" -eq 1 ]; then
  note "Using Docker's official install script for ${os_id:-unknown}."
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    status network_error
    note "curl or wget is required to download https://get.docker.com."
    exit 1
  fi
  tmp=$(mktemp 2>/dev/null || echo /tmp/remote-ops-get-docker.sh)
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL https://get.docker.com -o "$tmp"; then
      status network_error
      note "Could not download https://get.docker.com."
      exit 1
    fi
  else
    if ! wget -qO "$tmp" https://get.docker.com; then
      status network_error
      note "Could not download https://get.docker.com."
      exit 1
    fi
  fi
  if ! as_root sh "$tmp"; then
    status install_failed
    note "Docker install script failed. Details are in stderr."
    rm -f "$tmp"
    exit 1
  fi
  rm -f "$tmp"
  if command -v systemctl >/dev/null 2>&1; then
    as_root systemctl enable --now docker >/dev/null 2>&1 || true
  fi
else
  status unsupported_os
  note "No install adapter for this distribution."
  note "ID=${os_id:-unknown} ID_LIKE=${os_like:-unknown}"
  note "Supported: Ubuntu, Debian, Raspbian, CentOS, RHEL, Rocky, AlmaLinux, Fedora, Amazon Linux, Oracle Linux, Alpine."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1 || ! docker --version >/dev/null 2>&1; then
  status install_failed
  note "Installer finished, but docker is not available in PATH."
  exit 1
fi

if ! as_root docker info >/dev/null 2>&1; then
  status installed_no_daemon
  docker --version 2>/dev/null || true
  note "Docker client is installed, but the daemon is not responding."
  exit 1
fi

status installed
docker --version
note "Docker Engine is installed and the daemon responded."
exit 0
