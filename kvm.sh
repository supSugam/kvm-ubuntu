#!/bin/bash

echo "Script executed from: ${PWD}"
USERNAME="ctrlcat"

# ISO Variables
VERSION="24.04"
VERSION_FULL="24.04.1"
ISO_FILENAME="ubuntu-${VERSION_FULL}-live-server-amd64.iso"
DOWNLOAD_URL="https://releases.ubuntu.com/${VERSION_FULL}/ubuntu-${VERSION_FULL}-live-server-amd64.iso"
ISO_FILEPATH="${PWD}/${ISO_FILENAME}"

# VM Variables
VM_NAME="ubuntu-vm"
VM_MEMORY=4096
VM_CPU=4
VM_DISK_SIZE=30G
VM_DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"

# Check if ISO File Exists
if [ ! -f ${ISO_FILENAME} ]; then
    echo "ISO File Not Found. Downloading..."
    wget ${DOWNLOAD_URL}
fi

# Install Required Packages
echo "Installing Required Packages..."
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-viewer cloud-image-utils

# Enable and Start Libvirt Service
echo "Enabling and Starting Libvirt Service..."
sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd

# Add User to Libvirt Group
echo "Adding User to Libvirt Group..."
sudo usermod -aG libvirt ${USERNAME}
# Removed the newgrp command
echo "User ${USERNAME} added to libvirt group."

# Create Disk Image
echo "Creating Disk Image at ${VM_DISK_PATH}..."
sudo qemu-img create -f qcow2 ${VM_DISK_PATH} ${VM_DISK_SIZE}

# Check if meta-data and user-data files exist
if [ ! -f "meta-data" ] || [ ! -f "user-data" ]; then
    echo "meta-data and/or user-data files not found. Exiting..."
    exit 1
fi


if [ -f "seed.iso" ]; then
    rm -f seed.iso
fi
cloud-localds seed.iso user-data meta-data

echo "Creating VM with autoinstall..."
sudo virt-install \
    --name ${VM_NAME} \
    --memory ${VM_MEMORY} \
    --vcpus ${VM_CPU} \
    --os-variant ubuntu22.04 \
    --disk path=${VM_DISK_PATH},size=30,format=qcow2,bus=virtio \
    --disk path=seed.iso,device=cdrom,format=raw,cache=none \
    --network network=default,model=virtio \
    --location ${ISO_FILEPATH},initrd=casper/initrd,kernel=casper/vmlinuz \
    --graphics none \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial autoinstall'