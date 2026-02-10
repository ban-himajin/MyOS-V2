;[org 0x8000]

;MainKernelLoderPrograms

;-------ProgramConstantDatas------
%define Kernel_SIZE 0
%define Kernel_SECTOR_OFFSET 0x0000
%define Kernel_SECTOR_SEGMENT 0x0000
%define Kernel_START_SECTOR 0

;----------------------------------


;-------ProgramAllDate------------
;ProgramLabelValuesSection

Boot_Drive:;StartDeviceIDNumKeepLabel
    db 0

sector_size:;DAPInfomation
    dw 0

sector_offset:;DAPInfomation
    dw 0

sector_segment:;DAPInfomation
    dw 0

sector_num:;DAPInfomation
    dq 0

DAP:
    db 0x10;DAP_AllByteSize
    db 0
    dw 0;ReadSecterNum
    dw 0;Offset
    dw 0;Segment
    dq 0;StartoSecterNum

;-------16bitMode--------
[Bits 16]
;16BitSections
section .data16
gdt32bit_start:
    dw 0x0000
    dw 0x0000
    db 0x00
    db 0x00
    db 0x00
    db 0x00

    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x9a
    db 0xcf
    db 0x00

    dw 0xffff
    dw 0x0000
    db 0x00
    db 0x92
    db 0xcf
    db 0x00
gdt32bit_end:

gdt32bit_descriptor:
    dw gdt32bit_end - gdt32bit_start - 1
    dd gdt32bit_start

;16BitMainText
section .text16
;[Bits 16]
global start_16bit
start_16bit:
    cli
    mov byte[Boot_Drive], dl
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7fff

    sti
    call enable_a20_fast
    call load_kernel
    jmp setup_protect_mode
    
enable_a20_fast:;A20 balid func
    in  al, 0x92
    or  al, 0x02
    out 0x92,al
    ret

DAPset:;DBPLabelUseSet
    mov ax, [sector_size]
    mov word[DAP + 2], ax

    mov ax, [sector_offset]
    mov word[DAP + 4], ax

    mov ax, [sector_segment]
    mov word[DAP + 6], ax

    mov ax, word[sector_num]
    mov [DAP + 8], eax
    mov ax, word[sector_num + 2]
    mov [DAP + 10], eax

    ret

load_kernel:    
    mov ax, Kernel_SIZE
    mov [sector_size], ax

    mov ax, Kernel_SECTOR_OFFSET
    mov [sector_offset], ax

    mov ax, Kernel_SECTOR_SEGMENT
    mov [sector_segment], ax

    mov ax, Kernel_START_SECTOR
    mov [sector_num], ax

    call DAPset
    call read_secter_func
    ret

read_secter_func:;ReadOnlyFunction
    mov si, DAP
    mov ah, 0x42
    mov dl, [Boot_Drive]
    int 0x13
    
    jc .read_error
    ret
.read_error:;ReadSecterError
    hlt
    jmp .read_error

setup_protect_mode:

    cli
    lgdt [gdt32bit_descriptor]
    mov eax, cr0
    or eax, 0x01
    mov cr0, eax
    ;sti
    jmp 0x08:start_32bit

[Bits 32]
;-----------32bitマクロ定義セクション-------------
%macro set_idt_entry_32bit 3
    ;%1:割り込み番号
    ;%2:ハンドラアドレス
    ;%3:セグメントセレクタ

    lea eax, [%2]                 ; ハンドラの線形アドレス取得

    mov word [idt_32bit + %1*8 + 0], ax     ;offset_low
    mov word [idt_32bit + %1*8 + 2], %3     ;selector
    mov byte [idt_32bit + %1*8 + 4], 0      ;zero
    mov byte [idt_32bit + %1*8 + 5], 0x8E   ;type_attr(割り込みゲート)
    shr eax, 16
    mov word [idt_32bit + %1*8 + 6], ax     ;offset_high
%endmacro

;------------------------------------------
section .data32
idt_32bit:
    times 256 * 8 db 0
idt_ptr_32bit:
    dw 256 * 8 - 1
    dd idt_32bit

PIC1_IRQ_mask_data:
    db 0x00

PIC2_IRQ_mask_data:
    db 0x00

section .text32
start_32bit:
    extern C_loader_main
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9fc00
    mov ebp, esp
    call set_idt_32bit
    call set_irq_32bit
    sti
    call C_loader_main

    jmp $

.hang:
    hlt
    jmp .hang

set_irq_32bit:
    %define PIC1 0x20
    %define PIC2 0xA0
    %define PIC1_DATA 0x21
    %define PIC2_DATA 0xA1

    ;ICW1
    mov al, 0x11
    out PIC1, al
    out PIC2, al

    ;ICW2
    mov al, 0x20
    out PIC1_DATA, al
    mov al, 0x28
    out PIC2_DATA, al

    ;ICW3
    mov al, 0x4
    out PIC1_DATA, al
    mov al, 0x2
    out PIC2_DATA, al

    ;ICW4
    mov al, 0x01
    out PIC1_DATA, al
    out PIC2_DATA, al

    mov al, byte[PIC1_IRQ_mask_data]
    out PIC1_DATA, al
    mov al, byte[PIC2_IRQ_mask_data]
    out PIC2_DATA, al

    ret

set_idt_32bit:
    set_idt_entry_32bit 0, isr0_32bit, 0x08
    set_idt_entry_32bit 5, isr5_32bit, 0x08
    set_idt_entry_32bit 6, isr6_32bit, 0x08
    set_idt_entry_32bit 8, isr8_32bit, 0x08
    set_idt_entry_32bit 11, isr11_32bit, 0x08
    set_idt_entry_32bit 12, isr12_32bit, 0x08
    set_idt_entry_32bit 13, isr13_32bit, 0x08
    set_idt_entry_32bit 14, isr14_32bit, 0x08
    set_idt_entry_32bit 16, isr16_32bit, 0x08
    lidt [idt_ptr_32bit]
    ret

;--------isr_set_field-----------
global isr0_32bit
isr0_32bit:
    push dword 0
    push dword 0
    jmp isr_common

global isr5_32bit
isr5_32bit:
    push dword 0
    push dword 5
    jmp isr_common

global isr6_32bit
isr6_32bit:
    push dword 0
    push dword 6
    jmp isr_common

global isr8_32bit
isr8_32bit:
    push dword 8
    jmp isr_common

global isr11_32bit
isr11_32bit:
    push dword 11
    jmp isr_common

global isr12_32bit
isr12_32bit:
    push dword 12
    jmp isr_common

global isr13_32bit
isr13_32bit:
    ;push dword 13
    jmp isr_common

global isr14_32bit
isr14_32bit:
    push dword 14
    jmp isr_common

global isr16_32bit
isr16_32bit:
    push dword 0
    push dword 16
    jmp isr_common



;--------isr_common_function------------
;global isr_common
extern isr_C_function
isr_common:
    ;jmp $
    cli
    pusha

    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax

    push esp
    call isr_C_function
    add esp, 4

    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 4
    sti
    iret

.hang:
    hlt
    jmp .hang