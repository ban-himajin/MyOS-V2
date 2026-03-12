#ifndef BIOS_MOLD
#define BIOS_MOLD 1
#define BIOS_MOLD_VERSION 1

#define BIOS_VBE_MOLD_VERSION 1

//VBE_MOLDS
#if BIOS_VBE_MOLD_VERSION == 1
    #pragma pack(push, 1)
    typedef struct{
        unsigned short WIDTH;//x
        unsigned short HEIGHT;//y
        unsigned char one_pix_bitnum;//BitsPerPixel
        unsigned short one_line_bytes;//BytesPerScanLine
        unsigned char MemoryMode;//MemoryMode
        unsigned int VBE_Mems;//PhyBasePtr
    }VBE_data;
    #pragma pack(pop)

#endif
#define BIOS_MEMMAP_MOLD_VERSION 1

//MEMMAP_MOLDS
#if BIOS_MEMMAP_MOLD_VERSION == 1
    #pragma pack(push, 1)
    typedef struct{
        unsigned long start_address;
        unsigned long address_size;
        unsigned int mem_type;
        unsigned int mem_type;
        unsigned int extended_attributes;
    }mem_map;
    #pragma pack(pop)

    #pragma pack(push, 1)
    typedef struct{
        unsigned short *memmap_array_size;
        mem_map *mem_map_data;
    }mem_map_struct;
    #pragma pack(pop)

#endif

#endif