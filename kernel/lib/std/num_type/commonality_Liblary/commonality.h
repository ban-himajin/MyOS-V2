#ifndef COMMONALITY
#define COMMONALITY 1
#define COMMONALITY_VERSION 1

#include "./BIOS_mold/BIOS_mold.h"

#pragma pack(push, 1)
typedef struct{
    char* bios_type[4];
    union {
        struct {
            VBE_data *VBE;
            mem_map_struct *mem_map;
        }BIOS;
        struct {

        }UIEF;
    }BIOS_and_UEFI;
    
}BIOS_and_UEFI_struct;
#pragma pack(pop)

typedef struct{

}common_struct;

#endif