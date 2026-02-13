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
    unsigned short page_flag : 12;
    unsigned long long map_mem;
    unsigned short index_num : 9;
}PT;

typedef struct{
    unsigned short page_flag : 12;
    unsigned long long map_mem;
    unsigned short index_num : 9;
    unsigned short PT_size : 9;
    PT* PT_data;
}PD;

typedef struct{
    unsigned short page_flag : 12;
    unsigned long long map_mem;
    unsigned short index_num : 9;
    unsigned short PD_size : 9;
    PD* PD_data;
}PDPT;

typedef struct{
    unsigned short page_flag : 12;
    unsigned long long map_mem : 52;
    unsigned short index_num : 9;
    unsigned short PDPT_size;
    PDPT* PDPT_data;
}PML4;

typedef struct{
    unsigned short PML4_size : 9;
    PML4* PML4_data;
}Page_Table;

void* __attribute__((section(".Ctext"))) page_table_data(const unsigned short PML4_size, const unsigned short PDPT_size, const unsigned short PD_size, const unsigned short PT_size){
    Page_Table* page_data = SDMemory(sizeof(Page_Table));
    page_data->PML4_data = SDMemory(sizeof(PML4) * PML4_size);
    page_data->PML4_size = PML4_size;
    for(int i = 0; i < PML4_size; i++){
        page_data->PML4_data[i].PDPT_data = SDMemory(sizeof(PDPT) * PDPT_size);
        page_data->PML4_data->PDPT_size = PDPT_size;
        for(int j = 0; j < PDPT_size; j++){
            page_data->PML4_data[i].PDPT_data[j].PD_data = SDMemory(sizeof(PD) * PD_size);
            page_data->PML4_data->PDPT_data->PD_size = PD_size;
            for(int k = 0; k < PT_size; k++){
                page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_data = SDMemory(sizeof(PT) * PT_size);
                page_data->PML4_data->PDPT_data->PD_data->PT_size = PT_size;
            }
        }
    }
    return page_data;
}

int __attribute__((section(".Ctext"))) PML4_set_map_mem(PML4* pages, const unsigned int mems, const unsigned short flag, const unsigned short index){
    if(mems % (unsigned long long)(512*(unsigned long long)(512*GBYTE)) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        pages->index_num = index;
        return 0;
    }
    return 1;
}

int __attribute__((section(".Ctext"))) PDPT_set_map_mem(PDPT* pages, const unsigned int mems, const unsigned short flag, const unsigned short index){
    if(mems % (unsigned long long)(512*GBYTE) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        pages->index_num = index;
        return 0;
    }
    return 1;
}

int __attribute__((section(".Ctext"))) PD_set_map_mem(PD* pages, const unsigned int mems, const unsigned short flag, const unsigned short index){
    if(mems % (unsigned long long)(512*(unsigned long long)(2*MBYTE)) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        pages->index_num = index;
        return 0;
    }
    return 1;
}

int __attribute__((section(".Ctext"))) PT_set_map_mem(PT* pages, const unsigned int mems, const unsigned short flag, const unsigned short index){
    if(mems % (unsigned long long)(512*(unsigned long long)(4*KBYTE)) == 0){
        pages->map_mem = mems;
        pages->page_flag = flag;
        pages->index_num = index;
        return 0;
    }
    return 1;
}

unsigned long long* __attribute__((section(".Ctext"))) make_page_data(const Page_Table* page_data){
    unsigned int* PML4_start = align32(4 * KBYTE);
    if(page_data->PML4_size == 0) return 0;
    unsigned long long* page_table = SDMemory(sizeof(unsigned long long) * 512);
    unsigned long long* PML4 = page_table;
    unsigned long long* PDPT;
    unsigned long long* PD;
    unsigned long long* PT;
    for(int i = 0;i < page_data->PML4_size;i++){//PML4エントリチェック PML4のサイズが0ならループに入れない
        if(page_data->PML4_data[i].PDPT_size == 0){
            PML4[page_data->PML4_data[i].index_num] = ((unsigned long long)page_data->PML4_data[i].map_mem << 12) | page_data->PML4_data[i].page_flag;
            continue;
        }
        PDPT = (unsigned long long*)SDMemory(sizeof(unsigned long long) * 512);
        PML4[page_data->PML4_data[i].index_num] = ((unsigned long long)PDPT << 12) | page_data->PML4_data[i].page_flag;

        for(int j = 0;j < page_data->PML4_data[i].PDPT_size;j++){//PDPTエントリチェック
            if(page_data->PML4_data[i].PDPT_data[j].PD_size == 0){
                PDPT[page_data->PML4_data[i].PDPT_data[j].index_num] = ((unsigned long long)page_data->PML4_data[i].PDPT_data[j].map_mem << 12) | page_data->PML4_data[i].PDPT_data[j].page_flag;
                continue;
            }
            PD = (unsigned long long*)SDMemory(sizeof(unsigned long long) * 512);
            PDPT[page_data->PML4_data[i].PDPT_data[j].index_num] = ((unsigned long long)PD << 12) | page_data->PML4_data[i].PDPT_data[j].page_flag;
            
            for(int k = 0;k < page_data->PML4_data[i].PDPT_data[j].PD_size;k++){//PDエントリチェック
                if(page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_size == 0){
                    PD[page_data->PML4_data[i].PDPT_data[j].PD_data[k].index_num] = ((unsigned long long)page_data->PML4_data[i].PDPT_data[j].PD_data[k].map_mem << 12) | page_data->PML4_data[i].PDPT_data[j].PD_data[k].page_flag;
                    continue;
                }
                PT = (unsigned long long*)SDMemory(sizeof(unsigned long long) * 512);
                PD[page_data->PML4_data[i].PDPT_data[j].PD_data[k].index_num] = ((unsigned long long)PT << 12) | page_data->PML4_data[i].PDPT_data[j].PD_data[k].page_flag;

                for(int n = 0;n <  page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_size;n++){
                    PT[page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_data[n].index_num] = ((unsigned long long)page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_data[n].map_mem << 12) | page_data->PML4_data[i].PDPT_data[j].PD_data[k].PT_data[n].page_flag;
                }
            }
        }

    }
    return page_table;
}

#endif