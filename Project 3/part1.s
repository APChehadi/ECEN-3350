.text

.global sum_two
sum_two:
	subi	sp, sp, 8          # stack frame 32 bytes
    stw		ra, 4(sp)          # save return address
   
	add		r2, r4, r5

    xor		r8, r2, r4
    xor 	r9, r2, r5
    and 	r8, r9, r9
    blt 	r8, r0, overflow
   
    ldw     ra, 4(sp)          # restore return address
    addi    sp, sp, 8          # remove frame
   
    ret

overflow:
    br		overflow


.global op_three
op_three:
	subi	sp, sp, 8          # stack frame 32 bytes
    stw		ra, 4(sp)          # save return address
	stw		r6, 0(sp)
	
	call	op_two
	mov		r4, r2
	ldw		r6, 0(sp)
	mov		r5, r6
	call	op_two
   
    ldw		ra, 4(sp)          # restore return address
    addi	sp, sp, 8          # remove frame
   
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