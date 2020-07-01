IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	code db 0,0,0,0
	codeChange db 0,0,0,0
	Clock equ es:6Ch
	guess db 0,0,0,0
	colors db 6h, 9h, 0ah, 0bh, 0ch, 0dh, 0eh, 0fh 
	printV dw 0
	printX dw 0
	MSGStart    db ' Your code:     Results:                            Bulls&Cows', 13,10,10 
				db '                                                    Instruction:', 13,10
				db '                                                    Guess the 4 code colors', 13,10
				db '                                                    order within 14 turns.', 13,10
				db '                                                    Each guess is made by', 13,10
				db '                                                    choosing a row of 4 colors', 13,10
				db '                                                    Enter the color by pressing', 13,10
				db '                                                    the letters/numbers:', 13,10
				db '                                                    Red - press R or 1', 13,10
				db '                                                    Blue - press B or 2', 13,10
				db '                                                    Green - press G or 3', 13,10
				db '                                                    White - press W or 4', 13,10
				db '                                                    Magenta - press M or 5',13,10
				db '                                                    Cyan - press C or 6', 13,10
				db '                                                    Brown - press N or 7', 13,10
				db '                                                    Yellow - press Y or 8', 13,10
				db '                                                    Then, press Enter', 13,10
				db '                                                    Right Arrow - Restart', 13,10
				db '                                                    Backspace - Back', 13,10
				db '                                                    "V" - one in a right place', 13,10
				db '                                                    "X" - one in a wrong place ', 13,10
				db '                                                    No answer - not in the code', 13,10,10,'$'
	MSGWin      db '    You won!!! For a new game press Right Arrow$'
	MSGLose     db 'You lost!!! For a new game press Right Arrow$'
	;dl - new color
CODESEG
; --------------------------
; Your code here - Procedures
;------------------------		
proc start_game
	push ax
	mov ah, 0
	mov al, 2
	int 10h
	mov dx, offset MSGStart
	mov ah, 9
	int 21h
	mov di, 322 
	pop ax
	ret
endp start_game
;------------------------
proc random_char
	push ax
	mov ax, 40h 
 	mov es, ax 
 	mov ax, [Clock] 	 	 	; read timer counter 
 	mov ah, [byte cs:bx] 	 	; read one byte from memory 
 	xor al, ah  	 	 		; xor memory and counter 
 	and al, 00000111b  	 		; leave result between 0-7
	mov ah, 0
	mov si, ax
	mov dh, [colors+si]
	mov [code+bx-1], dh
	mov ax, 0B800h
	mov es, ax
	pop ax
	ret
endp random_char
;------------------------
proc turn
	push ax
	push cx
	mov cx, 4
	mov bx, 1
waitfordata1:
	cmp di, 372
	ja continue
	call random_char
continue:
	mov ah, 1                ; check keyboard status 
    int 16h
	je waitfordata1          ; keyboard buffer empty, we still waiting for input
	
	mov ah, 0                ; we got code in keyboard buffer, 
	                         ; we will get the scan code in <ah> register 
							 ; and remove this code from keyboard buffer
	int 16h
	
	cmp ah, 1h
	je exit
	call check_restart
	cmp di, 372
	jbe dont_cheat1
	cmp ah, 51h  ;cheat(PGDN)
	je call_cheat1
dont_cheat1:
	cmp ah, 0eh  ;delete
	je call_back
	call get_color
	cmp dh, 0
	je waitfordata1
	jmp endproc
call_cheat1:
	call cheat
	jmp waitfordata1
call_cheat2:
	call cheat
	jmp waitfordata2
call_back:
	call back
	jmp waitfordata1	
exit:
	mov ax, 4c00h
	int 21h
endproc:
	call print_new_color
	mov [guess+bx-1], dl
	inc bx 
	add di, 6
	loop waitfordata1
waitfordata2:
	mov ah, 1                ; check keyboard status 
    int 16h
	je waitfordata2          ; keyboard buffer empty, we still waiting for input
	
	mov ah, 0                ; we got code in keyboard buffer, 
	                         ; we will get the scan code in <ah> register 
							 ; and remove this code from keyboard buffer
	int 16h
	call check_restart
	cmp di, 372
	jbe dont_cheat2
	cmp ah, 51h  ;cheat(PGDN)
	je call_cheat2
dont_cheat2:
	cmp ah, 1h
	je exit
	cmp ah, 0eh  ;delete
	je call_back
	cmp ah, 1ch
	jne waitfordata2
	call beep
	pop cx
	pop ax
	ret 
endp turn
;------------------------
proc get_color
	mov dh, 1
	cmp ah, 13h  ;r
	je get_red
	cmp ah, 30h  ;b
	je get_blue
	cmp ah, 22h  ;g
	je get_green
	cmp ah, 11h  ;w
	je get_white
	cmp ah, 32h  ;m
	je get_magenta
	cmp ah, 2eh  ;c
	je get_cyan
	cmp ah, 31h  ;n
	je get_brown
	cmp ah, 15h  ;y
	je get_yellow
	cmp ah, 2  ;r
	je get_red
	cmp ah, 3  ;b
	je get_blue
	cmp ah, 4  ;g
	je get_green
	cmp ah, 5  ;w
	je get_white
	cmp ah, 6  ;m
	je get_magenta
	cmp ah, 7  ;c
	je get_cyan
	cmp ah, 8  ;n
	je get_brown
	cmp ah, 9  ;y
	je get_yellow
	mov dh, 0
	jmp endproc1
