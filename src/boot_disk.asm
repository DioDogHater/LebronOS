; Load (dh) sectors in drive (dl) into [es:bx]
; Destroys all registers
disk_load:
	pusha
	push dx ; Store dx

	mov ah, 0x02	; ah = 0x02 = read
	mov al, dh	; al = how many sectors we wanna read
	mov cl, 0x02	; cl = sector 2, because it's the first one we can actually use
	mov ch, 0x00	; We want to use the first cylinder only (0x00)
	mov dh, 0x00	; head number = 0
	
	int 0x13	; BIOS interrup to read data from disk
	jc .disk_error	; If there's an error (carry bit set)
	
	pop dx
	cmp al, dh	; al = sectors read
	jne .sectors_error ; if al != sectors we want to read, then throw an error

	popa
	ret

	.disk_error:
	mov bx, .DISK_ERROR
	call print
	jmp end_of_boot
	
	.sectors_error:
	mov bx, .SECTORS_ERROR
	call print
	jmp end_of_boot

	.DISK_ERROR: db "Disk read error",10,0
	.SECTORS_ERROR: db "Incorrect number of sectors read",10,0
