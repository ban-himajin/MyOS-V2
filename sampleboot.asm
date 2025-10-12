[org 0x7c00]
[bits 16]



start:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    mov si, msg
    mov ax, 0xb8000
    mov es, ax
    jmp print_loop

msg:
    db "hello world",0

print_loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0f
    mov [es:0], ax
    add di, 2
    jmp print_loop

.done:
    jmp $

times 510 - ($-$$) db 0
dw 0xAA55