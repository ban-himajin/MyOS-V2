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
    dd 0x00

corsor_X:
    dd 0x00

back_color:
    db 0x00

text_color:
    db 0x07

color:
    db 0x07

color_red:
    db 0x0c

color_blue:
    db 0x01


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
    cmp al, 10
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
    lgdt [gdt32bit_descriptor]

    mov eax, cr0
    or eax, 0x01
    ;jmp $;テスト用
    mov cr0, eax
    align 1024
    jmp $
    jmp 0x08:start_32bit

[BITS 32]
;-----------32bitマクロ定義セクション-------------
%macro set_idt_entry_32bit 3
    ;%1:割り込み番号
    ;%2:ハンドラアドレス
    ;%3:セグメントセレクタ

    mov word [idt + %1 * 8 + 0], (%2-$$) & 0xffff   ;offset_low
    ;mov word [idt + %1 * 8 + 0], %2-$$ & 0xffff    ;offset_low
    mov word [idt + %1 * 8 + 2], %3                 ;selector
    mov byte [idt + %1 * 8 + 4], 0                  ;zero
    mov byte [idt + %1 * 8 + 5], 0x8e               ;type_attr(割り込みゲート)
    mov word [idt + %1 * 8 + 6], (%2-$$) >> 16      ;offset_high
    ;mov word [idt + %1 * 8 + 6], %2 >> 16       ;offset_high
%endmacro

;------------------------------------------

section .data;32bit専用データセクション

start_msg_32bit:
    db 10, "Start 32bit Mode!",10 ,0

;GDTの作成
gdt64bit_start:
    dd 0x0000
    dd 0x0000
    dd 0x0000
    dd 0x0000

    dw 0x0000
    dw 0x0000
    dd 0x00
    dd 0x9a
    dd 0xa0
    dd 0x00

    dd 0xffff
    dd 0x0000
    dd 0x00
    dd 0x92
    dd 0xa0
    dd 0x00
gdt64bit_end:

gdt64bit_descriptor:
    dw gdt64bit_end - gdt64bit_start - 1
    dd gdt64bit_start

;IDTの作成
idt:
    times 256 * 6 db 0
idt_ptr:
    dw 256 * 8 - 1
    dd idt

;ページングテーブルの定義
%define PAGE_FLAGS 0x03
align 4096
pml4_table_32bit:
    dq pdpt_table_32bit + PAGE_FLAGS
    times 511 dq 0

align 4096
pdpt_table_32bit:
    dq pd_table_32bit + PAGE_FLAGS
    times 511 dq 0

align 4096
pd_table_32bit:
    dq pt_table_32bit + PAGE_FLAGS
    times 511 dq 0

align 4096
pt_table_32bit:
    dq 0x00000000 | PAGE_FLAGS
    times 511 dq 0
;seciton .bss

section .text
start_setup_32bit:;32bitに入ったら初期化するものを入れるまた初期化に使う関数でも可
    ;現在カーソル位置からどれだけずらした位置を初期位置にするか
    mov ax, [corsor_Y]
    add ax, 1
    mov word[corsor_Y], ax

    call setup_corsor_32bit
    ;call load_corsor_32bit
    call load_corsor_32bit
    ret
setup_color_32bit:;背景とテキストカラーをVGAで扱える形に直す関数
    mov al, [back_color]
    shl al, 4
    mov bl, [text_color]
    or al, bl
    mov byte [color], al
    ret

setup_corsor_32bit:;VGAの初期位置を決める
    mov eax, [corsor_Y]
    inc eax
    imul eax, 80
    add eax, [corsor_X]
    imul eax, 2
    add eax, 0xb8000
    mov dword[VGA], eax
    ret

load_corsor_32bit:;カーソルの位置を
    cmp al, 10
    pusha
    mov eax, [corsor_Y]
    mov ebx, [corsor_X]
    je .load_corsor_false
    jmp .load_corsor_end
.load_corsor_false:
    ;jmp $
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

clean_screen:;画面をすべて消す関数1
    mov edi, 0xb8000    ;VGAメモリを直接入力
    mov ecx, 80 * 25
    mov ax, [back_color]
    jmp .loop
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    mov dword[corsor_X], 0
    mov dword[corsor_Y], 0
    call load_corsor_32bit
    ret

print_32bit:;文字を出力する関数
    mov edi, [VGA]
    call setup_color_32bit
    jmp .print_loop_32bit

.print_loop_32bit:
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
    jmp .print_loop_32bit
.done:
    mov byte [color], 0x07
    call load_corsor_32bit
    ret
.line_break_32bit:
    call load_corsor_32bit
    ;jmp .print_32bit_next
    jmp .print_loop_32bit


start_print_32bit:;32bit開始メッセージを出そす関数
    mov esi, start_msg_32bit
    mov al, 0x07
    mov byte[text_color], al
    call print_32bit
    ret

error_color:
    mov ax, [color_red]
    mov word[color], ax
    ret

start_32bit:
    cli
    call idt_setup_32bit
    mov ax, 0x10
    mov dx, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9fc00
    mov ebp, esp
    call start_setup_32bit
    ;call clean_screen
    call start_print_32bit
    call paging_32bit
    ;sti
    jmp $

paging_32bit:
    pusha
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov eax, pml4_table_32bit
    mov cr3, eax

    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    popa
    ret

idt_setup_32bit:
    set_idt_entry_32bit 0, isr0_32bit, 0x08
    set_idt_entry_32bit 3, bp_32bit, 0x08
    set_idt_entry_32bit 6, ud_32bit, 0x08
    set_idt_entry_32bit 8, df_32bit, 0x08
    set_idt_entry_32bit 13, gp_32bit, 0x08
    set_idt_entry_32bit 14, pf_32bit, 0x08
    lidt [idt_ptr]
    ret

;ここから下が例外ハンドラの処理をする関数
isr0_msg_32bit:
    db "de 0",32 ,0

isr0_32bit:
    cli
    pushad
    call error_color
    mov esi, isr0_msg_32bit
    call print_32bit
    popad
    hlt
    ;iret

ud_msg_32bit:
    db "ud 6",32 ,0

ud_32bit:
    cli
    pushad
    call error_color
    mov esi, ud_msg_32bit
    popad
    hlt
    ;iret

gp_msg_32bit:
    db "gp 13",32 ,0

gp_32bit:
    cli
    pushad
    call error_color
    mov si,gp_msg_32bit
    popad
    hlt
    ;iret

pf_msg_32bit:
    db "pf 14",32 ,0

pf_32bit:
    cli
    pushad
    call error_color
    mov esi, pf_msg_32bit
    popad
    hlt
    ;iret

df_msg_32bit:
    db "df 8",32 ,0

df_32bit:
    cli
    pushad
    call error_color
    mov esi, df_msg_32bit
    popad
    hlt
    ;iret

bp_msg_32bit:
    db "bp 3",32 ,0

bp_32bit:
    cli
    pushad
    call error_color
    mov esi, bp_msg_32bit
    popad
    hlt
    ;iret

;---------------------------------
