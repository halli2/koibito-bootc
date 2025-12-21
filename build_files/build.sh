#!/bin/bash
set -ouex pipefail

# Install build reqs
dnf -y install yq 'dnf5-command(copr)'

# Enable repos
dnf -y install \
  --repofrompath "terra,https://repos.fyralabs.com/terra$(rpm -E %fedora)" \
  --setopt="terra.gpgkey=https://repos.fyralabs.com/terra$(rpm -E %fedora)/key.asc" \
  terra-release
# dnf -y install terra-release-extras
# dnf -y config-manager setopt terra-mesa.enabled=1

dnf -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# dnf -y copr enable bieszczaders/kernel-cachyos-addons

# Install kernel
# dnf -y copr enable sentry/kernel-blu
# dnf -y remove kernel kernel{,-core,-modules,-modules-core,-modules-extra}
# dnf -y install kernel kernel{,-core,-modules,-modules-core,-modules-extra}
dnf -y install mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld

sed -i "s,ExecStart=/usr/bin/bootc upgrade --apply --quiet,ExecStart=/usr/bin/bootc upgrade --quiet,g" /usr/lib/systemd/system/bootc-fetch-apply-updates.service

dnf -y install scx-scheds-git
/ctx/config/build.sh
/ctx/build_yml.sh /ctx/base.yaml
/ctx/build_yml.sh /ctx/koibito.yaml
/ctx/build_yml.sh /ctx/dev-packages.yaml

/ctx/build_yml.sh /ctx/niri/niri.yaml

# Remove unwanted
dnf -y remove alacritty swaylock

dnf clean all
rm -rf /tmp/* || true
rm -rf /var/log/*
rm -rf /var/cache/*
