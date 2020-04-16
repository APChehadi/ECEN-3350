.equ HEX1, 0xFF200020
	.equ PUSHBUTTONS, 0xFF200050
.global _start
_start:
	movia   r16, HEX1 		# Address of HEX3...HEX0 Displays
	movia   r17, PUSHBUTTONS # Address of pushbuttons
	movia	r18, HEX_bits_1
	movia	r19, HEX_bits_2
	movi 	r10, 8
	movi	r11, 8
	stwio	r0, 0(r16)
    movia   r1, BUTTON_STATE
    movia   r2, COMPARE_NB
    movia   r3, COMPARE_B
    ldw     r1, 0(r1)
    ldw     r2, 0(r2)
    ldw     r3, 0(r3)

LOOP:	          
	ori 	r5, r0, 0x4B40
	orhi	r5, r5, 0x004C
	br  	DELAY
	
DELAY:
	subi	r5, r5, 1
	bgt 	r5, r0, DELAY
	br 		CHECK
	
CHECK:
	ldwio	r12, 0(r17)	#input from pushbuttons
    bne     r12, r0, STATE_CHECKER
	beq     r1, r2, NO_BUTTON
    beq     r1, r3, BUTTON 
	br		CHECK

STATE_CHECKER:
    roli    r1, r1, 16
    beq     r1, r2, NO_BUTTON
    beq     r1, r3, BUTTON
    br      STATE_CHECKER

NO_BUTTON:
	blt		r4, r10, SCROLL_1
	br		RESET
	
SCROLL_1:
	slli	r6, r6, 8
	ldw 	r7, 0(r18)
	or  	r6, r6, r7
	stwio	r6, 0(r16)
	addi	r18, r18, 4
	addi	r4, r4, 1
	br		LOOP
	
BUTTON:
	blt		r4, r11, SCROLL_2
	br		RESET
	
SCROLL_2:
	srli	r13, r13, 8
	ldw 	r14, 0(r19)
	or  	r13, r13, r14
	stwio	r13, 0(r16)
	addi	r19,r19, 4
	addi	r4, r4, 1
	br		LOOP
	
RESET:
	movi	r4, 0x0
	movia	r18, HEX_bits_1
	movia	r19, HEX_bits_2
	br  	LOOP
	
.data
	HEX_bits_1:
		.word 0x79, 0x49, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00
	HEX_bits_2:
		.word 0x4F000000, 0x49000000, 0x49000000, 0x49000000, 0x00, 0x00, 0x00, 0x00
	.end
    BUTTON_STATE:
        .word 0xFFFF0000
    COMPARE_NB:
        .word 0xFFFF0000
    COMPARE_B:
        .word 0x0000FFFF