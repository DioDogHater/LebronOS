[org 0x7c00]
KERNEL_OFFSET equ 0x1000

boot_sector_start:
	mov [boot_drive], dl
	mov bp, 0x9000
	mov sp, bp

	mov bx, lebron_boot_msg
	call print_real_mode

	call boot_sector_load_kernel
	call switch_to_protected_mode

end_boot_sector:
	jmp $

; 16 bit functions / labels
[bits 16]

boot_sector_load_kernel:
	mov bx, lebron_kernel_load_msg
	call print_real_mode

	mov bx, KERNEL_OFFSET
	mov dh, 10
	mov dl, [boot_drive]
	call boot_sector_disk_load
	ret

; prints out null-terminated string in bx in 16 bit real mode
print_real_mode:
	pusha
	mov ah, 0x0e
	.loop:
	mov al, [bx]
	
	test al, al
	jz .done
	
	int 0x10

	inc bx
	jmp .loop
	
	.done:
	popa
	ret

; Load dh sectors from drive dl and load them in bx
boot_sector_disk_load:
	pusha
	push dx
	mov ah, 0x02	; 0x02 = read
	mov al, dh	; number of sectors to read
	mov cx, 0x0002	; ch = cylinder = 0
			; cl = start sector = 2 (we skip the first one)
	mov dh, 0	; head number (0)
	int 0x13	; BIOS interrupt
	jc .disk_error	; If there's an error, Carry flag is set
	pop dx
	cmp al, dh
	jne .sector_error ; If the sectors read != sectors we want to read
	popa
	ret
	
	.disk_error:
	mov bx, .disk_error_msg
	call print_real_mode
	jmp end_boot_sector

	.sector_error:
	mov bx, .sector_error_msg
	call print_real_mode
	jmp end_boot_sector

	.disk_error_msg: db "Disk reading error!",10,13,0
	.sector_error_msg: db "Incorrect number of sectors read!",10,13,0

switch_to_protected_mode:
	cli			; disable interrupts
	lgdt [gdt_descriptor]	; load the GDT descriptor
	mov eax, cr0
	or eax, 0x1		; Switch to 32-bit mode
	mov cr0, eax
	jmp CODE_SEG:init_protected_mode ; Far jump to other segment

; 32 bit functions / labels
[bits 32]

init_protected_mode:
	mov ax, DATA_SEG	; Update the segment registers
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000	; Move the stack up
	mov esp, ebp

	call lebron_begin_protected_mode

lebron_begin_protected_mode:
	mov ebx, lebron_protected_mode_msg
	call print_protected_mode
	
	call KERNEL_OFFSET	; Start the kernel

kernel_end:
	jmp $

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0F

; prints out null-terminated string in ebx
print_protected_mode:
	pusha
	mov edx, VIDEO_MEMORY
	mov ah, WHITE_ON_BLACK
	.loop:
	mov al, [ebx]
	
	test al, al
	jz .done

	mov [edx], ax
	inc ebx
	add edx, 2

	jmp .loop

	.done:
	popa
	ret

; Global Descriptor Table
%include "src/boot_sector_gdt.asm"

; Data section 
boot_drive: db 0
lebron_boot_msg: db "LebronOS is booting up in 16-bit real mode...",10,13,0
lebron_kernel_load_msg: db "The Lebron kernel is loading...",10,13,0
lebron_protected_mode_msg: db "LebronOS is in 32-bit protected mode.",0

; Make the boot_sector_bootable
times 510 - ($-$$) db 0
dw 0xaa55
