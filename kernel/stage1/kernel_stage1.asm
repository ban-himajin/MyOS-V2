[Bits 64]

section .data
gdt64bit_start:
    dq 0x0000000000000000

    dq 0x00AF9A000000FFFF

    dq 0x00AF92000000FFFF

gdt64bit_end:
gdt64bit_descriptor:
    dw gdt64bit_end - gdt64bit_start - 1
    dd gdt64bit_start

boot_data:
    dw 0    ;bios_type
    dw 0    ;VBE_datas
    dw 0    ;mem_map_struct

section .text
start_kernel:
    extern kernel_stage_one_main
    cli
    pop rax
    mov boot_data, rax
    lgdt[gdt64bit_descriptor]
    xor ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ss, ax

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    xor rsi, rsi
    xor rdi, rdi
    xor rbp, rbp
    xor r8,  r8
    xor r9,  r9
    xor r10, r10
    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15

    ;mov rsp, 0xFFFFD554C0000000
    mov rsp, 0xfffff
    mov rbx, rax


.hang:
    hlt
    jmp .hang