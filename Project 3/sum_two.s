.global _start
_start:
	movia	sp, 0x04000000
	movi	r4, -7
	movi	r5, -3
	call sum_two

done:
	br done
	
sum_two:

	subi	sp, sp, 8          # stack frame 32 bytes
    stw		ra, 4(sp)          # save return address
   
	add		r2, r4, r5

    xor		r8, r2, r4
    xor 	r9, r2, r5
    and 	r8, r9, r9
    blt 	r8, r0, overflow
   
    ldw    ra, 4(sp)          # restore return address
    addi   sp, sp, 8          # remove frame
   
    ret
	
overflow:
	br overflow