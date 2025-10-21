[BITS 16]
[org 0x7c00]

;----------定数作成スペース---------
%define SECONDSIZE 72

%define VGA 0xb8000


;----------------------------------


jmp start
;seciton .data

start_msg:
    db "BanHimaBootLoader Ver:a 0.0.1", 10, 0

error_msg:
    db "|SecondBoot no found|", 0

back_color_32bit:
    db 0x00

color:
    db 0x07

corsor_Y:
    db 0x00

corsor_X:
    db 0x00

;section .bss

;section .text


no_displey_corsor:
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

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7bff
    ;スタックの開始位置
    sti
    call no_displey_corsor
    call clean_screen
    call start_print
    jmp load_second

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

load_second:
    mov bx, 0x8000
    xor ax, ax
    mov es, ax

    ;ファイルの読み込み
    mov ah, 0x02
    mov al, SECONDSIZE
    mov ch, 0
    mov cl, 2
    ;ロード先のセクタ番号
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc error_print

    jmp 0x0000:0x8000
    ;jmp 0x0000:0xFFFFF

times 510-($-$$) db 0
dw 0xaa55