get_red:
	mov dl, 0ch
	jmp endproc1
get_blue:
	mov dl, 9h
	jmp endproc1
get_green:
	mov dl, 0ah
	jmp endproc1
get_white:
	mov dl, 0fh
	jmp endproc1
get_magenta:
	mov dl, 0dh
	jmp endproc1
get_cyan:
	mov dl, 0bh
	jmp endproc1
get_brown:
	mov dl, 6h
	jmp endproc1
get_yellow:
	mov dl, 0eh
	jmp endproc1
endproc1:
	ret
endp get_color
;------------------------
proc print_new_color
	push ax
	mov ah, dl
	mov al, 219
	mov [es:di], ax
	mov [es:di+2], ax
	mov [es:di+160], ax
	mov [es:di+162], ax
	pop ax
	ret
endp print_new_color
;------------------------
proc beep
	in al, 61h
	or al, 00000011b
	out 61h, al
	
	mov al, 0B6h
	out 43h, al
	
	mov al, (98h * 2) - 100h
	out 42h, al
	mov al, (0Ah * 2) + 1h
	out 42h, al
	
	mov dx, (0FFh / 3)
	next:
	mov cx, 0FFFFh
	delay_loop:
	loop delay_loop
	dec dx
	jnz next
	
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
endp beep
;------------------------
proc check_colors
	push cx
	push bx
	mov cx, 4
	mov bx, 1
checkV:
	mov dh, [guess+bx-1]
	cmp [codeChange+bx-1], dh
	jne cont1
	mov [codeChange+bx-1], 0
	mov [guess+bx-1], 0
	inc [printV]
cont1:
	inc bx
	loop checkV
	mov cx, 4
	mov bx, 1
checkX1:
	cmp [guess+bx-1], 0
	je cont3
	call checkX
cont3:
	inc bx
	loop checkX1
endpr:
	pop bx
	pop cx
	ret
endp check_colors
;------------------------
proc checkX
	push cx
	mov cx, 4
	mov si, 1
checkX2:
	mov dh, [guess+bx-1]
	cmp [codeChange+si-1], dh
	jne cont2
	mov [codeChange+si-1], 0
	mov [guess+bx-1], 0
	inc [printX]
	jmp endl
cont2:
	inc si
	loop checkX2
endl:
	pop cx
	ret
endp checkX
;------------------------
proc print_results
	push cx
	add di, 6
	cmp [printV], 0
	je continueA
	mov cx, [printV]
Red:
	mov ah, 07h
	mov al, 'V'
	mov [es:di], ax
	add di, 4
	loop Red
continueA:
	cmp [printX], 0
	je continueB
	mov cx, [printX]
White:
	mov ah, 07h
	mov al, 'X'
	mov [es:di], ax
	add di, 4
	loop White
continueB:
	mov cx, 4
	sub cx, [printX]
	sub cx, [printV]
	cmp cx, 0
	je continueC
Black:
	add di, 4
	loop Black
continueC:
	add di, 434
	pop cx
	ret
endp print_results
;------------------------
proc back
	cmp bx, 1
	je endpro
	dec bx
	inc cx
	sub di, 6
	mov dl, 0
	call print_new_color
endpro:
	ret
endp back
;------------------------
proc zero
	push cx
	push bx
	mov [printV], 0
	mov [printX], 0
	mov cx, 4
	mov bx, 1
loop1:
	mov  bx, cx
	mov dh, [code+bx-1]
	mov [codeChange+bx-1], dh
	inc bx
	loop loop1
	pop bx
	pop cx
	ret
endp zero
;------------------------
proc cheat
	push cx
	push bx
	push di
	mov di, 72
	mov cx, 4
	mov bx, 1
print_char:
	mov  bx, cx
	mov ah, [code+bx-1]
	mov al, 219
	mov [es:di], ax
	sub di, 4
	inc bx
	loop print_char
	pop di
	pop bx
	pop cx
	ret
endp cheat
;------------------------
proc check_restart
	cmp ah, 1h
	je exits
	cmp ah, 4dh
	jne not_restart
	jmp Game
not_restart:
	ret
endp check_restart
; --------------------------
; Your code here 
; --------------------------	
Start:
	mov ax, @data
	mov ds, ax
Game:
	call start_game
	mov cx, 14
turns:
	cmp cx, 7
	jne startturn
	mov di, 374
startturn:
	call turn
	call zero
	call check_colors
	call print_results
	cmp [printV], 4
	jne contgame
	mov dx, offset MSGWin
	mov ah, 9
	int 21h
	mov ah, 07h
	mov al, 2
	mov [es:3840], ax
	mov [es:3842], ax
	mov [es:3844], ax
	jmp restart
contgame:
	loop turns
	mov dx, offset MSGLose
	mov ah, 9
	int 21h
restart:
	mov ah, 1                ; check keyboard status 
    int 16h
	je restart          ; keyboard buffer empty, we still waiting for input
	
	mov ah, 0                ; we got code in keyboard buffer, 
	                         ; we will get the scan code in <ah> register 
							 ; and remove this code from keyboard buffer
	int 16h
	call check_restart
	jmp restart
exits:
	mov ax, 4c00h
	int 21h
END start