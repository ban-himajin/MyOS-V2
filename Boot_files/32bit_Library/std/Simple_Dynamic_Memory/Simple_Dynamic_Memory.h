#ifndef SIMPLE_DYANMIC_MEMORY
#define SIMPLE_DYANMIC_MEMORY 1
#define SIMPLE_DYANMIC_MEMORY_VERSION 1.0

typedef unsigned int size32_t;
extern char end;
char* end_memory = &end;


void* __attribute__((section(".Ctext")))  SDMemory(size32_t size){
    void* start_memory = (void*)end_memory;
    end_memory += size;
    return start_memory;
}

void __attribute__((section(".Ctext"))) align32(unsigned int size){
    end_memory = end_memory + (end_memory - (end_memory%size))
    return ;
}

#endif