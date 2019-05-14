[org 0x0100]
jmp start
game_end: dw 0
old_kbisr:dd 0
old_timer:dd 0
body: dw 19
head: dw 0
tail: dw 1124
left: db 1
right: db 0
up: db 0
down: db 0
snake: times 240 dw 0
timerflag:dw 0
second: dw 0
clicks: db 0
fruit_location: dw 0
fruit_flag: db 1
number: dw 900
speed_controller: dw 18
speed_flag: dw 0
speed_chaypi: dw 18
danger: dw 0
danger_fruit_location:dw 0
danger_fruit_flag: dw 0
fruit_count: dw 0
game_over_str: db 'GAME OVER'	;strlen = 9
game_won_str: db 'GAME OVER! Well Played'	;strlen = 21
snake_size: dw 20
total_lives: dw 3
lives:dw 3
life_lost:dw 0
score:dw 0
game_start: dw 0
touch_flag: dw 0
currentTime: dw 240
lives_rem_str: db 'lives Remaining: '  ;strlen = 17
score_str: db 'score: '  ;strlen = 7
time_str: db 'time: '    ;strlen = 6
lives_str: db 'Total lives: '  ;strlen = 13
stage_str: db 'Stage: ' ;strlen 7
game_won: dw 0
stage: dw 1
stage_flag: dw 1
stage_flag2: dw 1
first_move: dw 1
intro1: db 'Stage 1' ;strlen 7
intro2: db 'Stage 2' ;strlen 7
intro3: db 'Stage 3' ;strlen 7
intro_flag: dw 0
chaypi_start: dw 0
sound:
	push ax
	push bx
	push cx
	mov al, 182
	out 43h, al
	mov ax, 4560
	out 42h, al
	in al, 61h
	or al, 00000011b
	out 61h, al
	mov bx, 1
s1:
	mov cx, 5535
s2:
	dec cx
	jne s2
	dec bx
	jne s1
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop cx
	pop bx
	pop ax
	ret

sound_fruit:
	push ax
	push bx
	push cx
	mov al, 182
	out 43h, al
	mov ax, 4560
	out 42h, al
	in al, 61h
	or al, 00000011b
	out 61h, al
	mov bx, 1
s1_fruit:
	mov cx, 65535
s2_fruit:
	dec cx
	jne s2_fruit
	dec bx
	jne s1_fruit
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop cx
	pop bx
	pop ax
	ret
	
	
;Clear Screen
clrscr:
	pusha
	push es
	mov ax, 0xb800
	mov es, ax
	xor di,di
	mov ax,0x0720
	mov cx,2000
	cld
	rep stosw
	pop es
	popa
	ret
	
boundary:
	pusha
	push es
	mov ax, 0xb800
	mov es, ax
	xor di,di
	mov cx, 80
	mov di, 1
	l1:
	mov byte[es:di], 0x6C
	add di, 2
	loop l1
	
	mov cx, 22
	mov di, 161
	l2:
	mov byte[es:di], 0x6C
	add di, 158
	mov byte[es:di], 0x6C
	add di, 2
	loop l2
	mov cx, 80
	mov di, 3681
	l3:
	mov byte[es:di], 0x6C
	add di, 2
	loop l3
	pop es
	popa
	ret

stage2:
	pusha
	push es
	mov ax, 0xb800
	mov es, ax
	mov di, 691
	mov cx, 30
	stage2_loop:
	mov byte[es:di], 0x79
	add di, 2
	loop stage2_loop
	pop es
	popa
	ret
	
stage3:
	pusha
	push es
	mov ax, 0xb800
	mov es, ax
	mov di, 2753
	mov cx, 15
	stage3_loop1:
	mov byte[es:di], 0x79
	add di, 2
	loop stage3_loop1
	mov di, 2813
	mov cx, 15
	stage3_loop2:
	mov byte[es:di], 0x79
	add di, 2
	loop stage3_loop2
	pop es
	popa
	ret
	

	
	
