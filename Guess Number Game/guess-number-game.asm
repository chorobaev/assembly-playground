default rel
extern printf, exit
%define nl 0xA, 0xD

section .data
    msg_welcome db "Welcome to Guess Number!", nl, \
              "It is a geme with simple rules.", nl, \
              "There is a hidden number between 1 and 255.", nl, \
              "Your aim is to guess it within a minimal try.", nl, \
              "How do you think? What is the number?...", nl
    len_welcome equ $ - msg_welcome

    msg_less db "LESS than your number!", nl
    len_less equ $ - msg_less

    msg_greater db "GREATER than than your number!", nl
    len_greater equ $ - msg_greater
    
    msg_invalid_input db "Please enter a number in range 1..255!", nl
    len_invalid_input equ $ - msg_invalid_input
 
    format db "%d", 10, 0

    msg_win db "Oh my God! You guessed the number!", nl, \
              "You found it in %d attemts.", nl 
     
    try_count db 0        


section .bss
    num resb 4
    hidden resb 4


section	.text
	global main
main: 
    call print_welcome_msg
    call set_random
     
    ;mov eax, [hidden]
    ;call print_int
    
    call start_game
    ret

start_game:
    .while:
    call read_num
    mov edx, num
    call atoi
    
    cmp eax, [hidden]
    je .win

    cmp eax, 1
    jb .invalid

    cmp eax, 255
    ja .invalid

    cmp eax, [hidden]
    jb .greater

    cmp eax, [hidden]
    ja .less

    .invalid:
    call print_invalid_input
    jmp .while

    .greater:
    call print_greater
    call increment_try
    jmp .while
    
    .less:
    call print_less
    call increment_try
    jmp .while

    .win:
    call increment_try
    call print_win

    ret

set_random:
    rdtsc
    mov ebx, 255
    call modulo
    add eax, 1
    mov [hidden], eax
    ret

modulo:
    mov edx, 0
    div ebx 
    mov eax, edx
    ret

read_num:
    mov eax, 3
    mov ebx, 2
    mov ecx, num
    mov edx, 4
    int 0x80
    ret

increment_try:
    inc byte [try_count]
    ret

print_welcome_msg:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_welcome
    mov edx, len_welcome
    int 0x80 
    ret

print_less:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_less
    mov edx, len_less
    int 0x80
    ret

print_greater:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_greater
    mov edx, len_greater
    int 0x80
    ret

print_win:
    sub rsp, 8
    mov esi, [try_count]
    lea rdi, [rel msg_win]
    xor eax, eax
    call printf
    xor eax, eax
    add rsp, 8
    ret

print_invalid_input:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_invalid_input
    mov edx, len_invalid_input
    int 0x80
    ret

print_int:
    sub rsp, 8
    mov  esi, eax
    lea  rdi, [rel format]
    xor  eax, eax           
    call printf
    xor  eax, eax
    add rsp, 8
    ret

print_num:
    mov eax, 4
    mov ebx, 1
    mov ecx, num
    mov edx, 3
    int 0x80
    ret

atoi:
    xor eax, eax 
    .top:
    movzx ecx, byte [edx] 
    inc edx ; 
    cmp ecx, '0'
    jb .done
    cmp ecx, '9'
    ja .done
    sub ecx, '0' 
    imul eax, 10 
    add eax, ecx
    jmp .top
    .done:
    ret

