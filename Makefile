# $@ : Target file
# $< : First dependency
# $^ : All dependencies

all: run

build/kernel.bin: build/kernel_entry.o build/kernel.o
	ld -m elf_i386 -s -o $@ -Ttext 0x1000 $^ --oformat binary

build/kernel_entry.o: src/kernel_entry.asm
	nasm $< -felf32 -o $@

build/kernel.o: src/kernel.c
	gcc -g -m32 -fno-pie -ffreestanding -c $< -o $@

kernel.dis: build/kernel.bin
	ndisasm -b 32 $< > $@

build/boot_sector.bin: src/boot_sector.asm
	nasm $< -fbin -o $@

build/os-image.bin: build/boot_sector.bin build/kernel.bin
	cat $^ > $@

run: build/os-image.bin
	qemu-system-i386 -fda $<

clean:
	rm build/*.bin build/*.o *.dis
