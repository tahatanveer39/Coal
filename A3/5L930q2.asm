[org 0x0100]

jmp start

title: db '25L-0930'
paragraph:  db 'Pak SarZameen Shaadbaad', 10
			db 'Laal Kabootar Laal Kabootar',10
			db 'Nasha akhion mein zyada hai sharab se', 10
			db 'Test text to check wrap and boundaries, Test text to check wrap and boundaries, Test text to check wrap and boundaries', 0
search: db 'Kabootar', 0
count: dw 0
msg1:  db 'Total Matches Found: [', 0
msg2:  db '] | Viewport Status: ACTIVE', 0

clrscr:
	push es
	push ax
	push cx
	push di
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, 0
	mov ax, 0x0720
	mov cx, 2000
	
	cld
	rep stosw
	
	pop di
	pop cx
	pop ax
	pop es
	ret
	
	
viewport:
	push es
	push ax
	push bx
	push cx
	push di
	cld
	
	mov ax, 0xb800
	mov es, ax
	
	;upper left to right
	mov bx, 0
	mov ax, 3
	mov bl, 80
	mul bl
	add ax, 8
	shl ax, 1
	mov di, ax
	mov ax, 0x07CD
	mov cx, 64
	rep stosw
	
	;lower left to right
	mov bx, 0
	mov ax, 21
	mov bl, 80
	mul bl
	add ax, 8
	shl ax, 1
	mov di, ax
	mov ax, 0x07CD
	mov cx, 64
	rep stosw
	
	;left boundary
	mov bx, 0
	mov ax, 4
    mov bl, 80
    mul bl
    add ax, 8
    shl ax, 1
    mov di, ax
    mov ax, 0x07BA
    mov cx, 17
	left:
		mov [es:di], ax
		add di, 160
		loop left
	
	;right boundary
	mov bx,0
	mov ax, 4
	mov bl, 80
	mul bl
	add ax, 71
	shl ax, 1
	mov di, ax
	mov ax, 0x07BA
	mov cx, 17
	right:
		mov [es:di], ax
		add di, 160
		loop right
	
	pop di
	pop cx
	pop bx
	pop ax
	pop es
	ret
	
printTitle:
	push bx
	push ds
	push si
	push ax
	push cx
	push es
	push di
	
	mov si, title
	
	mov ax, 0xb800
	mov es, ax
	
	mov bx, 0
	mov ax, 4
    mov bl, 80
    mul bl
    add ax, 36
    shl ax, 1
    mov di, ax
	
    mov ah, 0x1E
	mov cx, 8
	cld
	
	titleloop:
		lodsb
		stosw
		loop titleloop
	
	pop di
	pop es
	pop cx
	pop ax
	pop si
	pop ds
	pop bx
	ret
	
printPara:
	push bp
    mov bp, sp
    push si
    push ax
    push bx
    push cx
    push dx
    push es
    push di
	
	mov ax, 0xb800
    mov es, ax
	mov si, [bp+6] ;message
	mov dh, 6 ;starting row
	mov dl, 10 ;starting col
	
	nextLine:
		mov al, dh
		mov bl, 80
		mul bl
		mov bl, dl
		xor bh, bh
		add ax, bx
		shl ax, 1
		mov di, ax
		
		mov cx, 0
		
	charLoop:
		mov ax, [bp+4]
		lodsb
		cmp al, 0
		je done
		cmp al, 10
		je lineBreak
		
		stosw
		inc cx
		cmp cx, 60
		je lineBreak
		jmp charLoop
		
	lineBreak:
		mov dl, 10
		inc dh
		cmp dh, 21
		jge done
		jmp nextLine
		
	done:
		pop di
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		pop si
		pop bp
		ret 4
		
		
; top, left, bottom, right, n
scroll:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es

	mov ax, 0xb800
	mov ds, ax
	mov es, ax
	cld

	;rows to move
	mov bx, [bp+8]
	sub bx, [bp+12]
	inc bx
	sub bx, [bp+4]

	mov ax, [bp+12]
	mov di, 80
	mul di
	add ax, [bp+10]
	shl ax, 1
	mov di, ax

	mov ax, [bp+4]
	mov si, 160
	mul si
	add ax, di
	mov si, ax

	;width
	mov dx, [bp+6]
	sub dx, [bp+10]
	inc dx

	;skip val
	mov ax, 160
	sub ax, dx
	sub ax, dx

	move:
		mov cx, dx
		rep movsw
		add si, ax
		add di, ax
		dec bx
		jnz move

	mov bx, [bp+4]
	mov si, ax
	mov ax, 0x0720
	
	blank:
		mov cx, dx
		rep stosw
		add di, si
		dec bx
		jnz blank

	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10
	

;string, attr
highlight:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	cld

	mov ax, 0xb800
	mov es, ax
	mov dh, 4

row:
	mov al, dh
	mov ah, 0
	mov bl, 80
	mul bl
	add ax, 9
	shl ax, 1
	mov di, ax
	mov cx, 62

cell:
	mov bx, di
	mov si, [bp+6]

comp:
	lodsb
	cmp al, 0
	je matched
	scasb
	jne next
	inc di
	jmp comp

matched:
	inc word [count]
	mov ax, [bp+4]
	
hl:
	mov [es:di-1], al
	sub di, 2
	cmp di, bx
	ja hl

next:
	mov di, bx
	add di, 2
	dec cx
	jnz cell

	inc dh
	cmp dh, 21
	jb row

	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4

;num, offset
printNum:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	push di
	push es

	mov ax, 0xb800
	mov es, ax
	mov ax, [bp+6]
	mov di, [bp+4]
	mov bx, 10
	xor cx, cx

	divLoop:
		xor dx, dx
		div bx                  ; ax = qt, dx = rmndr
		push dx
		inc cx
		cmp ax, 0
		jne divLoop

	printLoop:
		pop dx
		add dl, '0'
		mov dh, 0x07
		mov [es:di], dx
		add di, 2
		loop printLoop

	mov ax, di

	pop es
	pop di
	pop dx
	pop cx
	pop bx
	pop bp
	ret 4

status:
	push ax
	push si
	push di
	push es

	mov ax, 0xb800
	mov es, ax
	cld
	mov di, 3680
	mov ah, 0x07

	mov si, msg1
	p1:
		lodsb
		cmp al, 0
		je p1done
		stosw
		jmp p1
		
	p1done:
		push word [count]
		push di
		call printNum           ; ax = offset after the number
		mov di, ax
		mov ah, 0x07

	mov si, msg2
	
	p2:
		lodsb
		cmp al, 0
		je p2done
		stosw
		jmp p2
		
p2done:
	pop es
	pop di
	pop si
	pop ax
	ret


start:
	call clrscr
	call viewport
	call printTitle
	
	push paragraph
	push word 0x0700
	call printPara
	
	push word 6     ;top
	push word 9     ;left
	push word 20    ;bottom
	push word 70    ;right
	push word 1     ;n
	call scroll
	
	
	push search
	push word 0xCE
	call highlight
	call status
	
	mov ax, 0x4C00
    int 0x21
	
	
	
