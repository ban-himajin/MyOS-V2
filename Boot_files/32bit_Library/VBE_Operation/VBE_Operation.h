#ifndef VBE_OPERATION
#define VBE_OPERATION 1
#define VBE_OPERATION_VERSION 1.0

#pragma pack(push, 1)
typedef struct{
    //unsigned char WIDTH;//x
    unsigned short WIDTH;//x
    //unsigned char HEIGHT;//y
    unsigned short HEIGHT;//y
    unsigned char one_pix_bitnum;//BitsPerPixel
    unsigned short one_line_bytes;//BytesPerScanLine
    unsigned char MemoryMode;//MemoryMode
    unsigned int VBE_Mems;//PhyBasePtr
}VBE_data;
#pragma pack(pop)


void write_pixel(const VBE_data *VBE, int x, int y, unsigned int color){
    unsigned char* p = (unsigned char*)VBE->VBE_Mems + ((y * VBE->one_line_bytes) + (x * (VBE->one_pix_bitnum / 8)));
    for(int i = 0;i < VBE->one_pix_bitnum / 8; i++){
        p[i] = (color >> (i * 8));
    }
    return ;
}

#endif