snake_body:    
	push cs
	pop ds                      ; just runs the first time when code starts to give initial position to snake
	cmp word[stage], 2
	jl cont
	call stage2
	cmp word[stage], 3
	jne cont
	call stage3
	cont:
	pusha
	push es
	mov ax, 0xb800
	mov es, ax
	mov bx, 0
	mov ax, [tail]
	mov di, ax
	mov cx, [body]
	mov dx, 0
	body_loop:
	mov byte[es:di],'o'
	mov word[snake+bx], di
	add bx, 2
	inc dx
	cmp dx, 63
	jl snake_normal
	cmp dx, 65
	jge right_snake
	add di, 160
	call next_down_move
	jmp continue_snake
	right_snake:
	cmp dx, 120
	jge down_snake
	sub di, 2
	call next_down_move
	jmp continue_snake
	down_snake:
	cmp dx, 122
	jge reset_pos
	add di, 160
	call next_down_move
	jmp continue_snake
	reset_pos:
	mov dx, 0
	call next_left_move
	snake_normal:
	add di, 2
	call next_left_move
	continue_snake:
	loop body_loop
	mov byte[es:di],'x'
	mov word[snake+bx], di
	mov word[head], bx
	call boundary
	pop es
	popa
	ret
	
kbisr: 
	pusha
	push cs
	pop ds
	in al,0x60
	cmp al,0X4D           ;left arrow
	jne cmp_2
	cmp word[cs:timerflag],1
	jne oldisr_jump
	mov word[cs:timerflag],0
	cmp byte[cs:right], 0           ; if going left then cant just move to right and same is checked in other directions to not to move in opposite direction
	jne oldisr_jump
	mov byte[cs:left], 1
	mov byte[cs:right], 0
	mov byte[cs:up], 0
	mov byte[cs:down], 0
	jmp oldisr_jump

cmp_2:                  ;right arrow
	cmp al,0x4B		
	jne cmp_3
	cmp word[cs:timerflag],1
	jne oldisr_jump
	mov word[cs:timerflag],0
	cmp byte[cs:left], 0
	jne oldisr_jump
	mov byte[cs:left], 0
	mov byte[cs:right], 1
	mov byte[cs:up], 0
	mov byte[cs:down], 0
	jmp oldisr_jump 
	
oldisr_jump:                    ; moved this part to middle of 4 comparisons because there was an error of short jump not found
	popa
	jmp far[cs:old_kbisr]

exit: 
	mov al,20h
	out 20h,al 
	pop es
	pop ax
	iret 
	
cmp_3:                  ; up arrow
	cmp al,0x48		
	jne cmp_4
	cmp word[cs:timerflag],1
	jne oldisr_jump
	mov word[cs:timerflag],0
	cmp byte[down], 0
	jne oldisr_jump
	mov byte[cs:left], 0
	mov byte[cs:right], 0
	mov byte[cs:up], 1
	mov byte[cs:down], 0
	jmp oldisr_jump 
	
cmp_4:                  ; down arrow
	cmp al,0x50	
	jne cmp_5
	cmp word[cs:timerflag],1
	jne oldisr_jump
	mov word[cs:timerflag],0
	cmp byte[cs:up], 0
	jne oldisr_jump
	mov byte[cs:left], 0
	mov byte[cs:right], 0
	mov byte[cs:up], 0
	mov byte[cs:down], 1
	jmp oldisr_jump 

cmp_5:
	cmp al, 0x1c ;Enter Key Pressed
	jne oldisr_jump	
	mov word[cs:game_start], 1
	jmp oldisr_jump	

