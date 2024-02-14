SHELL = bash


OS_ID = debian12

NAME = vm-debiban
UUID = $(shell uuidgen)


.PHONY: vm-renew
vm-renew: vm-kill vm-inst


.PHONY: vm-inst
vm-inst: seed.debian.iso vm-debian.qcow2
	virt-install \
		--name $(NAME) --uuid=$(UUID) \
		--cpu host-passthrough --vcpus 10 \
		--memory 4096 --memorybacking access.mode=shared,source.type=memfd \
		--boot uefi \
		--import \
		--disk path=$(CURDIR)/vm-debian.qcow2,format=qcow2 \
		--disk path=seed.debian.iso,format=raw,readonly=on \
		--network bridge=virbr0 \
		--network user \
		--console pty,target.type=virtio \
		--graphics spice,listen=127.0.0.1 \
		--osinfo short-id=$(OS_ID) \
		--filesystem source=$$HOME,target=host-home,driver.type=virtiofs

	virsh detach-disk --domain $(NAME) --target $(CURDIR)/seed.debian.iso --persistent


seed.debian.iso: dists/debian/cloud-init.yaml
	cloud-init schema -c dists/debian/cloud-init.yaml
	cloud-localds seed.debian.iso dists/debian/cloud-init.yaml


vm-debian.qcow2: debian-12-genericcloud-amd64.qcow2
	cp -f debian-12-genericcloud-amd64.qcow2 vm-debian.qcow2
	qemu-img resize vm-debian.qcow2 '20G'


debian-12-genericcloud-amd64.qcow2:
	curl -o $@ -L https://cloud.debian.org/images/cloud/bookworm-backports/latest/debian-12-backports-genericcloud-amd64.qcow2


.PHONY: vm-kill
vm-kill:
	-virsh destroy --remove-logs $(NAME)
	-virsh undefine --nvram $(NAME)
	rm -f vm-debian.qcow2
