[BITS 16]
[org 0x7c00]

;section .text

;----------定数作成スペース---------
%define FARST_SECTOR_OFFSET 0x8000
;%define FARST_SECTOR_OFFSET 0x7e00
%define FARST_SECTOR_SEGMENT 0x0000

;----------------------------------

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

DAP:
    db 0x10;DAPの全体バイト数
    db 0
    dw 0;読み込むセクタ数
    dw 0;オフセット
    dw 0;セグメント
    dq 0;読み込みセクタ開始場所(セクタ0からの計算ではなく現在位置からの移動数)

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
    mov sp, 0x7bcc
    sti

    call scan_partition
    ;call load_farst_partition
    mov dl, [Boot_Drive]
    jmp FARST_SECTOR_SEGMENT:FARST_SECTOR_OFFSET

scan_partition:
    mov si, partition_table
    mov cx, 4
.next_entry:
    mov al, [si]
    cmp al, 0x80
    je .found
    add si, 16
    loop .next_entry
    ret
.found:
    push eax
    
    mov bx, si

    ;mov eax, [bx + 12]
    mov eax, 1
    mov dword[sector_size], eax

    mov ax, FARST_SECTOR_OFFSET
    mov [sector_offset], ax

    mov ax, FARST_SECTOR_SEGMENT
    mov [sector_segment], ax

    mov eax, [bx + 8]
    mov dword[sector_num], eax

    call DAPset
    call load_partition_vbr
    pop eax
    ret

load_partition_vbr:
    mov si, DAP
    mov ah, 0x42
    mov dl, [Boot_Drive]

    mov bx, [DAP + 4]
    mov ax, [DAP + 6]
    mov es, ax

    int 0x13

    jc error_print

    ret

error_print:
    jmp $

times 446-($-$$) db 0
; パーティションテーブルを後方に置く場合の例
; パーティション1: ブート不可, Linux (0x83), LBA開始: 2048, セクター数: 4096
partition_table:
    db 0x80               ; ブートフラグ 0x00非アクティブ 0x80アクティブ
    db 0x00,0x02,0x00     ; CHS開始位置（例）
    db 0xaa               ; パーティションタイプ
    db 0xFF,0xFF,0xFF     ; CHS終了位置（例）
    dd 2048               ; LBA数値 * 512が開始位置 LBA開始セクター (リトルエンディアン)
    ;dd 8               ; LBA数値 * 512が開始位置 LBA開始位置 (リトルエンディアン)
    dd 4096               ; ブロック数 * 512が全体サイズになる パーティションサイズ (リトルエンディアン)
times 510-($-$$) db 0
dw 0xaa55