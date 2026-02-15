#ifndef VGA_DRIVER
#define VGA_DRIVER 1
#define VGA_VERSION 1.0
#define VGA_START_MEMORY 0xb8000
#define VGA_HEIGHT 25
#define VGA_WIDTH 80
#define COLOR(bc, tc) ((bc<<4) | (tc))

//-----ColorList-----
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

typedef struct{
    unsigned short *VGA;
    char x;
    char y;
}VGA_data;

unsigned short* get_vga_memory(){//VGA Memory get function
    return (unsigned short*)VGA_START_MEMORY;
}

int set_vga(VGA_data *VGA){//VGA memory set X,Y
    VGA->VGA = (unsigned short*)VGA_START_MEMORY + (VGA->y * VGA_WIDTH + VGA->x);
    return 0;
}

int write_vga_text(VGA_data *VGA, const unsigned char text, const unsigned char color){//VGA write text
    *(VGA->VGA) = (unsigned short)((color << 8) | (text));
    VGA->VGA++;
    if(VGA->x > VGA_WIDTH){
        VGA->y++;
        VGA->x = 0;
    }
    else VGA->x++;
    return 0;
}

int write_vga_texts(VGA_data *VGA, const char* text, const unsigned char color){//VGA write texts
    unsigned int count;
    for(count = 0;text[count] != '\0';count++){
        if(text[count] == '\n'){
            VGA->y++;
            VGA->x = 0;
            set_vga(VGA);
        }
        else write_vga_text(VGA, text[count], color);
    }
    return 0;
}

int clean_screen (const unsigned char offset_text, const unsigned char offset_color){//crean screen texts
    VGA_data VGA = {(unsigned short*)VGA_START_MEMORY};
    int loop_count;
    for(loop_count = 0;loop_count < (VGA_HEIGHT * VGA_WIDTH);loop_count++)write_vga_text(&VGA, offset_text, offset_color);
    return 0;
}

#endif