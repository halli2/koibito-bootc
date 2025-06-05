#!/bin/bash
set -ouex pipefail

# Install build reqs
dnf -y install yq 'dnf5-command(copr)'

# Enable repos
dnf -y install \
  --repofrompath "terra,https://repos.fyralabs.com/terra$(rpm -E %fedora)" \
  --setopt="terra.gpgkey=https://repos.fyralabs.com/terra$(rpm -E %fedora)/key.asc" \
  terra-release
dnf -y install terra-release-extras
dnf -y config-manager setopt terra-mesa.enabled=1
dnf -y copr enable bieszczaders/kernel-cachyos-addons

# Install kernel
dnf -y copr enable sentry/kernel-blu
dnf -y remove kernel kernel{,-core,-modules,-modules-core,-modules-extra}
dnf -y install kernel kernel{,-core,-modules,-modules-core,-modules-extra}

sed -i "s,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g" /usr/lib/systemd/system/bootc-fetch-apply-updates.service

dnf -y install scx-scheds
/ctx/config/build.sh
/ctx/build_yml.sh /ctx/base.yaml
/ctx/build_yml.sh /ctx/koibito.yaml
/ctx/build_yml.sh /ctx/dev-packages.yaml

/ctx/build_yml.sh /ctx/hyprland/hyprland.yaml
cp -r /ctx/hyprland/usr /
cp -r /ctx/hyprland/etc /

dnf clean all
rm -rf /tmp/* || true
rm -rf /var/log/*
rm -rf /var/cache/*
