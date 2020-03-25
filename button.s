.text
	.equ HEX1, 0xFF200020
	.equ PUSHBUTTONS, 0xFF200050
	.global _start
_start: 
	movia   r16, HEX1 		# Address of HEX3...HEX0 Displays
	movia   r17, PUSHBUTTONS # Address of pushbuttons
	movia	r18, HEX_bits_1
	movia	r19, HEX_bits_2

SETUP:
	ldwio	r4, 0(r18)	#load pattern for HEX Displays
	ldwio	r8, 0(r19)
	ldwio	r5, 0(r17)	#input from pushbuttons
	beq     r5, r0, NO_BUTTON
	br		BUTTON
	
CHECK:
	ldwio	r5, 0(r17)	#input from pushbuttons
	beq     r5, r0, NO_BUTTON
	br		BUTTON
	
BUTTON:
	stwio	r8, 0(r16) #store HEX3...HEX0
	roli	r8, r8, -8
	movia	r7, 500000

DELAY2:
	subi	r7, r7, 1
	bne		r7, r0, DELAY2
	br		CHECK

NO_BUTTON:
	stwio	r4, 0(r16)	#store HEX3...HEX0
	roli	r4, r4, 8
	movia	r7, 500000	#delay counter

DELAY:
	subi	r7, r7, 1
	bne	    r7, r0, DELAY
	br		CHECK
.data
	HEX_bits_1:
		.word 0x79494949, 0x00000000
	HEX_bits_2:
		.word 0x4949494F, 0x00000000

	.end