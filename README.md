### VM Setup Using KVM and QEMU, with Ubuntu 24.04

1. Install KVM and QEMU

```bash
sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm
```

2. Check if your CPU supports hardware virtualization

```bash
kvm-ok
```

3. Enable and start the libvirtd service

```bash
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

4. Make your user a member of the libvirt group so that you can manage virtual machines without root privileges

```bash
sudo usermod -aG libvirt $(whoami)
newgrp libvirt
```

5. Download the cloud image for Ubuntu 24.04.1 Server

6. Create the disk image for the virtual machine

```bash
qemu-img create -f qcow2 ubuntu-24.04.1.qcow2 25G
```

7. Install the virtual machine using `virt-install`

```bash
virt-install \
    --name ubuntu24.04 \
    --ram 4096 \
    --disk path=ubuntu-24.04.1.qcow2,format=qcow2 \
    --vcpus 4 \
    --os-variant ubuntu22.04 \
    --location /home/ctrlcat/Downloads/iso/ubuntu-24.04.1.iso \
    --network bridge=virbr0 \
    --graphics none \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial'
```

Note: It didn't installed for me, so I had to use virt-manager with the same configuration, during ubuntu installation, I selected languages, keyboard layout, and went along with the default settings.

8. Find the IP address of the virtual machine (from the host)

```bash
virsh net-dhcp-leases default
```

9. Add public SSH key to the virtual machine

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@<ip-address>
```

10. Loging to the virtual machine using SSH

```bash
ssh -i ~/.ssh/id_ed25519 <username>@<ip-address>
```
