;----------定数作成スペース---------
%define KERNEL_LOAD_SEGMENT 0x1000
;セグメント
%define KERNEL_LOAD_OFFSET 0x0000
;オフセット
;LoadPlace1 * 16 + LoadPlace2が配置場所

;%define SECONDBOOTSIZE

%define KERNEL_SIZE 1

%define KERNEL_COPY_PLACE 0x100000
;カーネルのコピー先指定

;%define VGA 0xb8000

;----------------------------------
section .data;bit共有データセクション

VGA:
    dq 0xb8000

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
;[org 0x100000]

section .data;16bit専用データセクション

Second_Start_msg:
    db "Start Second Boot", 10, 0

result_load_msg:
    db "kernel found", 10, 0

load_error:
    db "|Kernel no found|", 10, 0

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

print:;print関数
    lodsb
    cmp al, 0
    je .done_print
    cmp al, 10
    je .line_break_16bit
    jne .print_next
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

load_corsor_16bit:;カーソル位置を得る関数
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

start:;初めの部分
    cli
    xor ax, ax
    ;xor ax, 0x1000
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x9000
    ;mov sp, 0xFFF0
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

enable_a20_fast:;A20を有効にする関数
    in  al, 0x92
    or  al, 0x02
    out 0x92,al
    ret

load_kernel:;次に使うファイルをロードする
    mov ax, KERNEL_LOAD_SEGMENT
    mov es, ax
    mov bx, KERNEL_LOAD_OFFSET
    ;配置場所指定
    mov ah, 0x02
    ;読み取り開始セクタ数
    mov al, KERNEL_SIZE
    ;カーネルのサイズ数
    mov ch, 0
    mov cl, 2
    mov dl, 0x80
    int 0x13
    ;jc load_kernel_error
    jmp result_load_print

load_kernel_error:;ロード失敗
    mov si, load_error
    mov dh, [color_red]
    mov byte[color], dh
    call print
    jmp $

result_load_print:;ロード成功
    mov si, result_load_msg
    call print
    jmp setup_protect_mode

setup_protect_mode:;プロテクトモードへ移行
    call load_corsor_16bit
    cli
    ;jmp $
    lgdt [gdt32bit_descriptor]

    mov eax, cr0
    or eax, 0x01
    ;jmp $;テスト用
    mov cr0, eax
    ;sti
    ;jmp $
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
    db "Start 32bit Mode!", 10, 0

;GDTの作成
gdt64bit_start:
    dq 0x0000000000000000
    ;dw 0x0000
    ;dw 0x0000
    ;dd 0x00
    ;dd 0x00
    ;dd 0x00
    ;dd 0x00

    dq 0x00209A0000000000
    ;dw 0xffff
    ;dw 0x0000
    ;dw 0x0000
    ;dd 0x00
    ;dd 0x9a
    ;dd 0x20
    ;dd 0x00

    dq 0x0000920000000000
    ;dd 0xffff
    ;dd 0x0000
    ;dd 0x0000
    ;dd 0x00
    ;dd 0x92
    ;dd 0x00
    ;dd 0x00

gdt64bit_end:

gdt64bit_descriptor:
    dw gdt64bit_end - gdt64bit_start - 1
    dd gdt64bit_start

;IDTの作成
idt:
    ;times 256 * 6 db 0
    times 256 * 8 db 0
idt_ptr:
    dw 256 * 8 - 1
    dd idt

;ページングテーブルの定義
%define PAGE_FLAGS 0x003  ; Present + Read/Write

align 4096
pml4_table_64bit:
    dq pdpt_table_64bit + PAGE_FLAGS         ; PML4[0] → 下位仮想領域（identity map）
    dq pdpt_table_higher_half + PAGE_FLAGS   ; PML4[511] → 高位仮想領域（カーネル用）
    times 510 dq 0

align 4096
pdpt_table_64bit:
    dq pd_table_64bit + PAGE_FLAGS
    times 511 dq 0

align 4096
pdpt_table_higher_half:
    dq pd_table_higher_half + PAGE_FLAGS
    times 511 dq 0

align 4096
pd_table_64bit:
    dq pt_table_64bit + PAGE_FLAGS
    times 511 dq 0

align 4096
pd_table_higher_half:
    dq pt_table_higher_half + PAGE_FLAGS
    times 511 dq 0

