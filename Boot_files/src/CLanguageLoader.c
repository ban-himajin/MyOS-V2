#include "../Library/VGA_Driver/VGA_Driver_v1.h"


void __attribute__((section(".Ctext"))) C_loader_main(void){
    unsigned char VGA_x = 0;
    unsigned char VGA_y = 0;
    unsigned short *VGA = get_vga_memory();
    clean_screen(' ', COLLAR(Black,Black));
    write_vga_text(&VGA, 'A', COLLAR(Black, White));
    write_vga_texts(&VGA,"hello world", COLLAR(Black, White));
    while(1){
        //write_vga_texts(&VGA,"tset", COLLAR(Black, White));
    };
    return ;
}


void __attribute__((section(".Ctext"))) isr_C_function(void){
    clean_screen(' ', COLLAR(Red,Black));
    while(1){};
    return ;
}