;----------定数作成スペース---------
%define KERNEL_LOAD_SEGMENT 0x1000
;セグメント
%define KERNEL_LOAD_OFFSET 0x0000
;オフセット
;LoadPlace1 * 16 + LoadPlace2が配置場所

%define KERNEL_SIZE 1

%define KERNEL_COPY_PLACE 0x100000
;カーネルのコピー先指定

;%define VGA 0xb8000

;----------------------------------
section .data;bit共有データセクション

VGA:
    dd 0xb8000

corsor_Y:
    dw 0x00

corsor_X:
    dw 0x00

back_color:
    db 0x00

text_color:
    db 0x07

color:
    db 0x07

color_red:
    db 0x0c


[BITS 16]
[org 0x8000]

section .data;16bit専用データセクション

Second_Start_msg:
    db "Start Second Boot",10 ,0

load_error:
    db "|Kernel no found|",10 0

result_load_msg:
    db "kernel found", 10, 0

;32bitGDTの設定
gdt32_start:
    dq 0x0000000000000000
    dq 0x00cf9a000000ffff
    dq 0x00cf92000000ffff
gdt32_end:

gdt32_descriptor:
    dw gdt32_end - gdt32_start - 1
    dd gdt32_start

;section .bss

section .text

jmp start

print:;printの初めの部分
    lodsb
    cmp al, 0
    je .done_print
    cmp al, 10
    je .line_break_16bit
.print_next:
    mov ah, 0x0e
    mov bh, 0x00
    ;ページ番号
    mov bl, [color]
    ;文字の色
    int 0x10
    jmp print
.line_break_16bit:
    call load_corsor_16bit
    jmp .print_next
.done_print:
    mov byte [color], 0x07
    call load_corsor_16bit
    ret


load_corsor_16bit:
    mov ah, 0x03
    mov bh, 0x00
    int 0x10
    mov byte [corsor_Y], dh
    mov byte [corsor_X], dl
    je .load_corsor_16bit_line_break
    ret
.load_corsor_16bit_line_break:
    mov ah, 0x2
    mov dh, 0x00
    add dh, 1
    mov dl, 0
    mov byte [corsor_Y], dh
    mov byte [corsor_X], dl
    int 0x10
    ret

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000
    ;スタックの開始位置
    sti

    call load_corsor_16bit
    call second_start_print
    call enable_a20_fast
    ;jmp $
    jmp load_kernel
    jmp setup_protect_mode

second_start_print:
    mov si, Second_Start_msg
    call print
    ret

enable_a20_fast:
    in  al, 0x92
    or  al, 0x02
    out 0x92,al
    ret

load_kernel:
    mov ax, KERNEL_LOAD_SEGMENT
    mov es, ax
    mov bx, KERNEL_LOAD_OFFSET
    ;配置場所指定
    mov ah, 0x02
    ;読み取り開始セクタ数
    mov al, KERNEL_SIZE
    ;カーネルのサイズ数
    mov ch, 0
    mov dl, 0x80
    int 0x13
    ;jc load_kernel_error
    jmp result_load_print

load_kernel_error:
    mov si, load_error
    mov dh, [color_red]
    mov byte[color], dh
    call print
    jmp $

result_load_print:
    mov si, result_load_msg
    call print
    jmp setup_protect_mode

setup_protect_mode:
    call load_corsor_16bit
    cli
    lgdt [gdt32_descriptor]

    mov eax, cr0
    or eax, 0x01
    ;jmp $;テスト用
    mov cr0, eax
    jmp 0x08:start_32bit

[BITS 32]
section .data;32bit専用データセクション

start_msg_32bit:
    db "Start 32bit Mode!",0


;seciton .bss

section .text

setup_32bit:;32bitスタート時に初期化するものを入れる関数
    mov al, [back_color]
    shl al, 4
    mov bl, [text_color]
    or al, bl
    mov byte [color], al
    
    mov eax, [corsor_Y]
    inc eax
    imul eax, 80
    add eax, [corsor_X]
    imul eax, 2
    add eax, 0xb8000
    mov dword[VGA], eax
    ret

load_corsor_32bit:
    cmp al, 10
    pusha
    mov dx, 0x3d4
    mov al, 0x0f
    out dx, al
    inc dx
    in al, dx
    mov dl ,al

    dec dx
    mov al, 0x0e
    out dx, al
    inc dx
    in al, dx
    mov bh, al
    
    ;カーソルの上位バイトと下位バイトをx,yに分解
    mov ax, bx
    mov cx, 80
    xor dx, dx
    div cx
    je .load_corsor_false
    jmp .load_corsor_end
.load_corsor_false:
    inc ax
    mov dx, 0
.load_corsor_end:
    mov word[corsor_Y], ax
    mov word[corsor_X], dx
    pop ax
    ret

clean_screen:;画面をすべて消す関数1
    mov edi, VGA
    mov ecx, 80 * 25
    mov ax, [back_color]
    jmp .loop
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    ret

print_32bit:;文字を出力する関数
    lodsb
    cmp al, 0
    je .done
    cmp al, 10
    je .line_break_32bit
.print_32bit_next:
    inc byte[corsor_X]
    mov ah, [color]
    mov [edi], ax
    add edi, 2
    jmp print_32bit
.done:
    mov byte [color], 0x07
    call load_corsor_32bit
    ret
.line_break_32bit:
    call load_corsor_32bit
    jmp .print_32bit_next

start_print_32bit:
    mov esi, start_msg_32bit
    mov ah, [color_red]
    mov byte[color], ah
    mov edi, [VGA]
    call print_32bit
    ret

start_32bit:
    call setup_32bit
    ;call clean_screen
    mov al, 'A'        ; 表示する文字
    mov ah, 0x1F       ; 属性（白文字・青背景）

    ; AX = 文字＋属性（2バイト）
    mov eax, 0xB8000   ; VGAテキストモードの開始アドレス
    mov [eax], ax      ; 画面左上に表示

    call start_print_32bit
    
    cli


    jmp $