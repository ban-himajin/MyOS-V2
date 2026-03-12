[bits 16]
[org 0x7c00]

;----------定数作成スペース---------
;BOOTの設定
;VBRの次がブートローダーとは限らないから定数必要ないかもしれない
%define BOOT_SIZE 25
%define BOOT_SECTOR_OFFSET 0x8000
%define BOOT_SECTOR_SEGMENT 0x0000
%define BOOT_START_SECTOR 1

;----------------------------------
section .text
jmp start

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

align 16
DAP:
    db 0x10;DAPの全体バイト数 0x10 = 16
    db 0;予約
    dw 0;読み込むセクタ数
    dw 0;オフセット
    dw 0;セグメント
    dq 0;読み込みセクタ開始場所(セクタ0からの計算ではなく現在位置からの移動数)

;----------data_section--------------
DAPset:
    push ax

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

    pop ax
    ret

start:
    cli
    mov byte[Boot_Drive], dl
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x07a00
    sti

    call set_boot_LBA
    call load_disk
    mov ah, 0x0E    ; BIOS テレタイプ出力
    mov al, 'A'     ; 表示したい文字
    mov bh, 0x00    ; ページ番号（通常 0）
    mov bl, 0x07    ; 文字色（白・黒背景、テキストモード時）
    int 0x10
    ;cli
    mov dl, byte[Boot_Drive]
    jmp BOOT_SECTOR_SEGMENT:BOOT_SECTOR_OFFSET
    ;jmp 0x0000:BOOT_SECTOR_OFFSET
    ;jmp BOOT_SECTOR_OFFSET:0

.hang:
    mov ah, 0x0E    ; BIOS テレタイプ出力
    mov al, 'C'     ; 表示したい文字
    mov bh, 0x00    ; ページ番号（通常 0）
    mov bl, 0x07    ; 文字色（白・黒背景、テキストモード時)
    int 0x10
    hlt
    jmp .hang


set_boot_LBA:    
    mov ax, BOOT_SIZE
    mov [sector_size], ax

    mov ax, BOOT_SECTOR_OFFSET
    mov [sector_offset], ax

    mov ax, BOOT_SECTOR_SEGMENT
    mov [sector_segment], ax

    mov ax, BOOT_START_SECTOR
    mov [sector_num], ax

    call DAPset
    ret
    
load_disk:
    
    mov si, DAP
    mov ah, 0x42
    mov dl, [Boot_Drive]
    int 0x13
    
    jc .load_error
    
    ret
.load_error:
    mov ah, 0x0E    ; BIOS テレタイプ出力
    mov al, 'D'     ; 表示したい文字
    mov bh, 0x00    ; ページ番号（通常 0）
    mov bl, 0x07    ; 文字色（白・黒背景、テキストモード時）
    int 0x10
    hlt
    jmp .load_error

times 510-($-$$) db 0
dw 0xaa55