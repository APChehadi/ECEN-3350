.equ	HEX_DISP_3_0, 0xFF200020
.global _start
_start:
	movia	r2, HEX_DISP_3_0
	movia	r3, scroll_message
	movi 	r4, 0x0
	movia	r8, repeat_pattern
	movi 	r10, 18
	movi	r11, 30
	stwio	r0, 0(r2)
LOOP:	          
	ori 	r5, r0, 0x4B40
	orhi	r5, r5, 0x004C
	br  	DELAY
DELAY:
	subi	r5, r5, 1
	bgt 	r5, r0, DELAY
	br 		CONTROLLER
CONTROLLER:
	blt 	r4, r10, SCROLL
	blt 	r4, r11, PATTERN_DISP
	br  	RESET
PATTERN_DISP:
	ldw 	r9, 0(r8)
	stwio 	r9, 0(r2)
	addi	r8, r8, 4
	addi	r4, r4, 1
	br  	LOOP
SCROLL:
	slli	r6, r6, 8
	ldw 	r7, 0(r3)
	or  	r6, r6, r7
	stwio	r6, 0(r2)
	addi	r3,	r3, 4
	addi	r4, r4, 1
	br  	LOOP
RESET:
	movi	r4, 0x0
	movia	r3, scroll_message
	movia	r8, repeat_pattern
	br  	LOOP
.data
repeat_pattern:
	# A, B, A, B, A, B, C, blank, C, blank, C, blank
	.word	0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x7F7F7F7F, 0x00000000, 0x7F7F7F7F, 0x00000000, 0x7F7F7F7F, 0x00000000 
scroll_message:
	# "Hello Buffs---____" 
	.word	0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7C, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00
