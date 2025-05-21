#include "./drivers/display.h"
#include "./lebron_img.h"

void main(){
	clear_screen();
	kprint_at("LEBRON OS KERNEL STARTED...\n",0,0);
	
	kprint_at(lebron_image,0,0);

	kprint_at("LEBRON OS KERNEL HAS BEEN STOPPED...",0,24);
}
