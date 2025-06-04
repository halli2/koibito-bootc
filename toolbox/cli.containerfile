FROM fedora-toolbox:latest

RUN dnf -y update
RUN <<EOF
#!/bin/env sh
set -oue pipefail
# 
# Install general deps 
GEN_PKGS=(
  exa
  fd-find
  fish
  fuse
  git-delta
  jq
  just
  npm
  p7zip
  qt5-qtwayland # VulkanCapsViewer
  ripgrep
  unrar
  wl-clipboard
  zoxide
)

# General dev tools
DEV_PKGS=(
  clang
  clang-tools-extra
  llvm
  mold

  rocm-hip
  rocm-opencl
  rocm-clinfo
)

DEV_DEPS=(
  libgbm-devel
  libinput-devel
  libseat-devel
  libxkbcommon-devel
  pipewire-devel
  systemd-devel
  wayland-devel
)

dnf -y install \
  ${GEN_PKGS[@]} \
  ${DEV_PKGS[@]} \
  ${DEV_DEPS[@]}
EOF

