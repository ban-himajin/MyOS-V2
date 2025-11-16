[BITS 16]
[org 0x7c00]

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

%define VGA 0xb8000

;----------------------------------


jmp start
;seciton .data

start_msg:
    db "BanHimaBootLoader Ver:a 0.0.1", 10, 0

error_msg:
    db "|Select sector no found|", 0
    
back_color_32bit:
    db 0x00

color:
    db 0x07

corsor_Y:
    db 0x00

corsor_X:
    db 0x00

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

load_corsor:
    mov ah, 0x03
    mov bh, 0x00
    int 0x10
    mov byte [corsor_Y], dh
    mov byte [corsor_X], dl
    je .load_corsor_line_break
    ret
.load_corsor_line_break:
    mov ah, 0x2
    mov dh, 0x00
    add dh, 1
    mov dl, 0
    mov byte [corsor_Y], dh
    mov byte [corsor_X], dl
    int 0x10
    ret

clean_screen:
    mov edi, VGA
    mov ecx, 80 * 25
    mov ax, [back_color_32bit]
    jmp .loop
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    ret

print:;printの初めの部分
    lodsb
    cmp al, 0
    je .done_print
    cmp al, 10
    je .line_break
.print_next:
    mov ah, 0x0e
    mov bh, 0x00
    ;ページ番号
    mov bl, [color]
    ;文字の色
    int 0x10
    jmp print
.line_break:
    call load_corsor
    jmp .print_next
.done_print:
    mov byte [color], 0x07
    call load_corsor
    ret

print_vga:
    lodsb
    cmp al, 0
    je .done_print_vga
    mov ah, [color]
    mov [es:di], ax
    add di, 2
    jmp print_vga
.done_print_vga:
    mov byte [color], 0x07
    call get_corsor
    ret

get_corsor:
    mov ah, 0x03
    mov bh, 0x00
    int 0x10
    mov byte [corsor_Y], dh
    mov byte [corsor_X], dl
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
    mov sp, 0x7bff
    ;スタックの開始位置
    sti
    call no_displey_corsor
    call load_corsor
    call clean_screen
    call start_print
    call load_disk
    call load_sector
    ;jmp 0x0000:0x8000
    jmp SECOND_SECTOR_SEGMENT:SECOND_SECTOR_OFFSET

start_print:;ブートローダー実行時に実行
    mov si, start_msg
    call print
    ret

start_print_vga:
    ;mov ax, VGA
    mov ax, 0xb800
    mov es, ax
    mov si, start_msg
    call print_vga

error_print:;指定の位置にファイルがなかった場合に実行
    mov si, error_msg
    mov byte [color], 0x0c
    call print
    jmp $

error_print_vga:
    ;mov ax, VGA
    mov ax, 0xb800
    mov es, ax
    mov si, error_msg
    call print_vga
    jmp $

load_disk:
    mov ax, LBA
    cmp ax, 1
    je load_lba
    jmp load_second

load_lba:
    push ax

    mov ax, LBA_SIZE
    mov [sector_size], ax

    mov ax, LBA_SECTOR_OFFSET
    mov [sector_offset], ax

    mov ax, LBA_SECTOR_SEGMENT
    mov [sector_segment], ax

    mov ax, LBA_START_SECTOR
    mov [sector_num], ax

    pop ax
    call DAPset
    call load_sector
    jmp load_second

load_second:
    push ax

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
    int 0x13
    
    jc error_print

    ret
    ;jmp 0x0000:0xFFFFF

times 510-($-$$) db 0
dw 0xaa55