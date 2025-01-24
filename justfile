# Installation: sudo podman push koibito-bootc:41 registry.666777555.xyz/koibito-bootc:41
# sudo podman run --rm --privileged --pid=host -v /var/lib/containers:/var/lib/containers --security-opt label=type:unconfined_t -v /dev:/dev registry.666777555.xyz/koibito-bootc:41 bootc install to-disk /dev/nvme0n1

_default:
    @just --list


build:
    podman build -t koibito-bootc:41 .

build-from-scratch:
    podman build --pull=always --no-cache -t koibito-bootc:41 .

push_to_registry:
    podman push koibito-bootc:41 registry.666777555.xyz/koibito-bootc:41

build_to_registry:
    @just build-from-scratch
    @just push_to_registry
        

# VM Test
build-qcow2:
    mkdir -p output
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
        --local localhost/koibito-bootc:41

# build-iso:
#     mkdir -p output
#     sudo podman run \
#         --rm \
#         -it \
#         --privileged \
#         --pull=newer \
#         --security-opt label=type:unconfined_t \
#         -v $(pwd)/output:/output \
#         -v /var/lib/containers/storage:/var/lib/containers/storage \
#         quay.io/centos-bootc/bootc-image-builder:latest \
#         --type anaconda-iso \
#         --rootfs ext4 \
#         --local localhost/koibito-bootc:41

        
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

