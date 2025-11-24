[BITS 16]
[org 0x7c00]
section .text
;---------includeスペース----------
;%include "include_asm/LBA_16.asm"
;%include "include_asm/print_VGA.asm"

;---------------------------------

;----------定数作成スペース---------

;1ならtrue,0ならfalse
%define LBA 0

;LBAの設定
%define LBA_SIZE 1
%define LBA_SECTOR_OFFSET 0x0600
%define LBA_SECTOR_SEGMENT 0x0000
%define LBA_START_SECTOR 1

;セカンドローダーの設定
;%define SECOND_SECTOR 72
%define SECOND_SIZE 88
%define SECOND_SECTOR_OFFSET 0x8000
%define SECOND_SECTOR_SEGMENT 0x0000
%define SECOND_START_SECTOR 1

;%define VGA 0xb800

;----------------------------------

jmp start
;seciton .data

start_msg:
    db "BanHimaBootLoader Ver:a 0.0.1", 10, 0

error_msg:
    db "|Select sector no found|", 0
    
VGA:
    dq 0xb8000

back_color:
    db 0x00

text_color:
    db 0x07

color:
    db 0x07

corsor_Y:
    dd 0

corsor_X:
    dd 0

Boot_Drive:
    db 0

sector_size:
    dw 0

sector_offset:
    dw 0

sector_segment:
    dw 0

sector_num:
    dq 0

DAP:
    db 0x10;DAPの全体バイト数
    db 0
    dw 0;読み込むセクタ数
    dw 0;オフセット
    dw 0;セグメント
    dq 0;読み込みセクタ開始場所(セクタ0からの計算ではなく現在位置からの移動数)

;section .bss

;section .text

no_displey_corsor:
    pusha
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al

    inc dx
    mov al, 0x20
    out dx, al

    mov ah, 0x2
    mov bh, 0x00
    mov dh, 0
    mov dl, 0
    int 0x10
    popa
    ret

clean_screen_16bit:
    mov edi, 0xb8000
    mov ecx, 80 * 25
    mov ax, [back_color]
    jmp .loop
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    mov byte[corsor_X], 0
    mov byte[corsor_Y], 0
    ret
    
setup_color:
    mov al, [back_color]
    shl al, 4
    mov bl, [text_color]
    or al, bl
    mov byte [color], al
    ret

load_corsor:
    cmp al, 10
    pusha
    mov eax, [corsor_Y]
    mov ebx, [corsor_X]
    je .load_corsor_line_break
    jmp .load_corsor_end
.load_corsor_line_break:
    inc eax
    mov ebx, 0
.load_corsor_end:
    ;0xb8000+((y*80)+x)*2をもとに計算
    mov dword[corsor_Y], eax
    mov dword[corsor_X], ebx
    imul eax, 80
    add eax, ebx
    imul eax, eax, 2
    add eax, 0xb8000
    mov dword[VGA], eax
    popa
    mov edi, [VGA]
    ret

print:
    mov edi, [VGA]
    call setup_color
.print_loop:
    lodsb
    cmp al, 0
    je .done_print
    cmp al, 10
    je .line_break
.print_next:
    inc byte[corsor_X]
    mov ah, [color]
    
    mov [edi], ax
    add edi, 2
    jmp .print_loop
.line_break:
    call load_corsor
    jmp .print_loop
.done_print:
    mov byte [color], 0x07
    call load_corsor
    ret

DAPset:
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

start:
    cli
    mov byte[Boot_Drive], dl
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov es, ax
    mov ss, ax
    ;mov sp, 0x7bff
    mov sp, 0x7c00
    ;スタックの開始位置
    sti
    call no_displey_corsor
    ;call load_corsor_16bit
    call clean_screen_16bit
    call start_print
    call load_disk
    call load_sector
    ; ES:DI に文字セルのアドレス
    ; AL に文字コード、AH に属性

    mov ax, [corsor_X]
    mov bx, [corsor_Y]
    ;jmp 0x0000:0x8000
    jmp SECOND_SECTOR_SEGMENT:SECOND_SECTOR_OFFSET

start_print:;ブートローダー実行時に実行
    mov si, start_msg
    ;mov byte [color], 0x07
    call print
    ret

error_print:;指定の位置にファイルがなかった場合に実行
    mov si, error_msg
    mov byte [color], 0x0c
    call print
    jmp $

load_disk:
    push ax
    mov ax, LBA
    cmp ax, 1
    je load_lba
    jmp load_second

load_lba:
    mov ax, LBA

    mov ax, LBA_SIZE
    mov [sector_size], ax

    mov ax, LBA_SECTOR_OFFSET
    mov [sector_offset], ax

    mov ax, LBA_SECTOR_SEGMENT
    mov [sector_segment], ax

    mov ax, LBA_START_SECTOR
    mov [sector_num], ax

    call DAPset
    call load_sector
    jmp load_second

load_second:
    mov ax, LBA

    mov ax, SECOND_SIZE
    mov [sector_size], ax

    mov ax, SECOND_SECTOR_OFFSET
    mov [sector_offset], ax

    mov ax, SECOND_SECTOR_SEGMENT
    mov [sector_segment], ax

    mov ax, SECOND_START_SECTOR
    mov [sector_num], ax

    pop ax
    call DAPset
    call load_sector
    ret

load_sector:

    mov si, DAP
    mov ah, 0x42
    mov dl, [Boot_Drive]

    mov bx, [DAP + 4]
    mov ax, [DAP + 6]
    mov es, ax

    int 0x13
    
    jc error_print

    ret
    ;jmp 0x0000:0xFFFFF

times 510-($-$$) db 0
dw 0xaa55