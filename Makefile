# it's alive

ASM=nasm -f bin
BOOTLOADER=bootloader
BUILD=build
SOFTWARE=software

all:
	$(ASM) $(SOFTWARE)/init.asm		-o $(BUILD)/init.bin
	$(ASM) $(SOFTWARE)/login.asm		-o $(BUILD)/login.bin
	$(ASM) $(SOFTWARE)/shell.asm		-o $(BUILD)/shell.bin
	$(ASM) $(SOFTWARE)/ps.asm		-o $(BUILD)/ps.bin
	$(ASM) $(SOFTWARE)/ip.asm		-o $(BUILD)/ip.bin
	$(ASM) $(SOFTWARE)/help.asm		-o $(BUILD)/help.bin
	$(ASM) $(SOFTWARE)/httpd.asm		-o $(BUILD)/httpd.bin
	$(ASM) $(SOFTWARE)/kill.asm		-o $(BUILD)/kill.bin
	$(ASM) $(SOFTWARE)/free.asm		-o $(BUILD)/free.bin

	$(ASM) kernel.asm			-o build/kernel.bin

	$(ASM) $(BOOTLOADER)/stage2.asm	-o build/stage2.bin
	$(ASM) $(BOOTLOADER)/stage1.asm	-o $(BUILD)/disk_with_omega.raw

	make clean

clean:
	rm -f	$(BUILD)/stage2.bin	\
		$(BUILD)/init.bin	\
		$(BUILD)/login.bin 	\
		$(BUILD)/shell.bin 	\
		$(BUILD)/ps.bin		\
		$(BUILD)/ip.bin		\
		$(BUILD)/help.bin	\
		$(BUILD)/httpd.bin	\
		$(BUILD)/kill.bin	\
		$(BUILD)/free.bin
