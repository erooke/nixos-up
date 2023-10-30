vm-boot:
	qemu-system-x86_64 \
		-enable-kvm \
		-m 2G \
		-drive file=vm/heron.raw,format=raw \
		-drive if=pflash,format=raw,file=./vm/OVMF.fd
vm-install: vm-files tarball
	qemu-system-x86_64 \
		-enable-kvm \
		-m 2G \
		-cdrom vm/nixos.iso \
		-boot order=d \
		-drive file=vm/heron.raw,format=raw \
		-drive if=pflash,format=raw,file=./vm/OVMF.fd

vm-files: vm-dir
	cp -t vm /usr/share/edk2-ovmf/x64/OVMF.fd
	qemu-img create -f raw vm/heron.raw 8G

vm-dir:
	mkdir -p vm
	chattr +C vm 2> /dev/null || true

tarball:
	git archive --format=tar.gz -o nixos-up.tar.gz --prefix=nixos-up/ HEAD
