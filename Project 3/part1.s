.text

.global sum_two
sum_two:
	# function prologue
	subi	sp, sp, 0xc
    stw		ra, 8(sp)
	stw		fp, 4(sp)
   
	add		r2, r4, r5

	# Overflow Detection
    xor		r8, r2, r4
    xor 	r9, r2, r5
    and 	r8, r9, r9
    blt 	r8, r0, overflow
   
    # function epilogue
	ldw		fp, 4(sp)
	ldw		ra, 8(sp)
    addi	sp, sp, 0xc
   
    ret

overflow:
    br		overflow


.global op_three
op_three:
	# function prologue
	subi	sp, sp, 0xc
    stw		ra, 8(sp)
	stw		fp, 4(sp)
	
	call	op_two
	mov		r4, r2
	mov		r5, r6
	call	op_two
   
    # function epilogue
    ldw		fp, 4(sp)
	ldw		ra, 8(sp)
    addi	sp, sp, 0xc
   
    ret


.global fibonacci
fibonacci:
	subi	sp, sp, 8
	stw		ra, 4(sp)
	stw		r4, 0(sp)
	
	movi	r2, 1
	bgt		r4, r2, fib_loop
	mov		r2, r4
	br		fib_end
	
fib_loop:
	subi	r4, r4, 1
	call	fibonacci
	
	ldw		r4, 0(sp)
	subi	r4, r4, 2
	stw		r2, 0(sp)
	call	fibonacci
	
	ldw		r4, 0(sp)
	add		r2, r2, r4
	
fib_end:
	ldw		ra, 4(sp)
	addi	sp, sp, 8
	ret

.end