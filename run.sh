#!/bin/bash

usage() {
    echo "Usage: $0 image-file"
    echo "Run qemu image for debug."
    echo
    echo "Press 'Ctrl-A X', if quit qemu."
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

image=$(realpath $1)

qemu-system-x86_64 \
    -m 512 \
    -enable-kvm \
    -drive file=${image},if=virtio,format=qcow2 \
    -serial mon:stdio \
    -nographic \
    -netdev user,id=user.0,hostfwd=tcp::4089-:22 \
    -device virtio-net,netdev=user.0
