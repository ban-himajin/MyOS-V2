#ifndef STDLIB
#define STDLIB 1
#define STDLIBVERSION 1.0

#define true 1
#define false 0
#define NULL 0

int abs(int x){
    if (x < 0) return -x;
    return x;
}

#endif