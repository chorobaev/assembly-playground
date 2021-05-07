section .data
	SYS_EXIT equ 1
	SYS_READ equ 3
	SYS_WRITE equ 4
	STDIN equ 0
	STDOUT equ 1
	
	%define nl 0xA, 0xD
	
	msgEnterWeight db 'Enter your weight in kg: '
	lenEnterWeight equ $ - msgEnterWeight
	
	msgEnterHeight db 'Enter yout height in cm: '
	lenEnterHeight equ $ - msgEnterHeight
	
	msgResult db 'Your BMI is '
	lenResult equ $ - msgResult
	
	const10 dd 10
	
section .bss
	weight resb 4
	height resb 4
	bmi resb 4
	char resb 1

section .text
    global _start
    
string_to_int:
	xor eax, eax			 ; zero a "result so far"
.top:
	movzx ecx, byte [edx]    ; get a character
	inc edx 				 ; ready for next one
	cmp ecx, '0' 		     ; valid?
	jb .done
	cmp ecx, '9'
	ja .done
	sub ecx, '0' 			 ; "convert" character to number
	imul eax, 10 			 ; multiply "result so far" by ten
	add eax, ecx 			 ; add in current digit
	jmp .top 				 ; until done
.done:
    ret
    
print_number:
    push eax
    push edx
    xor edx,edx          ;edx:eax = number
    div dword [const10]  ;eax = quotient, edx = remainder
    test eax, eax         ;Is quotient zero?
    je .l1               ; yes, don't display it
    call print_number     ;Display the quotient
.l1:
    mov eax, edx
    call print_char  ;Display the remainder
    pop edx
    pop eax
    ret
    
print_char:
	mov [char], eax
    mov edx, 1
    mov ecx, char
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    ret

_start:
	; Ask weight
    mov edx, lenEnterWeight
    mov ecx, msgEnterWeight
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    
    ; Get weight
    mov edx, 4
    mov ecx, weight
    mov ebx, STDIN
    mov eax, SYS_READ
    int 0x80
    
    ; Ask height
    mov edx, lenEnterHeight
    mov ecx, msgEnterHeight
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    
    ; Get height
    mov edx, 4
    mov ecx, height
    mov ebx, STDIN
    mov eax, SYS_READ
    int 0x80
    
    ; Convert weight to int
    mov edx, weight
    call string_to_int
    mov [weight], eax
    
    ; Convert height to int
    mov edx, height
    call string_to_int
    mov [height], eax
    
    ; Raise weight ot power square
    mov eax, weight
    mov ecx, weight
    mul ecx
    mov [weight], eax
    
    ; Divide height to the squire of weight
    xor eax, eax
    mov eax, height
    mov ecx, weight
    div ecx
    mov [bmi], eax
    
    ; Print result title
    mov edx, lenResult
    mov ecx, msgResult
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    
    ; Print result
    mov eax, bmi
    call print_number
    
    ; Exit code
    mov eax, SYS_EXIT
    int 0x80
    

