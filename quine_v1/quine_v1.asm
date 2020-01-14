BITS 32

segment .data

	nnul db  0, 127, 69, 76, 70, 1, 1, 1, 0, 2, 0, 3, 0, 1, 0, 192, 128, 4, 8, 52, 0, 72, 5, 0, 52, 0, 32, 0, 3, 0, 40, 0, 7, 0, 4, 0, 1, 0, 128, 4, 8, 0, 128, 4, 8, 113, 1, 0, 113, 1, 0, 5, 0, 16, 0, 1, 0, 116, 1, 0, 116, 145, 4, 8, 116, 145, 4, 8, 22, 2, 0, 22, 2, 0, 6, 0, 16, 0, 4, 0, 148, 0, 148, 128, 4, 8, 148, 128, 4, 8, 36, 0, 36, 0, 4, 0, 4, 0, 4, 0, 20, 0, 3, 0, 71, 78, 85, 0, 152, 218, 8, 106, 138, 244, 73, 72, 30, 33, 1, 132, 83, 229, 112, 171, 116, 179, 116, 39, 0, 49, 192, 49, 201, 189, 112, 145, 4, 8, 69, 188, 141, 146, 4, 8, 176, 5, 187, 193, 146, 4, 8, 177, 100, 128, 241, 1, 205, 128, 137, 195, 138, 69, 0, 60, 0, 116, 13, 137, 233, 49, 192, 176, 4, 178, 1, 205, 128, 69, 235, 236, 49, 192, 138, 4, 36, 1, 199, 131, 255, 0, 116, 27, 68, 184, 4, 0, 185, 112, 145, 4, 8, 186, 1, 0, 205, 128, 79, 131, 255, 0, 117, 233, 69, 235, 197, 184, 4, 0, 185, 112, 145, 4, 8, 186, 30, 1, 0, 205, 128, 184, 4, 0, 185, 141, 146, 4, 8, 186, 51, 0, 205, 128, 184, 4, 0, 185, 193, 146, 4, 8, 186, 6, 0, 205, 128, 235, 1, 144, 184, 94, 0, 185, 1, 0, 131, 241, 10, 131, 241, 100, 205, 128, 49, 192, 176, 6, 205, 128, 49, 192, 176, 1, 205, 128, 0, 0

	zer db 9, 1, 1, 3, 3, 6, 1, 1, 1, 1, 1, 1, 8, 1, 2, 2, 4, 2, 3, 2, 2, 2, 4, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 8,1, 1, 1, 3, 3, 1, 3, 2, 3, 3, 3, 3, 3, 3, 3,0

	file_name db "quine", 0

segment .text
	global _start

_start:                 ; initialisation of some registers
	xor eax, eax
    xor ebx, ebx
	xor ecx, ecx
    xor edx, edx
	mov ebp, nnul
	inc ebp
	mov esp, zer

opening:
	mov al, 5           ; syscall 32 bits for open
	mov ebx, file_name
	mov cl, 100         ; mod for create file
	xor cl, 1
	int 0x80
	mov ebx, eax

write_code:             ; write all characters one by one, jmp to another function for the 'decompression'
	mov al, [ebp]
	cmp al, 0
	je trans
	mov ecx, ebp
	xor eax, eax
	mov al, 4           ; syscall 32 bits for write
	mov dl, 1
	int 0x80
	inc ebp
	jmp write_code

trans:                  ; initialisation for the function zer0
	xor eax, eax
	mov al, [esp]
	add edi, eax
	cmp edi, 0
	je array
	inc esp

zer0:                   ; write the right number of 0 in the son of this programm
	mov eax, 4
	mov ecx, nnul
	mov edx, 1
	int 0x80
	dec edi
	cmp edi, 0
	jne zer0
	inc ebp
	jmp loop

array:                  ; write all the arrays which contain the data for the execution
	mov eax, 4
	mov ecx, nnul
	mov edx, 286
	int 0x80
	mov eax, 4
	mov ecx, zer
	mov edx, 51
	int 0x80
	mov eax, 4
	mov ecx, file_name
	mov edx, 6
	int 0x80
	jmp hello
	nop

end:
	mov eax, 0x5e       ; syscall 32 bits for fchmod
	mov ecx, 1
	xor ecx, 10
	xor ecx, 100        ; everybody can exec the programm
	int 0x80
	xor eax, eax
	mov al, 6           ; syscall 32 bits for close
	int 0x80
	xor eax, eax
	mov al,1            ; syscall 32 bits for exit
	int 0x80
