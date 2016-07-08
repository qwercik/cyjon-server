Use RAW image file with Bochs or Qemu:

	qemu-system-x86_64 -hda "disk with omega.raw"
	or
	qemu-system-x86_64 -kernel kernel.bin

or file "kernel.bin" with any GRUB instance (GNU/Linux required) /boot/grub/grub.cfg:

	menuentry "Cyjon OS" {
		multiboot /{path to this file}/kernel.bin
	}
