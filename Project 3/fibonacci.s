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