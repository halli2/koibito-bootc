FROM scratch AS ctx
COPY build_scripts /

FROM quay.io/fedora/fedora-bootc:42
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf -y install yq 'dnf5-command(copr)' && \
    /ctx/cleanup.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release && \
    dnf -y install terra-release-extras && \
    dnf -y config-manager setopt terra-mesa.enabled=1 && \
    /ctx/cleanup.sh

# Configure the image
COPY config /tmp/config
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /tmp/config/build.sh && \
    /ctx/cleanup.sh

# Add bootc installation config (btrfs)
COPY /bootc/rootfs/usr /usr

# Stop bootc from auto-rebooting on update
RUN -mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    sed -i "s,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g" /usr/lib/systemd/system/bootc-fetch-apply-updates.service

COPY base.yaml /tmp/base.yaml
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /tmp/base.yaml && \
    /ctx/cleanup.sh

COPY koibito.yaml /tmp/koibito.yaml
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /tmp/koibito.yaml

COPY dev-packages.yaml /tmp/dev-packages.yaml
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /tmp/dev-packages.yaml && \
    /ctx/cleanup.sh

COPY hyprland /tmp/hyprland
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /tmp/hyprland/hyprland.yaml && \
    cp -r /tmp/hyprland/usr / && \
    cp -r /tmp/hyprland/etc / && \
    /ctx/cleanup.sh

# Scheduler
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf -y copr enable kylegospo/system76-scheduler && \
    dnf -y install system76-scheduler && \
    systemctl enable com.system76.Scheduler.service && \
    /ctx/cleanup.sh


# Adds core user with password "core"
# For local running in a container..
# RUN useradd -G wheel -p sa97a3iPo6ucE core && \
#     mkdir -m 0700 -p /home/core/.ssh && \
#     chown -R core: /home/core

RUN bootc container lint
