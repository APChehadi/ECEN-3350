##
##  BBint2.s -- Bare Bones Interrupts v.2
##
##  Operation using the DE10-Lite:
##	* Uses Interrupts for Timer0 and The two pushbuttons Key0 & Key1
##	* Counts in binary using the 7-segment display LEDs
##	* PB0 adds 1 to the LEDs
##	* PB1 adds 2 to the LEDs
##	Code below sets gp (global pointer, r26) to 0xFF200000
##	Used as a base for MMI/O, with I-type instructions with offset
##

# MMI/O address offsets from 0xFF200000
        .equ    O_LEDS,        0x0000
        .equ    O_HEX03,       0x0020
        .equ    O_HEX45,       0x0030
        .equ    O_SW,          0x0040
        .equ    O_KEY,         0x0050
        .equ    O_JP1,         0x0060
        .equ    O_ARDUINO,     0x0100
        .equ    O_ARDUINO_RES, 0x0110
        .equ    O_JTAG_UART,   0x1000
        .equ    O_TIMER0,      0x2000

##########################################################

.section    .reset, "ax"			# Reset Vector: 0x00000000

	movia   r2, _start
	jmp     r2                      # Branch to main program

.section    .exceptions, "ax"		# Exception Vector: 0x00000020
.global     EXCEPTION_HANDLER

###########################################################
#  Exception Handler / Interrupt Service Routines (ISRs)  #
###########################################################

EXCEPTION_HANDLER:
	rdctl	et, ipending			# Exception Temporary <- Pending Int Bits
	bne	et, r0, ISR_External		# Exception is external (hardware source)

	# Internal exceptions are NOT handled
	eret




ISR_External:
	subi    ea, ea, 4				# Adjust ea to restart interrupted instruction

	subi	sp, sp, 8				# Must save ALL registers modified in the ISR
	stw     ea,  4(sp)				# Exception Address (where ERET returns)
#	stw     ra, ??(sp)				# <- Needed only if you CALL something
#	stw     r3,  ?(sp)
	stw     r2,  0(sp)

	andi    r2, et, 0b1				# ipending => Timer0 Interrupt?
	beq     r2, r0, NoTimer0_INT

#####################################
#  Timer0 Interrupt Service Routine
#
#	call    ISR_Timer0				# ISR may be in a function, or hardcoded:
	stwio	r2, O_TIMER0(gp)		# Clear Timer0 IRQ (Interrupt Request)
	# ldwio	r2, O_HEX03(gp)
	# addi	r2, r2, 1				# Count-up on the 7-seg display LED bits
	# stwio	r2, O_HEX03(gp)

    movia   r2, TimerFlag           # Set TimerFlag to 1
    movi	r2, 0x1

	br      END_ISR





NoTimer0_INT:
	andi    r2, et, 0b10			# ipending => Pushbutton Interrupt?
	beq     r2, r0, END_ISR

#########################################
#  Pushbutton Interrupt Service Routine
#
#	call    ISR_Key					# ISR may be in a function, or hardcoded:
	ldwio	et, O_KEY+12(gp)		# Edge Capture register (Interrupt Request src)
	stwio	et, O_KEY+12(gp)		# Any Write => Clear "Key" IRQ
	#ldwio	r2, O_LEDS(gp)			# LEDs
	#add	    r2, r2, et				# Count-up on the LEDs (Key0: +1; Key1: +2)
	#stwio	r2, O_LEDS(gp)
	movi	r17, 0x3
	movi	r18, 0b1
	movi	r19, 0b10
	movi	r20, 0x7
	beq		et, r18, INCREASE
	beq		et, r19, DECREASE
	
INCREASE:
	beq		r17, r20, END_ISR
	addi	r17, r17, 1
	addi	r16, r16, 10
	movi	r2, 0(r16)			# 1e8/1e7 = 10Hz
	stwio	r2, O_TIMER0+8(gp)		# Lo halfword
	srli	r2, r2, 16
	stwio	r2, O_TIMER0+12(gp)		# Hi halfword
	movi    r2, 0b0111         		# STOP=0 START=1, CONT=1, ITO=1
	stwio   r2, O_TIMER0+4(gp)
	br	END_ISR
	
