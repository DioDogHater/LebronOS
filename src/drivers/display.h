#ifndef __KERNEL_DRIVER_DISPLAY_H
#define __KERNEL_DRIVER_DISPLAY_H

#include "./ports.h"

#define VIDEO_MEMORY 0xb8000
#define WHITE_ON_BLACK 0x0F

// Compute video memory address offset
#define VGA_GET_OFFSET(c, r) (2*((r)*80+(c)))
#define VGA_GET_OFFSET_ROW(o) (((o)>>1)/80)
#define VGA_GET_OFFSET_COL(o) (((o)>>1)%80)

// Function prototypes
void kprint_at(char*,int,int);
#define kprint(s) kprint_at((s),-1,-1)
void kprint_decimal(int,int,int);
unsigned int kprint_char(unsigned char,int,int,unsigned char);
#define kputchar(c) kprint_char((c),-1,-1,0x0F)
unsigned int get_cursor_offset();
void set_cursor_offset(unsigned int);

// Kernel prints null-terminated string at (col, row)
// if col or row are negative, print at current cursor location
void kprint_at(char* str, int col, int row){
	unsigned char* vga_mem = (unsigned char*) VIDEO_MEMORY;
	unsigned int addr_offset;
	if(col >= 0 && row >= 0)
		addr_offset = VGA_GET_OFFSET(col,row);
	else
		addr_offset = get_cursor_offset();

	// Update cursor to print out efficiently
	set_cursor_offset(addr_offset);

	while(*str){
		// Print this character
		addr_offset = kprint_char(*str,-1,-1,WHITE_ON_BLACK);
		
		// Advance to next character
		str++;
	}
}

// Print n as a decimal number at (col, row)
void kprint_decimal(int n, int col, int row){
	if(n == 0) { kprint_char('0',col,row,WHITE_ON_BLACK); return; }
	unsigned char str[18];
	int i;
	str[17] = 0;
	for(i = 16; i > 0, n != 0; i--){
		str[i] = n % 10 + '0';
		n /= 10;
	}
	kprint_at(str+i+1,col,row);
}

// Print char at (col, row) with attributes (attr)
// if col or row are negative, then print at current cursor position
// returns the new cursor position
unsigned int kprint_char(unsigned char c, int col, int row, unsigned char attr){
	unsigned char* vga_mem = (unsigned char*) VIDEO_MEMORY;
	unsigned int addr_offset;

	if(col >= 0 && row >= 0){
		addr_offset = VGA_GET_OFFSET(col,row);
	}else{
		addr_offset = get_cursor_offset();
		col = VGA_GET_OFFSET_COL(addr_offset);
		row = VGA_GET_OFFSET_ROW(addr_offset);
	}
	
	if(c == '\n'){
		col = 0;
		row++;
		if(row >= 25)
			row = 0;
	}else{
		vga_mem[addr_offset] = c;
		vga_mem[addr_offset+1] = attr;
		col++;
		if(col >= 80){
			col = 0;
			row++;
			if(row >= 25)
				row = 0;
		}
	}
	
	addr_offset = VGA_GET_OFFSET(col,row);
	set_cursor_offset(addr_offset);
	return addr_offset;
}

// Get the offset of the current cursor position
unsigned int get_cursor_offset(){
	port_byte_out(VGA_PORT_CTRL, VGA_CURSOR_HIGH);
	unsigned int cursor_offset = port_byte_in(VGA_PORT_DATA) << 8;
	port_byte_out(VGA_PORT_CTRL, VGA_CURSOR_LOW);
	cursor_offset += port_byte_in(VGA_PORT_DATA);
	return cursor_offset*2;
}

// Set the offset of the current cursor position
void set_cursor_offset(unsigned int cursor_offset){
	cursor_offset /= 2;
	port_byte_out(VGA_PORT_CTRL,VGA_CURSOR_HIGH);
	port_byte_out(VGA_PORT_DATA, (unsigned char) (cursor_offset >> 8));
	port_byte_out(VGA_PORT_CTRL,VGA_CURSOR_LOW);
	port_byte_out(VGA_PORT_DATA, (unsigned char) (cursor_offset & 0xFF));
}

// Set current cursor position
void set_cursor_position(int col, int row){
	if(col < 0 || row < 0) return;
	set_cursor_offset((unsigned int)VGA_GET_OFFSET(col,row));
}

void clear_screen(){
	unsigned char* vga_mem = (unsigned char*) VIDEO_MEMORY;
	for(unsigned int i = 0; i < 80*25; i++){
		*vga_mem = 0;
		vga_mem[1] = 0;
		vga_mem += 2;
	}
	set_cursor_offset(0);
}

#endif
