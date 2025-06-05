FROM scratch AS ctx
COPY build_files /

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
    dnf -y install --repofrompath "terra,https://repos.fyralabs.com/terra$(rpm -E %fedora)" --setopt="terra.gpgkey=https://repos.fyralabs.com/terra$(rpm -E %fedora)/key.asc" terra-release && \
    dnf -y install terra-release-extras && \
    dnf -y config-manager setopt terra-mesa.enabled=1 && \
    /ctx/cleanup.sh

# Configure the image
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/config/build.sh && \
    /ctx/cleanup.sh

# Add bootc installation config (btrfs)
COPY /bootc/rootfs/usr /usr
# Stop bootc from auto-rebooting on update
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    sed -i "s,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g" /usr/lib/systemd/system/bootc-fetch-apply-updates.service


RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /ctx/base.yaml && \
    /ctx/cleanup.sh


RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /ctx/koibito.yaml \
    /ctx/cleanup.sh


RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /ctx/dev-packages.yaml && \
    /ctx/cleanup.sh

    
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_yml.sh /ctx/hyprland/hyprland.yaml && \
    cp -r /ctx/hyprland/usr / && \
    cp -r /ctx/hyprland/etc / && \
    /ctx/cleanup.sh


# Kernel and schedulers (scx_*)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf -y copr enable sentry/kernel-blu && \
    dnf -y install \
        --allow-downgrade \
        --repo=copr:copr.fedorainfracloud.org:sentry:kernel-blu \
        kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra && \
    dracut \
        --no-hostonly --kver "$(rpm -q kernel | sed 's/kernel-//')" --reproducible \
        --zstd -v --add ostree -f "/lib/modules/$(rpm -q kernel | sed 's/kernel-//')/initramfs.img" && \
    dnf -y copr enable bieszczaders/kernel-cachyos-addons && \
    dnf -y install scx-scheds && \
    /ctx/cleanup.sh


RUN bootc container lint