move:               
push cs
pop ds                 ; this function moves the snake with the positions already saved in array named as snake
	cmp word[stage], 2
	jl cont2
	call stage2
	cmp word[stage], 3
	jne cont2
	call stage3
	cont2:
	pusha
	push es
	mov ax, 0xb800
	mov es, ax
	mov bx, 0
	mov cx, [body]
	cmp word[first_move], 1
	jne print_loop
	mov ax, word[snake+bx]
	mov di, ax
	sub di,2
	mov byte[es:di], ' '
	mov word[first_move], 0
	print_loop:
	mov ax, word[snake+bx]
	mov di, ax
	mov byte[es:di], 'o'
	cmp word[fruit_location], di
	jne move_temp
	mov byte[fruit_flag], 1
	mov byte[es:di+1], 0x07
	move_temp:
	add di, 2
	add bx, 2
	loop print_loop
	mov ax, word[snake+bx]
	mov di, ax
	mov byte[es:di], 'x'
	push di
	call self_touch_check
	cmp word[stage], 2
	jl cont3
	push di 
	call stage2_wall_check
	cmp word[stage], 3
	jne cont3
	push di 
	call stage3_wall_check
	cont3:
	cmp word[touch_flag], 1
	jne fruit_compare
	dec word[lives]
	mov word[life_lost], 1
	mov word[touch_flag], 0
	jmp move_temp2
	fruit_compare:
	cmp word[fruit_location], di
	jne check_danger_fruit
	mov byte[fruit_flag], 1
	mov byte[es:di+1], 0x07
	add word[score], 4
	call sound_fruit
	call increase_body
	check_danger_fruit:
	cmp word[danger_fruit_flag], 0
	jz move_temp2
	cmp word[danger_fruit_location], di
	jne move_temp2
	dec word[lives]
	mov word[life_lost], 1
	mov byte[danger_fruit_flag], 1
	mov byte[es:di+1], 0x07
	call sound_fruit
	move_temp2:
	call boundary
	pop es
	popa
	ret
	
stage2_wall_check:
	push bp
	mov bp, sp
	pusha
	push cs
	pop ds
	cmp word[bp+4], 690
	jl stage2_wall_check_end
	cmp word[bp+4], 748
	jg stage2_wall_check_end
	mov word[touch_flag], 1
	stage2_wall_check_end:
	popa
	pop bp
	ret 2

stage3_wall_check:
	push bp
	mov bp, sp
	pusha
	push cs
	pop ds
	cmp word[bp+4], 2752
	jl stage3_wall_check_end
	cmp word[bp+4], 2782
	jg stage3_wall_next_check
	mov word[touch_flag], 1
	jmp stage3_wall_check_end
	stage3_wall_next_check:
	cmp word[bp+4], 2812
	jl stage3_wall_check_end
	cmp word[bp+4], 2842
	jg stage3_wall_check_end
	mov word[touch_flag], 1
	stage3_wall_check_end:
	popa
	pop bp
	ret 2
	
	
self_touch_check:
	push bp
	mov bp, sp
	pusha
	push cs
	pop ds
	mov cx, [body]
	mov bx, 0
	self_loop:
	mov di, [snake+bx]
	cmp di, [bp+4]
	jne not_touching
	mov word[touch_flag], 1
	jmp self_end
	not_touching:
	add bx, 2
	loop self_loop
	
	self_end:
	popa
	pop bp
	ret 2
	


increase_body:
	pusha 
	push cs
	pop ds
	add word[snake_size], 4
	mov cx, 4
	mov bx, 0
	increase_start:
	push cx
	mov cx, [body]
	mov bx, [head]
	add word[head], 2
	inc cx
	increase_loop:
	mov ax, [snake+bx]
	mov word[snake+bx+2], ax
	sub bx, 2
	loop increase_loop
	inc word[body]
	sub word[snake], 2
	pop cx
	loop increase_start
	popa
	ret
	
updating_body:          ;moves each character in the snake array one step backward so positions are changed
	pusha 
	push cs
	pop ds
	push es
	mov ax, 0xb800
	mov es, ax
	mov cx, [body]
	mov bx, 0
	mov ax, word[snake]
	mov di, ax
	mov word[es:di], 0x0720	
	update_loop:
	mov ax, [snake+bx+2]
	mov word[snake+bx], ax
	add bx, 2
	loop update_loop
	pop es
	popa
	ret

	
snake_movement:                     ; checks which direction the snake is going right now and updates and print 
	pusha
	push cs
	pop ds
	cmp byte[left], 1
	jne right_move
	mov bx, [head]
	
	mov ax, [snake+bx]
	call updating_body
	add ax, 2
	mov word[snake+bx], ax
	call move
	call sound
	;checking if the snake is hitting right wall
	mov cl, 160
	div cl
	cmp ah, 158
	jne jmp_range_chaypi
	dec word[lives]
	mov word[life_lost], 1
	jmp movement_end
	
