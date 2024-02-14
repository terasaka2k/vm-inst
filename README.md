# vm-inst

```bash
# libvirt

make -f debian.mk vm-renew

VM_IP=...
ssh -XY -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null vm@$VM_IP
```
