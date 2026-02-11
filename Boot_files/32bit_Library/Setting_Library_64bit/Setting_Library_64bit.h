#ifndef SETTING_LIBRARY_64BIT
#define SETTING_LIBRARY_64BIT 1
#define SETTING_LIBRARY_VERSION 1.0

#define BIT 1
#define BYTE 8
#define KBYTE 1024ULL
#define MBYTE (1024 * KBYTE)
#define GBYTE (1024 * MBYTE)
#define TBYTE (1024 * GBYTE)
#define PBYTE (1024 * TBYTE)

#define P 0x1
#define RE 0x2
#define US 0x4
#define PWT 0x8
#define PCD 0x10
#define A 0x20
#define D 0x40
#define PS 0x80
#define PG 0x100
#define AVAILABLE1 0x200
#define AVAILABLE2 0x400
#define AVAILABLE3 0x800
#define XD 0x1000000000000

#include "../std/Simple_Dynamic_Memory/Simple_Dynamic_Memory.h"

typedef struct{
    unsigned char page_flag;
    unsigned int map_mem;
}PT;

typedef struct{
    unsigned char page_flag;
    unsigned int map_mem;
    unsigned short PT_size;
    PT* PT_data;
}PD;

typedef struct{
    unsigned char page_flag;
    unsigned int map_mem;
    unsigned short PD_size;
    PD* PD_data;
}PDPT;

typedef struct{
    unsigned char page_flag;
    unsigned int map_mem;
    unsigned short PDPT_size;
    PDPT* PDPT_data;
}PML4;

typedef struct{
    unsigned short PML4_size;
    PML4* PML4_data;
}Page_Table;

void* __attribute__((section(".Ctext"))) page_table_data(const unsigned short PML4_size,const unsigned short PDPT_size,const unsigned short PD_size,const unsigned short PT_size){
    Page_Table* page_data = SDMemory(sizeof(Page_Table));
    page_data->PML4_data = SDMemory(sizeof(PML4) * PML4_size);
    for(int i = 0; i < PML4_size; i++){
        page_data->PML4_data[i].PDPT_data = SDMemory(sizeof(PDPT) * PDPT_size);
        for(int j = 0; j < PDPT_size; j++){
            page_data->PML4_data[i].PDPT_data[j].PD_data = SDMemory(sizeof(PD) * PD_size);
            for(int k = 0; k < PT_size; k++){
                page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_data = SDMemory(sizeof(PT) * PT_size);
            }
        }
    }
    return (void*)page_data;
}

int __attribute__((section(".Ctext"))) PML4_set_map_mem(PML4* pages, const unsigned int mems, const unsigned char flag){
    if(mems % (unsigned long long)(512*(unsigned long long)(512*GBYTE)) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        return 0;
    }
    return 1;
}

int __attribute__((section(".Ctext"))) PDPT_set_map_mem(PDPT* pages, const unsigned int mems, const unsigned char flag){
    if(mems % (unsigned long long)(512*GBYTE) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        return 0;
    }
    return 1;
}

int __attribute__((section(".Ctext"))) PD_set_map_mem(PD* pages, const unsigned int mems, const unsigned char flag){
    if(mems % (unsigned long long)(512*(unsigned long long)(2*MBYTE)) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        return 0;
    }
    return 1;
}

int __attribute__((section(".Ctext"))) PT_set_map_mem(PT* pages, const unsigned int mems, const unsigned char flag){
    if(mems % (unsigned long long)(512*(unsigned long long)(4*KBYTE)) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        return 0;
    }
    return 1;
}

#endif