right_move:
	cmp byte[right], 1
	jne up_move
	mov bx, [head]
	
	mov ax, [snake+bx]
	call updating_body
	sub ax, 2
	mov word[snake+bx], ax
	call move
	call sound
	;checking if the snake is hitting left wall
	mov cl, 160
	div cl
	cmp ah, 0
	jne movement_end
	dec word[lives]
	mov word[life_lost], 1
jmp_range_chaypi:
	jmp movement_end	
	
	
up_move:
	cmp byte[up], 1
	jne down_move
	mov bx, [head]
		
	mov ax, [snake+bx]
	call updating_body
	sub ax, 160
	mov word[snake+bx], ax
	call move
	call sound
	;checking if the snake is hitting upper wall
	cmp ax, 160
	jg movement_end
	dec word[lives]
	mov word[life_lost], 1
	jmp movement_end
	
down_move:
	cmp byte[down], 1
	jne up_move
	mov bx, [head]

	mov ax, [snake+bx]
	call updating_body
	add ax, 160
	mov word[snake+bx], ax
	call move
	call sound
	;checking if the snake is hitting bottom part
	cmp ax, 3680
	jl movement_end
	dec word[lives]
	mov word[life_lost], 1
	
movement_end:
	popa
	ret

fruits:
	pusha
	push cs
	pop ds
	random_pos:
	add word[number], 500
	mov ax, [number]
	mov dx, 0
	mov di, 1759
	div di
	mov di, dx
	add di, 160
	shl di, 1
	cmp di, 160
	jb random_pos
	cmp di ,3778
	ja random_pos
	mov ax, di
	mov cl, 160
	div cl
	cmp ah, 0
	je random_pos
	cmp ah, 158
	je random_pos
	mov ax, 0xb800
	mov es, ax
	mov word[fruit_location], di

	simple_fruit:
	mov byte[es:di], '*'
	mov byte[es:di+1], 0x02
	cmp word[danger], 1
	je dangerous_fruit
	jmp exit_fruit
	
	dangerous_fruit:
	cmp word[danger_fruit_flag], 0
	je print_new_danger_fruit
	mov di, [danger_fruit_location]
	mov byte[es:di], 0x20
	mov byte[es:di+1], 0x07
print_new_danger_fruit:	
	add word[number], 500
	mov ax, [number]
	mov dx, 0
	mov di, 1759
	div di
	mov di, dx
	add di, 160
	shl di, 1
	mov byte[es:di], '$'
	mov byte[es:di+1], 0x04
	mov word[danger_fruit_location], di
	mov word[danger_fruit_flag], 1

	exit_fruit:
	popa
	ret



bonus_and_end:
mov word[game_won], 1
add word[score], 50
jmp end_game

; timer interrupt service routine
timer: 
	push ax
	push cx
	push cs
	pop ds 
	
	call info_bar
	cmp word[cs:chaypi_start], 1
	jz skip_jump_range
	cmp word[cs:game_start], 1 ;game won't start until Enter is pressed
	jne skip_jump_range
	
	cmp word[cs:life_lost], 0
	je game_not_over
	call start_again
	jmp skipall
game_not_over:	
	cmp word[cs:intro_flag], 0
	jne continue_timer_intro
	call start_first
	continue_timer_intro:
	cmp word[cs:currentTime], 0
	ja speed_checking
	cmp word[cs:snake_size], 240
	je bonus_and_end
	dec word[cs:lives]
	mov word[cs:life_lost], 1
	call start_again
skip_jump_range: ;is label say koi farq nahin parta, sirf jump out of range k liye chaypi
	jmp skipall
