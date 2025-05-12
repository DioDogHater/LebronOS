nasm -fbin ./src/boot.asm -o ./build/boot.bin
qemu-system-x86_64 ./build/boot.bin
