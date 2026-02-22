#ifndef VBE_OPERATION
#define VBE_OPERATION 1
#define VBE_OPERATION_VERSION 1.0

#include "../std/stdlib/stdlib.h"

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

int write_pixel(const VBE_data *VBE, const int x, const int y, const unsigned int color){
    if(x < 0 || x > VBE->WIDTH || y < 0 || y > VBE->HEIGHT) return 1;
    unsigned char* p = (unsigned char*)VBE->VBE_Mems + ((y * VBE->one_line_bytes) + (x * (VBE->one_pix_bitnum / 8)));
    for(int i = 0;i < VBE->one_pix_bitnum / 8; i++){
        p[i] = (color >> (i * 8));
    }
    return 0;
}

void fill_screen(const VBE_data *VBE, const unsigned int color){
    unsigned char* vram = (unsigned int*)VBE->VBE_Mems;
    const unsigned int pix_byte_num = VBE->one_pix_bitnum / 8;
    const unsigned int loop_count = VBE->WIDTH * VBE->HEIGHT * pix_byte_num;
    for(unsigned int i = 0; i < loop_count; i += pix_byte_num){
        for(unsigned int c = 0; c < pix_byte_num; c++){
            vram[i + c] = color >> (c * 8);
        }
    }
    return ;
}

int write_line(const VBE_data *VBE, int x0, int y0, int x1, int y1, const unsigned int color){
    if(x0 >= VBE->WIDTH || x1 >= VBE->WIDTH)return 1;
    if(y0 >= VBE->HEIGHT || y1 >= VBE->HEIGHT) return 2;
    int dx = abs(x1 - x0);
    int dy = abs(y1 - y0);
    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;
    int err = dx - dy;
    while(1){
        write_pixel(VBE, x0, y0, color);
        if(x0 == x1 && y0 == y1)break;
        int e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x0 += sx;
        }
        if (e2 < dx) {
            err += dx;
            y0 += sy;
        }
    }

    return 0;
}

int write_draw_rect(const VBE_data *VBE, int x, int y, int w, int h, const unsigned int color){
    if(x >= VBE->WIDTH || w >= VBE->WIDTH)return 1;
    if(y >= VBE->HEIGHT || h >= VBE->HEIGHT) return 2;
    write_line(VBE, x, y, x+w, y, color);
    write_line(VBE, x, y, x, y+h, color);
    write_line(VBE, x, y+h, x+w, y+h, color);
    write_line(VBE, x+w, y, x+w, y+h, color);
    return ;
}

int write_fill_rect(const VBE_data *VBE, int x, int y, int w, int h, unsigned int color){
    if(x >= VBE->WIDTH || x+w >= VBE->WIDTH)return 1;
    if(y >= VBE->HEIGHT || y+h >= VBE->HEIGHT) return 2;
    if(y > h){
        int t = y;
        y = h;
        h = t;
    }
    for(int i = 0;i < h;i++){
        write_line(VBE, x, y+i, x+w, y+i, color);
    }
    return 0;
}

int write_draw_rect_crd(const VBE_data *VBE, int x0, int y0, int x1, int y1, const unsigned int color){
    write_draw_rect(VBE, x0, y0, x1 - x0, y1 - y0, color);
}

int write_fill_rect_crd(const VBE_data *VBE, int x0, int y0, int x1, int y1, const unsigned int color){
    return write_fill_rect(VBE, x0, y0, x1 - x0, y1 - y0, color);
}

#endif