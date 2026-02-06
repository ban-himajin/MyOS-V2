#ifndef VGA_DRIVER_V1
#define VGA_DRIVER_V1 1
#define VGA_Start_Memory 0xb8000
#define VGA_HEIGHT 25
#define VGA_WIDTH 80
#define COLLAR(tc, bc) ((tc<<4) | (bc))

//-----CollarList-----
#define Black 0
#define Brue 1
#define Green 2
#define Cyan 3
#define Red 4
#define Magenta 5
#define Brown 6
#define White 7
#define LightGray 8
#define LightBrue 9
#define LightGreen 10
#define LightLigthBrue 11
#define LightRed 12
#define LightMagenta 13
#define Yellow 14
#define LightWhite 15
//--------------------

unsigned short*  __attribute__((section(".Ctext"))) get_vga_memory(){//VGA Memory get function
    return (unsigned short*)VGA_Start_Memory;
}

int __attribute__((section(".Ctext"))) set_vga(unsigned short **VGA, const unsigned char VGA_x, const unsigned char VGA_y){//VGA memory set X,Y
    *VGA = (unsigned short*)VGA_Start_Memory + (VGA_y * VGA_WIDTH + VGA_x);
    return 0;
}

int  __attribute__((section(".Ctext"))) write_vga_text(unsigned short **VGA, unsigned char text, unsigned char collar){//VGA write text
    **VGA = (unsigned short)((collar << 8) | (text));
    (*VGA)++;
    return 0;
}

int  __attribute__((section(".Ctext"))) write_vga_texts(unsigned short **VGA, unsigned char text[], unsigned char collar){//VGA write texts
    unsigned int count;
    for(count = 0;text[count] != '\0';count++)write_vga_text(VGA, text[count], collar);
    return 0;
}

int  __attribute__((section(".Ctext"))) clean_screen (unsigned char offset_text, unsigned char offset_collar){//crean screen texts
    unsigned short *VGA = (unsigned short*)VGA_Start_Memory;
    int loop_count;
    for(loop_count = 0;loop_count < (VGA_HEIGHT * VGA_WIDTH);loop_count++)write_vga_text(&VGA, offset_text, offset_collar);
    return 0;
}

int  __attribute__((section(".Ctext"))) test(){
    return 0;
}

#endif