DECREASE:
	beq		r17, r18, END_ISR
	subi	r17, r17, 1	
	subi	r16, r16, 10
	movi	r2, 0(r16)			# 1e8/1e7 = 10Hz
	stwio	r2, O_TIMER0+8(gp)		# Lo halfword
	srli	r2, r2, 16
	stwio	r2, O_TIMER0+12(gp)		# Hi halfword
	movi    r2, 0b0111         		# STOP=0 START=1, CONT=1, ITO=1
	stwio   r2, O_TIMER0+4(gp)
	br	END_ISR

END_ISR:
	ldw     r2,  0(sp)
#	ldw     r3,  ?(sp)
#	ldw     ra,  (sp)      			# needed if CALL inst is used
	ldw     ea,  4(sp)      		# restore ALL used registers
	addi    sp, sp, 8
	eret

#############################################################################
.text

.global _start
_start:
# Initialize "global" registers
	orhi	gp, r0, 0xFF20			# MMI/O Base address: gp <- 0xFF200000
	orhi	sp, r0, 0x0400			# Stack Pointer at SDRAM_END+1=0x04000000

# Initialize Timer0 for 100ms interrupt
	movia	r2, 100#00000			# 1e8/1e7 = 10Hz
	stwio	r2, O_TIMER0+8(gp)		# Lo halfword
	srli	r2, r2, 16
	stwio	r2, O_TIMER0+12(gp)		# Hi halfword
	movi    r2, 0b0111         		# STOP=0 START=1, CONT=1, ITO=1
	stwio   r2, O_TIMER0+4(gp)
	movi	r16, 0(r2)

# Initialize Pushbutton 0 & 1 interrupt
	movui	r2, 0b11				# Enable both Key0 & Key1
	stwio	r2, O_KEY+8(gp)			# Interrupt Mask register

# Initialize Internal Interrupt Controller for Timer0 and Pushbutton Interrupts
	movui	r2, 0b11				# See DE10-Lite Computer manual, Table 2, p.10.
	wrctl	ienable, r2				# Enable INT0 & INT1 in the Interrupt Enable Register
	rdctl	r2, status
	ori		r2, r2, 1				# Set .PIE bit (Processor Interrupt Enable)
	wrctl	status, r2


# Initialize Hello Buffs Program
    movia	r3, 0xFF200020
	movia	r4, scroll_message
	movi 	r5, 0x0
	movia	r9, repeat_pattern
	movi 	r11, 18
	movi	r12, 30
	stwio	r0, 0(r3)


# DELAY:	          
# 	ori 	r5, r0, 0x4B40
# 	orhi	r5, r5, 0x004C
# 	br  	LOOP
	
# LOOP:
# 	subi	r5, r5, 1
# 	bgt 	r5, r0, LOOP
# 	br 		CONTROLLER
	

WAIT_FOR_FLAG:
    movia   r6, TimerFlag
    br LOOP

LOOP:
    ldw     r6, (r6)               # Read TimerFlag
    beq     r6, r0, LOOP
    stw     r0,  (r6)
    br CONTROLLER


CONTROLLER:
	blt 	r5, r11, SCROLL
	blt 	r5, r12, PATTERN_DISP
	br  	RESET
	
PATTERN_DISP:
	ldw 	r10, 0(r9)
	stwio 	r10, 0(r3)
	addi	r9, r9, 4
	addi	r5, r5, 1
	# br  	DELAY
    br      WAIT_FOR_FLAG
	
SCROLL:
	slli	r7, r7, 8
	ldw 	r8, 0(r4)
	or  	r7, r7, r8
	stwio	r7, 0(r3)
	addi	r4,	r4, 4
	addi	r5, r5, 1
	# br  	DELAY
    br      WAIT_FOR_FLAG
	
RESET:
	movi	r5, 0x0
	movia	r4, scroll_message
	movia	r9, repeat_pattern
	# br  	DELAY
    br      WAIT_FOR_FLAG

# Do Nothing
Done:	
	br	Done


.data
TimerFlag:
	.word 0

repeat_pattern:
	# A, B, A, B, A, B, C, blank, C, blank, C, blank
	.word	0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x7F7F7F7F, 0x00000000, 0x7F7F7F7F, 0x00000000, 0x7F7F7F7F, 0x00000000 

scroll_message:
	# "Hello Buffs---____" 
	.word	0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7C, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00