speed_checking:
	cmp word[cs:snake_size], 240
	je bonus_and_end
	
	cmp word[cs:snake_size], 80
	jne game_not_over3
	cmp word[cs:stage_flag], 1
	jne game_not_over3
	mov word[cs:stage_flag] ,0
	mov word[cs:stage], 2               ;; is jaga pa daal dena stage 2 blinking print wala 2 second ka ////////////////////////////////////
	mov word[cs:game_start], 0
	call intro
	jmp skipall
	game_not_over3:

	cmp word[cs:snake_size], 160
	jne game_not_over5
	cmp word[cs:stage_flag2], 1
	jne game_not_over5
	mov word[cs:stage_flag2] ,0
	mov word[cs:stage], 3                          ; is jaga pa daal dena stage 3 blinking print wala 2 second ka liyay/////////////////////////////
	mov word[cs:game_start], 0
	call intro
	jmp skipall
	game_not_over5:
	;speed Checking
	cmp word[cs:second], 0
	je outer
	mov ax, word[cs:second]
	mov cl, 20
	div cl
	cmp ah, 0
	jne outer
	cmp word[cs:speed_flag], 1
	je outer
	mov ax, word[cs:speed_controller]
	cmp ax, 1 ;fastest possible speed
	je outer
	shr ax, 1
	mov word[cs:speed_controller], ax
	
	mov ax, word[cs:speed_chaypi]
	shr ax, 1
	mov word[cs:speed_chaypi], ax
	mov word[cs:speed_flag], 1
	
outer:
	cmp word[cs:fruit_count], 5
	jne continue_timer
	mov word[cs:danger], 1
	mov word[cs:fruit_count], 0
	continue_timer:
	cmp byte[cs:fruit_flag], 1
	jne timer_temp
	call fruits
	mov word[cs:danger], 0
	inc word[cs:fruit_count]
	mov byte[cs:fruit_flag], 0
	
	
	timer_temp:
	inc byte[cs:clicks]
	cmp byte[cs:clicks], 18
	jne continue
	mov word[cs:speed_flag], 0
	inc word[cs:second]
	dec word[cs:currentTime]
	mov byte[cs:clicks], 0
	continue:
	dec word[cs:speed_controller]
	cmp word[cs:speed_controller], 0
	jne skipall
	call snake_movement
	mov ax, word[cs:speed_chaypi]
	mov word[cs:speed_controller], ax
	
    cmp word[cs:timerflag],1  
    je skipall
	mov word[cs:timerflag],1

skipall:
	mov al,20h
	out 20h,al 	
	; send EOI to PIC
	pop cx
	pop ax
	iret                    ; return from interrupt

info_bar:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	push cs
	pop ds
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,13
	mov dh,24
	mov dl,2
	push cs
	pop es
	mov bp,lives_str
	int 0x10
	
	mov ax,14
	push ax
	mov ax,[cs:total_lives]
	push ax
	call printnum
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,17
	mov dh,24
	mov dl,18
	push cs
	pop es
	mov bp,lives_rem_str
	int 0x10
	
	mov ax,34
	push ax
	mov ax,[cs:lives]
	push ax
	call printnum
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,7
	mov dh,24
	mov dl,40
	push cs
	pop es
	mov bp,stage_str
	int 0x10
	
	mov ax,47
	push ax
	mov ax,[cs:stage]
	push ax
	call printnum
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,7
	mov dh,24
	mov dl,50
	push cs
	pop es
	mov bp,score_str
	int 0x10
	
	mov ax,56
	push ax
	mov ax,[cs:score]
	push ax
	call printnum
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,6
	mov dh,24
	mov dl,64
	push cs
	pop es
	mov bp,time_str
	int 0x10
	
	mov ax,72
	push ax
	mov ax,[cs:currentTime]
	push ax
	call printnum
	cmp word[cs:currentTime], 99
	ja continue_infobar
	mov di, 74
	push 0xb800
	pop es
	mov word[es:di], 0x0720
	continue_infobar:
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax

	ret


start_again:
pusha
push cs 
pop ds
mov word[cs:first_move], 1
cmp word[cs:lives], 0
jnz carry_on
mov word[chaypi_start], 1

carry_on:
call clrscr
call boundary
call snake_body
mov word[cs:life_lost], 0