align 4096
pt_table_64bit:
    %assign i 0
    %rep 512
        dq (i << 12) | PAGE_FLAGS  ; Identity map: 0x00000000〜0x0007FFFF
    %assign i i+1
    %endrep

align 4096
pt_table_higher_half:
    %assign i 0
    %rep 512
        dq (i << 12) | PAGE_FLAGS  ; 高位仮想アドレスに物理0x00000000〜をマップ
    %assign i i+1
    %endrep

;seciton .bss

section .text
start_setup_32bit:;32bitに入ったら初期化するものを入れるまた初期化に使う関数でも可
    ;現在カーソル位置からどれだけずらした位置を初期位置にするか
    mov ax, [corsor_Y]
    add ax, 1
    mov word[corsor_Y], ax
    mov word[corsor_X], 0

    call setup_corsor_32bit
    ;call load_corsor_32bit
    ;all load_corsor_32bit
    ret

setup_color_32bit:;背景とテキストカラーをVGAで扱える形に直す関数
    mov al, [back_color]
    shl al, 4
    mov bl, [text_color]
    or al, bl
    mov byte [color], al
    ret

setup_corsor_32bit:;VGAの初期位置を決める
    ;0xb8000 + ((Y * 80) + X) * 2 で計算
    mov eax, [corsor_Y]
    inc eax
    imul eax, 80
    add eax, [corsor_X]
    imul eax, 2
    add eax, 0xb8000
    mov dword[VGA], eax
    ret

load_corsor_32bit:;カーソルの位置を更新
    cmp al, 10
    pusha
    mov eax, [corsor_Y]
    mov ebx, [corsor_X]
    je .load_corsor_false_32bit
    jmp .load_corsor_end_32bit
.load_corsor_false_32bit:
    ;jmp $
    inc eax
    mov ebx, 0
.load_corsor_end_32bit:
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

clean_screen_32bit:;画面をすべて消す関数
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
    je .done_32bit
    cmp al, 10
    je .line_break_32bit
.print_32bit_next:
    inc byte[corsor_X]
    mov ah, [color]
    mov [edi], ax
    add edi, 2
    jmp .print_loop_32bit
.done_32bit:
    mov byte [color], 0x07
    call load_corsor_32bit
    ret
.line_break_32bit:
    call load_corsor_32bit
    ;jmp .print_32bit_next
    jmp .print_loop_32bit

start_print_32bit:;32bit開始メッセージを出す
    mov esi, start_msg_32bit
    mov al, 0x07
    mov byte[text_color], al
    call print_32bit
    ret

error_color:
    mov ax, [color_red]
    mov word[color], ax
    ret

start_32bit:;32bit開始位置
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
    sti
    call start_setup_32bit
    call start_print_32bit
    lgdt[gdt64bit_descriptor]
    ;jmp $
    call paging_32bit
    jmp 0x08:start_64bit

paging_32bit:
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov eax, pml4_table_64bit
    mov cr3, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

idt_setup_32bit:
    set_idt_entry_32bit 0, isr0_32bit, 0x08
    set_idt_entry_32bit 1, db_32bit, 0x08
    set_idt_entry_32bit 2, nmi_32bit, 0x08
    set_idt_entry_32bit 3, db_32bit, 0x08
    set_idt_entry_32bit 4, of_32bit, 0x08
    set_idt_entry_32bit 5, br_32bit, 0x08
    set_idt_entry_32bit 6, ud_32bit, 0x08
    set_idt_entry_32bit 7, nm_32bit, 0x08
    set_idt_entry_32bit 8, df_32bit, 0x08
    set_idt_entry_32bit 9, r9_32bit, 0x08
    set_idt_entry_32bit 10, ts_32bit, 0x08
    set_idt_entry_32bit 11, np_32bit, 0x08
    set_idt_entry_32bit 12, ss_32bit, 0x08
    set_idt_entry_32bit 13, gp_32bit, 0x08
    set_idt_entry_32bit 14, pf_32bit, 0x08
    set_idt_entry_32bit 15, r15_32bit, 0x08
    set_idt_entry_32bit 16, mf_32bit, 0x08
    set_idt_entry_32bit 17, ac_32bit, 0x08
    set_idt_entry_32bit 18, mc_32bit, 0x08
    set_idt_entry_32bit 19, xf_32bit, 0x08
    set_idt_entry_32bit 20, ve_32bit, 0x08
    set_idt_entry_32bit 21, r21_29_32bit, 0x08
    set_idt_entry_32bit 30, sx_32bit, 0x08
    set_idt_entry_32bit 31, r31_32bit, 0x08
    lidt [idt_ptr]
    ret

