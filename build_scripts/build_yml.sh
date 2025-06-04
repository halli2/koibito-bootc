#!/bin/bash
set -ouex pipefail

# PACKAGES
COPRS=$(yq eval '.packages.copr[]' $1)
INSTALL_PKGS=$(yq eval '.packages.install[]' $1)
REMOVE_PKGS=$(yq eval '.packages.remove[]' $1)


if [ -n "$COPRS" ]; then
  for copr in ${COPRS[@]}; do
    dnf -y copr enable "$copr"
  done
fi

if [ -n "$REMOVE_PKGS" ]; then
  dnf -y remove ${REMOVE_PKGS[@]}
fi

if [ -n "$INSTALL_PKGS" ]; then
  dnf -y install ${INSTALL_PKGS[@]}
fi

# SYSTEMD
SYSTEMD_ENABLE=$(yq eval '.systemd.enable[]' $1)
SYSTEMD_DISABLE=$(yq eval '.systemd.disable[]' $1)

if [ -n "$SYSTEMD_DISABLE" ]; then
  systemctl disable ${SYSTEMD_DISABLE[@]}
fi
if [ -n "$SYSTEMD_ENABLE" ]; then
  systemctl enable ${SYSTEMD_ENABLE[@]}
fi
