FROM quay.io/fedora/fedora-bootc:41

# Build dependencies
RUN dnf -y install yq 'dnf5-command(copr)'
# Enable rpmfusion
RUN dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Configure the image
COPY build_yml.sh /tmp/build_yml.sh
COPY config /tmp/config
RUN /tmp/config/build.sh
# Add bootc installation config (btrfs)
COPY /bootc/rootfs/usr /usr

# Stop bootc from auto-rebooting on update
RUN sed -i "s,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g" /usr/lib/systemd/system/bootc-fetch-apply-updates.service

# Install fsync kernel && mesa-git
# RUN dnf -y copr enable sentry/kernel-fsync && \
RUN dnf -y install mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld
# RUN dnf -y copr enable xxmitsu/mesa-git \
#     dnf -y install mesa-va-drivers mesa-vdpau-drivers
# DONT update (if it updates kernel it messes up)
# && \
    # dnf -y update --refresh

COPY base.yaml /tmp/base.yaml
RUN /tmp/build_yml.sh /tmp/base.yaml

COPY koibito.yaml /tmp/koibito.yaml
RUN /tmp/build_yml.sh /tmp/koibito.yaml

COPY dev-packages.yaml /tmp/dev-packages.yaml
RUN /tmp/build_yml.sh /tmp/dev-packages.yaml

# Sway as backup
RUN dnf -y install sway-config-fedora sway
COPY hyprland /tmp/hyprland
RUN /tmp/build_yml.sh /tmp/hyprland/hyprland.yaml && \
    cp -r /tmp/hyprland/usr / && \
    cp -r /tmp/hyprland/etc /

# Scheduler
RUN dnf -y copr enable kylegospo/system76-scheduler && \
    dnf -y install system76-scheduler && \
    systemctl enable com.system76.Scheduler.service

# COPY cosmic /tmp/cosmic
# RUN /tmp/build_yml.sh /tmp/cosmic/cosmic.yaml && \
#     cp /tmp/cosmic/greetd-workaround.service /usr/lib/systemd/system/
#     # systemctl enable greetd-workaround.service

RUN dnf clean all

# Adds core user with password "core"
# For local running in a container..
# RUN useradd -G wheel -p sa97a3iPo6ucE core && \
#     mkdir -m 0700 -p /home/core/.ssh && \
#     chown -R core: /home/core

RUN bootc container lint
