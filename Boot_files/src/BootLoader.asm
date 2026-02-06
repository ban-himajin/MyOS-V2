;[org 0x8000]

;MainBootLoderPrograms

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
    jmp setup_protect_mode
    
enable_a20_fast:;A20 balid func
    in  al, 0x92
    or  al, 0x02
    out 0x92,al
    ret

setDAP:;DBPLabelUseSet
    push ax

    mov ax, [sector_size]
    mov word[DAP + 2], ax

    mov ax, [sector_offset]
    mov word[DAP + 4], ax

    mov ax, [sector_segment]
    mov word[DAP + 6], ax

    mov ax, word[sector_num]
    mov [DAP + 8], ax
    mov ax, word[sector_num + 2]
    mov [DAP + 10], ax

    pop ax
    ret

read_secter_func:;ReadOnlyFunction
    mov si, DAP
    mov ah, 0x42
    mov dl, [Boot_Drive]
    int 0x13

    mov bx, [DAP + 4]
    mov ax, [DAP + 6]
    mov es, ax
    
    jc .read_error
    ret

.read_error:;ReadSecterError
    jmp $
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

    mov word [idt_32bit + %1 * 8 + 0], (%2-$$) & 0xffff   ;offset_low
    mov word [idt_32bit + %1 * 8 + 2], %3                 ;selector
    mov byte [idt_32bit + %1 * 8 + 4], 0                  ;zero
    mov byte [idt_32bit + %1 * 8 + 5], 0x8e               ;type_attr(割り込みゲート)
    mov word [idt_32bit + %1 * 8 + 6], (%2-$$) >> 16      ;offset_high
%endmacro

;------------------------------------------
section .data32
idt_32bit:
    times 256 * 8 db 0
idt_ptr_32bit:
    dw 256 * 8 - 1
    dd idt_32bit

section .text32
;[bits 32]
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
    ;mov dword [0xB8000], 0x2F332F33 ; "33"
    call C_loader_main
    sti
    jmp $

.hang:
    hlt
    jmp .hang

;init_32bit:
;    ret

set_idt_32bit:
    cli
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
    sti
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
    push dword 13
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
global isr_common
extern isr_C_function
isr_common:
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
    ;call isr_C_function
    add esp, 4

    pop gs
    pop fs
    pop es
    pop ds
    popa
    ;add esp, 4
    sti
    iret

.hang:
    hlt
    jmp .hang