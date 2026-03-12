//#include ".\lib\VGA_Driver\VGA_Driver.h"
#include "..\lib\std\num_type\num_type.h"
#include "..\lib\std\Simple_Dynamic_Memory\Simple_Dynamic_Memory.h"
#include "..\lib\Setting_Library_64bit\Setting_Library_64bit.h"
#include "..\lib\ELF_Analysis\ELF_Analysis.h"
#include "..\lib\VBE_Operation\VBE_Operation.h"
#include "..\lib\std\stdlib\stdlib.h"

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

typedef struct{
    uint8 type;
    union{
        struct{
            uint64 adr;
        }address;
        struct{
            uint32 PML4_index:9;
            uint32 PDPT_index:9;
            uint32 PD_index:9;
            uint32 PT_index:9;
        }page;
    };
}Kernel_page_struct;

void C_loader_main(uint64* kernel_mem, VBE_data* VBE, ELF_data *ELF_datas, uint64 *page_data_memory){
    fill_screen(VBE, 0x000040);
    Kernel_page_struct kernel_page = {
        .type = 0,
        // .page = {
        //     511, 0, 0, 0
        // }
        .address = {
            .adr = (uint64)kernel_mem
        }
    };
    if(ELF_Analysis(*kernel_mem, ELF_datas) == -1){
        fill_screen(VBE, 0x004000);
        //while(1);
    };
    Page_Table *Page_data = page_table_data(1,1,1,511);
    //Page_Table *Page_data = page_table_data(1,1,1,1);
    if(Page_data == 1){
        fill_screen(VBE, 0x400000);
        while(1);
    }
    PML4_set_map_mem(&(Page_data->PML4_data[0]), 0, (P | RE), 0);
    PDPT_set_map_mem(&(Page_data->PML4_data[0].PDPT_data[0]), 0, (P | RE), 0);
    PD_set_map_mem(&(Page_data->PML4_data[0].PDPT_data[0].PD_data[0]), 0, (P | RE), 0);
    for(int32 i = 0;i < Page_data->PML4_data[0].PDPT_data[0].PD_data[0].PT_size ;i++)PT_set_map_mem(&(Page_data->PML4_data[0].PDPT_data[0].PD_data[0].PT_data[i]), i * 0x1000, (P | RE), i);
    // PML4_set_map_mem(&(Page_data->PML4_data[1]), 0, (P | RE), kernel_page.PML4_index);
    // PDPT_set_map_mem(&(Page_data->PML4_data[1].PDPT_data[0]), 0, (P | RE), kernel_page.PDPT_index);
    // PD_set_map_mem(&(Page_data->PML4_data[1].PDPT_data[0].PD_data[0]), 0, (P | RE), kernel_page.PD_index);
    // for(int i = 0;i < Page_data->PML4_data[1].PDPT_data[0].PD_data[0].PT_size ;i++)PT_set_map_mem(&(Page_data->PML4_data[1].PDPT_data[0].PD_data[0].PT_data[i]), (i + 1) * 0x1000 + *kernel_mem, (P | RE), i);
    *page_data_memory = make_page_data(Page_data);
    write_fill_rect(VBE, 0, 100, 100, 100, page_data_memory);
    write_fill_rect(VBE, 0, 200, 100, 100, *page_data_memory);
    if(!page_data_memory){
        fill_screen(VBE, 0xff0000);
        while(1);
    }
    //fill_screen(VBE, 0x000000);
    uint64 virtual_kernel_mems = 0;
    if(kernel_page.type == 0){
        virtual_kernel_mems = kernel_page.address.adr << 12;
    }
    else{
        virtual_kernel_mems = ((unsigned long long)kernel_page.page.PML4_index << 39) | ((unsigned long long)kernel_page.page.PDPT_index << 30) | (kernel_page.page.PD_index << 21) | (kernel_page.page.PT_index << 12);
    }
    *kernel_mem = virtual_kernel_mems;
    //while(1);
    return ;
}


void isr_C_function(isr_list* isr_data){
    return ;
}

void err_screen(VBE_data* VBE){
    fill_screen(VBE, 0x0000ff);
    while(1);
}