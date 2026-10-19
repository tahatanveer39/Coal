[org 0x0100]
jmp start

obs: dw 0x6552, 0x2C91, 0x7FA3 ; packed observations
numObs: db 3
weights: db 2, -3, -1, 10 ; NORMAL: W1, W2, W3, Bias
db 1, 4, 2, 0 ; SUSPICIOUS: W1, W2, W3, Bias
db -2, 5, 4, -5 ; ATTACK: W1, W2, W3, Bias
normScore: dw 0,0,0 
susScore: dw 0,0,0 
atkScore: dw 0,0,0 
predFlag: dw 0,0,0

x1: db 0
x2: db 0 
x3: db 0

start:
mov si,0
mov cl,[numObs]

check:
	mov ax,[obs+si]
	mov dh,ah
	shr dh,2
	sub dh,20	
	mov [x1],dh	;x1

	rol ax,6
	mov dl,ah
	shr dl,3
	sub dl,8
	mov [x2],dl	;x2

	rol ax,5
	shr ah,3
	sub ah,16
	mov [x3],ah	;x3


	mov bp,-1
	mov bx,0
	
calcNormSc:
	inc bp
	mov ah,0
	mov al,[weights+bp]
	
	cmp al,0
	jge noSignW1
	
	mov ah,-1
	add al,-1
	xor al,-1
	
	noSignW1:
	mov dl,[x1+bx]
	cmp dl,0
	jge noSignX1
	
	mov dh,-1
	jmp skipToCalc1
	
	noSignX1:
	mov dh,0
	
	skipToCalc1:
	mov ch,8
	
	calcMult1:
		shr al,1
		jnc noCar1
		cmp ah,0
		je s1
			sub [normScore+si],dx
			jmp noCar1
		s1:
			add [normScore+si],dx	
			noCar1:
			shl dx,1
			dec ch
			jnz calcMult1
			
	cmp ch,0
	inc bx
	cmp bx,3
	jne calcNormSc
inc bp
mov dl,[weights+bp]
cmp dl,0
jge noSB1
mov dh,-1
jmp skip1
noSB1:
mov dh,0
skip1:
add [normScore+si],dx
mov dx,[normScore]
;jmp e

mov bx,0
calcSusSc:
	inc bp
	mov ah,0
	mov al,[weights+bp]
	
	cmp al,0
	jge noSignW2
	
	mov ah,-1
	add al,-1
	xor al,-1
	
	noSignW2:
	mov dl,[x1+bx]
	cmp dl,0
	jge noSignX2
	
	mov dh,-1
	jmp skipToCalc2
	
	noSignX2:
	mov dh,0
	
	skipToCalc2:
	mov ch,8
	calcMult2:
		shr al,1
		jnc noCar2
		cmp ah,0
		je s2
			sub [susScore+si],dx
			jmp noCar2
		s2:
			add [susScore+si],dx	
		noCar2:
		shl dx,1
		dec ch
		jnz calcMult2
	cmp ch,0
	inc bx
	cmp bx,3
	jne calcSusSc
inc bp
mov dl,[weights+bp]
cmp dl,0
jge noSB2
mov dh,-1
jmp skip2
noSB2:
mov dh,0
skip2:
add [susScore+si],dx


mov bx,0
calcAtkSc:
	inc bp
	mov ah,0
	mov al,[weights+bp]
	
	cmp al,0
	jge noSignW3
	
	mov ah,-1
	add al,-1
	xor al,-1
	
	noSignW3:
	mov dl,[x1+bx]
	cmp dl,0
	jge noSignX3
	
	mov dh,-1
	jmp skipToCalc3
	
	noSignX3:
	mov dh,0
	
	skipToCalc3:
	mov ch,8
	calcMult3:
		shr al,1
		jnc noCar3
		cmp ah,0
		je s3
			sub [atkScore+si],dx
			jmp noCar3
		s3:
			add [atkScore+si],dx	
		noCar3:
		shl dx,1
		dec ch
		jnz calcMult3
	cmp ch,0
	inc bx
	cmp bx,3
	jne calcAtkSc
inc bp
mov dl,[weights+bp]
cmp dl,0
jge noSB3
mov dh,-1
jmp skip3
noSB3:
mov dh,0
skip3:
add [atkScore+si],dx

pred:
	mov ax,[normScore+si]
	cmp [atkScore+si],ax
	jg atkPred
	cmp [susScore+si],ax
	jg susPred
	mov ax,1
	mov [predFlag+si],ax
	jmp skip
	atkPred:
		mov ax,[susScore+si]
		cmp [atkScore+si],ax
		jl susPred
		mov ax,3
		mov [predFlag+si],ax
		jmp skip
	susPred:
		mov ax,[atkScore+si]
		cmp [susScore+si],ax
		jl atkPred
		mov ax,2
		mov [predFlag+si],ax

skip:

add si,2
dec cl
jnz check

e:

mov ax,0x4c00
int 0x21