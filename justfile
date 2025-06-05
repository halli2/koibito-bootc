# Installation: sudo podman push koibito:latest registry.666777555.xyz/koibito:latest
# sudo podman run --rm --privileged --pid=host -v /var/lib/containers:/var/lib/containers --security-opt label=type:unconfined_t -v /dev:/dev registry.666777555.xyz/koibito:latest bootc install to-disk /dev/nvme0n1

_default:
    @just --list


build:
    sudo podman build -t koibito:latest .

build_chunked:
    @just build
    sudo podman run --rm \
        --privileged \
        -v /var/lib/containers:/var/lib/containers \
        "quay.io/centos-bootc/centos-bootc:stream10" \
        /usr/libexec/bootc-base-imagectl rechunk \
            localhost/koibito:latest \
            localhost/koibito:latest
build-from-scratch:
    sudo podman build --pull=always --no-cache -t koibito:latest .


# VM Test
build-qcow2:
    mkdir -p output
    @just build
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/config.toml:/config.toml:ro \
        -v $(pwd)/output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type qcow2 \
        --rootfs ext4 \
        --local localhost/koibito:latest


# Start VM
start-vm:
    qemu-system-x86_64 \
        -M accel=kvm \
        -cpu host \
        -smp 8 \
        -m 8G \
        -bios /usr/share/OVMF/OVMF_CODE.fd \
        -serial stdio \
        -nic user,hostfwd=tcp::60022-:22 \
        -snapshot output/qcow2/disk.qcow2

build-start:
    @just build
    @just build-qcow2
    @just start-vm

build-start-scratch:
    @just build-from-scratch
    @just build-qcow2
    @just start-vm

