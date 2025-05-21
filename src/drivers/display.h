#ifndef __KERNEL_DRIVER_DISPLAY_H
#define __KERNEL_DRIVER_DISPLAY_H

#include <stdarg.h>
#include "./ports.h"

#define VIDEO_MEMORY 0xb8000
#define WHITE_ON_BLACK 0x0F

// Global variable that stores the current text attribute (text color)
unsigned char KERNEL_TEXT_ATTRIBUTE = WHITE_ON_BLACK;

// Compute video memory address offset
unsigned int VGA_GET_OFFSET(unsigned int c, unsigned int r) { return (r*80+c)<<1; }
unsigned int VGA_GET_OFFSET_ROW(unsigned int offset) { return (offset>>1)/80; }
unsigned int VGA_GET_OFFSET_COL(unsigned int offset) { return (offset>>1)%80; }

// Function prototypes
void kprint_at(char*,int,int);
#define kprint(s) kprint_at((s),-1,-1)
void kprint_decimal(int,int,int);
void kprint_hex(int,int,int);
void kprintf(const char*,...);
unsigned int kputchar_at(unsigned char,int,int);
#define kputchar(c) kputchar_at((c),-1,-1)
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
		kputchar(*str);
		
		// Advance to next character
		str++;
	}
}

// Print n as a decimal number at (col, row)
void kprint_decimal(int n, int col, int row){
	if(n == 0) { kputchar_at('0',col,row); return; }
	unsigned char str[30], is_negative = n < 0;
	int i;
	str[29] = 0;
	if(is_negative) n = -n;
	for(i = 28; i > 0 && n != 0; i--){
		str[i] = n % 10 + '0';
		n /= 10;
	}
	if(is_negative) str[i--] = '-';
	kprint_at(str+i+1,col,row);
}

// Print n as a hexadecimal number at (col, row)
void kprint_hex(int n, int col, int row){
	if(n == 0) { kprint_at("0x0",col,row); return; }
	unsigned char str[30];
	int i;
	str[29] = 0;
	for(i = 28; i > 1 && n != 0; i--){
		if((n & 0xF) < 10)
			str[i] = (n & 0xF) + '0';
		else
			str[i] = (n & 0xF) - 10 + 'A';
		n = n >> 4;
	}
	str[i--] = 'x';
	str[i] = '0';
	kprint_at(str+i,col,row);
}

// Print formatted string with ... arguments
// %d -> decimal (int), %x -> hex (int), %b -> bool (char)
// %s -> string (char*), %c -> char, %p -> pointer (void*)
// %% -> '%'
void kprintf(const char* format, ...){
	va_list args;
	for(va_start(args, format); *format != 0; format++){
		if(*format == '%'){
			format++;
			switch(*format){
				case 'd':
					kprint_decimal(va_arg(args, int),-1,-1);
					break;
				case 'x':
					kprint_hex(va_arg(args,int),-1,-1);
					break;
				case 'b':
					kprint((_Bool)va_arg(args,int) ? "true" : "false");
					break;
				case 's':
					kprint(va_arg(args,char*));
					break;
				case 'c':
					kputchar((char)va_arg(args,int));
					break;
				case '%':
					kputchar('%');
					break;
				default:
					return;
			}
		}else
			kputchar(*format);
	}
}

// Print char at (col, row) with attributes (attr)
// if col or row are negative, then print at current cursor position
// returns the new cursor position
unsigned int kputchar_at(unsigned char c, int col, int row){
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
		vga_mem[addr_offset+1] = KERNEL_TEXT_ATTRIBUTE;
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
	return cursor_offset<<1;
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

// Clear the whole screen's text
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
