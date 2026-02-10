#include "../Library/VGA_Driver/VGA_Driver_v1.h"
#include "../Library/std/num_type/num_type.h"
#include "../Library/std/Simple_Dynamic_Memory/Simple_Dynamic_Memory.h"

void __attribute__((section(".Ctext"))) C_loader_main(void){
    uint8 VGA_x = 0;
    uint8 VGA_y = 0;
    uint16 *VGA = get_vga_memory();
    clean_screen(' ', COLOR(Black,Black));
    write_vga_text(&VGA, 'A', COLOR(Black, White));
    write_vga_texts(&VGA,"hello world", COLOR(Black, White));
    while(1){
        //write_vga_texts(&VGA,"tset", COLOR(Black, White));
    };
    return ;
}


void __attribute__((section(".Ctext"))) isr_C_function(void){
    //clean_screen('E', COLOR(Red,Black));
    //while(1){};
    return ;
}