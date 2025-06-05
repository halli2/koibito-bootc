FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora/fedora-bootc:42

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build.sh

# Add bootc installation config (btrfs)
COPY /bootc/rootfs/usr /usr
RUN bootc container lint
