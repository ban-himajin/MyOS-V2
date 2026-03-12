#ifndef SIMPLE_DYANMIC_MEMORY
#define SIMPLE_DYANMIC_MEMORY 1
#define SIMPLE_DYANMIC_MEMORY_VERSION 1.0

typedef unsigned int size32_t;
extern char end;
char* end_memory = &end;


void* SDMemory(size32_t size){
    void* start_memory = (void*)end_memory;
    end_memory += size;
    return start_memory;
}

void* align32(size32_t size){
    unsigned long long pad = ((unsigned int)end_memory % size);
    if(pad != 0)end_memory = end_memory + (size - pad);
    return end_memory;
}

#endif