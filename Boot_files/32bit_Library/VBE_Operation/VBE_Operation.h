#ifndef VBE_OPERATION
#define VBE_OPERATION 1
#define VBE_OPERATION_VERSION 1.0

typedef struct{
    unsigned int WIDTH;//x
    unsigned int HEIGHT;//y
    unsigned int one_pix_bitnum;//BitsPerPixel
    unsigned int one_line_bytes;//BytesPerScanLine
    unsigned int MemoryMode;//MemoryMode
    unsigned int VBE_Mems;//PhyBasePtr
}VBE_data;

void write_pixel(const VBE_data *VBE, int x, int y, unsigned int color){
    unsigned char* bf = *(unsigned char*)VBE->VBE_Mems;
    unsigned int offset = (y * VBE->one_line_bytes + x * (VBE->one_pix_bitnum / 8));
    *((unsigned int*)(bf + offset)) = color;
    return ;
}

#endif