;ここから下が例外ハンドラの処理をする関数
isr0_msg_32bit:;0
    db "de Ecode=0",32 ,0
isr0_32bit:
    cli
    pushad
    call error_color
    mov esi, isr0_msg_32bit
    call print_32bit
    popad
    hlt
    ;iret

db_msg_32bit:;1
    db "db Ecode=1",32 ,0
db_32bit:
    cli
    pushad
    call error_color
    mov si,db_msg_32bit
    popad
    hlt
    ;iret

nmi_msg_32bit:;2
    db "nmi Ecode=2",32 ,0
nmi_32bit:
    cli
    pushad
    call error_color
    mov si,nmi_msg_32bit
    popad
    hlt
    ;iret

bp_msg_32bit:;3
    db "bp Ecode=3",32 ,0
bp_32bit:
    cli
    pushad
    call error_color
    mov si,bp_msg_32bit
    popad
    hlt
    ;iret

of_msg_32bit:;4
    db "of Ecode=4",32 ,0
of_32bit:
    cli
    pushad
    call error_color
    mov si,of_msg_32bit
    popad
    hlt
    ;iret

br_msg_32bit:;5
    db "br Ecode=5",32 ,0
br_32bit:
    cli
    pushad
    call error_color
    mov si,br_msg_32bit
    popad
    hlt
    ;iret

ud_msg_32bit:;6
    db "ud Ecode=6",32 ,0
ud_32bit:
    cli
    pushad
    call error_color
    mov esi, ud_msg_32bit
    popad
    hlt
    ;iret

nm_msg_32bit:;7
    db "nm Ecode=7",32 ,0
nm_32bit:
    cli
    pushad
    call error_color
    mov si,nm_msg_32bit
    popad
    hlt
    ;iret

df_msg_32bit:;8
    db "df Ecode=8",32 ,0
df_32bit:
    cli
    pushad
    call error_color
    mov si,df_msg_32bit
    popad
    hlt
    ;iret

r9_msg_32bit:;9
    db "r9(-) Ecode=9",32 ,0
r9_32bit:
    cli
    pushad
    call error_color
    mov si,r9_msg_32bit
    popad
    hlt
    ;iret

ts_msg_32bit:;10
    db "ts Ecode=10",32 ,0
ts_32bit:
    cli
    pushad
    call error_color
    mov si,ts_msg_32bit
    popad
    hlt
    ;iret

np_msg_32bit:;11
    db "np Ecode=11",32 ,0
np_32bit:
    cli
    pushad
    call error_color
    mov si,np_msg_32bit
    popad
    hlt
    ;iret

ss_msg_32bit:;12
    db "ss Ecode=12",32 ,0
ss_32bit:
    cli
    pushad
    call error_color
    mov si,ss_msg_32bit
    popad
    hlt
    ;iret

gp_msg_32bit:;13
    db "gp Ecode=13",32 ,0
gp_32bit:
    cli
    pushad
    call error_color
    mov si,gp_msg_32bit
    popad
    hlt
    ;iret

pf_msg_32bit:;14
    db "pf Ecode=14",32 ,0
pf_32bit:;
    cli
    pushad
    call error_color
    mov esi, pf_msg_32bit
    popad
    hlt
    ;iret

r15_msg_32bit:;15
    db "r15(-) Ecode=15",32 ,0
r15_32bit:
    cli
    pushad
    call error_color
    mov si,r15_msg_32bit
    popad
    hlt
    ;iret

mf_msg_32bit:;16
    db "mf Ecode=16",32 ,0
mf_32bit:
    cli
    pushad
    call error_color
    mov si,mf_msg_32bit
    popad
    hlt
    ;iret

ac_msg_32bit:;17
    db "ac Ecode=17",32 ,0
ac_32bit:
    cli
    pushad
    call error_color
    mov si,ac_msg_32bit
    popad
    hlt
    ;iret