mov byte[cs:fruit_flag], 1
mov word[cs:danger], 0
mov word[cs:danger_fruit_flag], 0
mov word[cs:danger_fruit_location], 0
mov word[cs:game_start], 0
cmp word[cs:currentTime], 0
jne dont_update_time
mov word[cs:currentTime], 240
call next_down_move
dont_update_time:
popa
ret


next_right_move:
pusha
mov word[cs:left],0
mov word[cs:right],1
mov word[cs:up],0
mov word[cs:down], 0
popa 
ret

next_down_move:
pusha
mov word[cs:left],0
mov word[cs:right],0
mov word[cs:up],0
mov word[cs:down], 1
popa 
ret

next_left_move:
pusha
mov word[cs:left], 1
mov word[cs:right],0
mov word[cs:up],0
mov word[cs:down], 0
popa 
ret
	
printnum:
 push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 xor ax,ax
 mov al,80
 mov bl,24
 mul bl
 mov di,ax
 shl di,1
 mov ax,[bp+6] ;col
 shl ax,1
 add di,ax
 mov ax, [bp+4] ; load number in ax
 mov bx, 10 ; use base 10 for division
 mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
 div bx ; divide by 10
 add dl, 0x30 ; convert digit into ascii value
 push dx ; save ascii value on stack
 inc cx ; increment count of values
 cmp ax, 0 ; is the quotient zero
 jnz nextdigit ; if no divide it again
nextpos: pop dx ; remove a digit from the stack
 mov dh, 0x07 ; use normal attribute
 mov [es:di], dx ; print char on screen
 add di, 2 ; move to next screen location
 loop nextpos ; repeat for all digits on stack
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop es
 pop bp
 ret 4 	
	
intro:
pusha
push cs
pop ds
call clrscr
call boundary
call snake_body
call info_bar
mov word[cs:game_start], 0
mov word[cs:intro_flag], 0
mov ah,0x13
	xor al,al
	xor bh,bh
	mov dh,12
	mov dl,35
	push cs
	pop es	
	mov cx,7
	mov bl,0x81
	cmp word[cs:stage], 1
	jne stage_2_print
	mov bp,intro1
continueIntro:
	int 0x10
exit_intro:
popa
ret
stage_2_print:
	cmp word[cs:stage], 2
	jne stage_3_print
	mov bp,intro2
	jmp continueIntro
stage_3_print:
	mov bp,intro3
	jmp continueIntro
start_first:
pusha
push cs
pop ds
call clrscr
call boundary
call snake_body
call info_bar
mov word[cs:intro_flag], 1
popa
ret
	
start:
	call intro
	xor ax,ax
	mov es,ax 
	mov ax,[es:9*4]
	mov [old_kbisr],ax
	mov ax,[es:9*4+2]
	mov [old_kbisr+2],ax
	mov ax, [es:8*4]
	mov [cs:old_timer], ax 
	mov ax, [es:8*4+2]
	mov [cs:old_timer+2], ax
	cli
	mov word [es:9*4],kbisr 
	mov [es:9*4+2],cs
	mov word [es:8*4],timer 
	mov [es:8*4+2],cs
	sti
	;int 8h
	LLB:
	cmp word[chaypi_start], 0
	jz LLB
	end_game:
push ds 
pop es
	call clrscr
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov dh,12
	mov dl,35

	cmp word[game_won], 1
	je game_won_print
game_lost:	
	mov cx,9
	mov bl,0x84
	mov bp,game_over_str
	int 0x10
	call info_bar
	jmp exit_print
game_won_print:
	mov dl,25
	mov cx,22
	mov bl,0x82
	mov bp,game_won_str
	int 0x10
	call info_bar
exit_print:	
 mov word[game_end], 1
 xor ax,ax
	mov es,ax
	cli
	mov ax, [old_kbisr]
	mov [es:9*4], ax 
	mov ax, [old_kbisr+2]
	mov [es:9*4+2], ax
	mov ax,[old_timer] 
	mov [es:8*4], ax 
	mov ax, [old_timer+2]
	mov [es:8*4+2], ax
	sti
	
	mov ax,0x4c00
	int 0x21
	
	