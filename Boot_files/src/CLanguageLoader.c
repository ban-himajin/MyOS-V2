//#include "../32bit_Library/VGA_Driver/VGA_Driver.h"
#include "../32bit_Library/std/num_type/num_type.h"
#include "../32bit_Library/std/Simple_Dynamic_Memory/Simple_Dynamic_Memory.h"
#include "../32bit_Library/Setting_Library_64bit/Setting_Library_64bit.h"
#include "../32bit_Library/ELF_Analysis/ELF_Analysis.h"
#include "../32bit_Library/VBE_Operation/VBE_Operation.h"
#include "../32bit_Library/std/stdlib/stdlib.h"

typedef struct{
    uint16 GS;
    uint16 FS;
    uint16 ES;
    uint16 DS;
    
    uint16 AX;
    uint16 CX;
    uint16 DX;
    uint16 BX;
    uint16 SP;
    uint16 BP;
    uint16 SI;
    uint16 DI;

    uint16 isr_num;
    uint16 error_code;
}isr_list;

void C_loader_main(const unsigned char* kernel_mem, VBE_data* VBE){
    fill_screen(VBE, 0x000040);
    while(1);
    return ;
}


void isr_C_function(isr_list* isr_data){
    return ;
}

void err_screen(VBE_data* VBE){
    fill_screen(VBE, 0x0000ff);
    while(1);
}