mc_msg_32bit:;18
    db "mc Ecode=18",32 ,0
mc_32bit:
    cli
    pushad
    call error_color
    mov si,mc_msg_32bit
    popad
    hlt
    ;iret

xf_msg_32bit:;19
    db "xf Ecode=19",32 ,0
xf_32bit:
    cli
    pushad
    call error_color
    mov si,xf_msg_32bit
    popad
    hlt
    ;iret

ve_msg_32bit:;20
    db "ve Ecode=20",32 ,0
ve_32bit:
    cli
    pushad
    call error_color
    mov si,ve_msg_32bit
    popad
    hlt
    ;iret

r21_29_msg_32bit:;21-29
    db "r21-29(-)br Ecode=21-29",32 ,0
r21_29_32bit:
    cli
    pushad
    call error_color
    mov si,r21_29_msg_32bit
    popad
    hlt
    ;iret

sx_msg_32bit:;30
    db "sx Ecode=30",32 ,0
sx_32bit:
    cli
    pushad
    call error_color
    mov si,sx_msg_32bit
    popad
    hlt
    ;iret

r31_msg_32bit:;31
    db "r31(-) Ecode=31",32 ,0
r31_32bit:
    cli
    pushad
    call error_color
    mov si,r31_msg_32bit
    popad
    hlt
    ;iret
;---------------------------------

[bits 64]
;section .data

start_msg_64bit:
    db "Start 64bit Mode!", 10, 0
    ;db "SSSSSSSSSS", 10, 0

;section .dss

section .text

start_setup_64bit:;64bit初期化関数
    mov rax, [corsor_Y]
    add rax, 1
    mov qword[corsor_Y], rax
    mov qword[corsor_X], 0

    call setup_corsor_64bit
    ;call load_corsor_64bit
    ret

setup_color_64bit:;VGAで扱える色形式に変換する関数
    mov al, [back_color]
    shl al, 4
    mov bl, [text_color]
    or al, bl
    mov byte[color], al
    ret

setup_corsor_64bit:;カーソルの初期値を決める関数
    mov rax, [corsor_Y]
    inc rax
    imul rax, 80
    add rax, [corsor_X]
    imul rax, 2
    add rax, 0xb8000
    mov qword[VGA], rax
    ret

load_corsor_64bit:;カーソルを更新する関数
    ;0xb8000+((y*80)+x)*2をもとに計算
    cmp al, 10
    push rax
    push rbx
    mov eax, [corsor_Y]
    mov ebx, [corsor_X]
    je .load_corsor_false_64bit
    jmp .load_corsor_end_64bit
.load_corsor_false_64bit:
    inc eax
    mov ebx, 0
.load_corsor_end_64bit:
    mov dword[corsor_Y], eax
    mov dword[corsor_X], ebx
    imul eax, 80
    add eax, ebx
    imul eax, eax, 2
    add eax, 0xb8000
    mov dword[VGA], eax
    pop rax
    pop rbx
    mov edi, [VGA]
    ret

clean_screen_64bit:;画面内の文字をすべて消す関数
    mov edi, 0xb8000
    mov ecx, 80 * 25
    mov ax, [back_color]
    jmp .loop
.loop:
    mov [rdi], ax
    add edi, 2
    loop .loop
    mov byte[corsor_Y], 0
    mov byte[corsor_X], 0
    call load_corsor_64bit
    ret

print_64bit:;print関数
    mov rdi, [VGA]
    call setup_color_64bit

    ;jmp .print_loop_64bit
.print_loop_64bit:
    lodsb
    cmp al, 0
    je .done_64bit
    cmp al, 10
    je .line_break_64bit
.print_64bit_next:
    inc byte[corsor_X]
    mov ah, [color]
    stosw
    jmp .print_loop_64bit
.done_64bit:
    mov dword[color], 0x07
    call load_corsor_64bit
    ret
.line_break_64bit:
    call load_corsor_64bit
    jmp .print_loop_64bit

start_print_64bit:
    mov rsi, start_msg_64bit
    mov al, 0x07
    mov byte[text_color], al
    call print_64bit
    ret

start_64bit:;64bit開始場所
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x90000
    ;jmp $
    ;call clean_screen_64bit
    ;cli
    call start_setup_64bit
    call start_print_64bit
    ;jmp $
    ;sti
    jmp $
