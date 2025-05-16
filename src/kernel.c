#include "./drivers/display.h"

const char loading_bar[] = "-\\|/";

void main(){
	clear_screen();
	kprint_at("LEBRON OS KERNEL STARTED...\n",0,0);
	
	kprint_at("LEBRON OS KERNEL HAS BEEN STOPPED...\n",0,0);
}
