				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				EXPORT		EINT3_IRQHandler
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R12, =LED_BASE_ADR		; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports

				MOV 		R3, #0xB0000000		; Turn off three LEDs on port 1  
				STR 		R3, [R12, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R12, #0x40] 	; Turn off five LEDs on port 2 
				;MOV			R6, #0x7A
				MOV			R9, #0
				
; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number						
				
				
				LDR			R9,=INTERRUPT		; Loads the INTERRUPT address in R9
				MOV			R8,#0x200000		; Set R8 to 200 000 in hex which corresponds to setting the 21st bit to 1
				STR			R8,[R9]				; Enable the interrupt by storing it back into R9
				LDR			R9,=IO2IntEnf		; Loads the IO2UIntEnf, which enables the falling edge of the interrupt
				MOV			R8,#0				; Reseting R8
				MOV			R8,#0x400			; Set R8 to 400 in hex which corresponds to the 10th bit
				STR			R8,[R9]				; Enables GPIO interrupt for port 2.10 by storing the R8 into R9
															
			BL			RandomNum				; BL to random num to get R11
			MOV			R5, #0x1388				; Set a threshold to 5000 -> corresponds to 0.5s
			MOV			R7,#0					; Initialize R7
			MOV			R10, #1					; initialize Flag (R10) to 1

			BL 			prog1					; BL to scaling program (Lab3)
			
loop5	
			MOV			R6, #15					; Set R6 to 15, which is the first 4 LEDs to high
			BL			DISPLAY_NUM				; Turn 'em on
			MOV			R0, #0x9C4				; Set Delay to 0.25s
			BL 			DELAY					; Call the delay
			MOV 		R6,#0xF0				; change R6 to the other 4 LEDS
			BL			DISPLAY_NUM				; Display	
			MOV			R0, #0x9C4				; Set delay value
			BL			DELAY					; Delay	
			SUBS		R7,R7,R5				; Subs 5000 from Random Num
			CMP			R5,R7					; Compare if random num is less than 5000
			BLLT		loop5					; Leave loop if it is (Another iteration would make it go negative!)
			B			blink					; blinkin'
			
blink		
			MOV			R7,#0					; Reset R7 (using it as a counter)
			MOV 		R8, #100				; Set R8 to 100, sets it as frequency countdown
			MOV			R5,#0xFF				; Set R5 to all 1s to be used as a check
			BL			TurnOn					; Turn them on right away
loop6		
			; check if flag register is 0 if it's 0 then call
			; display num the way we did in lab 3 with the 
			
			ADD			R7, R7, #1				; Increments our counter (reflex thing)
			MOV			R0,#10					; Set delay to 1ms
			BL 			DELAY2					; Call Delay2
			SUBS		R8, R8,#1				; Decrement frequency counter
			BNE			loop6					; loop if result is not zero
			ANDS		R6,R6,R5				; Check if the LEDs were previously on/off
			BLNE		TurnOff					; If on turn off
			BLEQ		TurnOn					; If off, turn on
			
			B			loop6

TurnOff		STMFD		R13!,{R14}
			MOV			R6,#0					; Set R6 to 0
			BL			DISPLAY_NUM				; Display nothing
			MOV 		R8, #100				; Reset Frequency Counter
			LDMFD		R13!,{R15}				

			
			
TurnOn		STMFD		R13!,{R14}
			MOV			R6,#0xFF				; Set R6 to all 1s
			BL			DISPLAY_NUM				; Turn all of the LEDs on
			MOV 		R8, #100				; Reset Frequency Counter
			LDMFD		R13!,{R15}
					
					
EINT3_IRQHandler 	
					STMFD 		R13!,{R14}; Use this command if you need it 
					MOV			R10,#0			; Resets the Flag to 0
					LDR			R4,=IO2IntClr	; Sets the GPIO interrupt Clear for port 2 to R4 	
					ORR			R3,#0x400		; Setting 400 in Hex, which is bit 10
					STR			R3,[R4]			; Clears the port interrupt for 2.10
					LDMFD 		R13!,{R15}
					
					
 				; Use this command if you used STMFD (otherwise use BX LR) 

prog1			STMFD		R13!,{R14}
				
				MOV32		R9,#0x186A0
				MOV32		R12,#0x4E20
				
				; CMP R11 and R9 and checks if its more than the value. If it is, call morethan
				CMP			R11,R9
				BLGT			morethan
					 
			
				; CMP R11 and R10 and checks if its less than the value. If it is, call lessthan
				CMP			R11,R12
				BLLT			lessthan
				
				;otherwise just set r7 to r11
				MOV			R7,R11
								
				
				LDMFD		R13!,{R15}


morethan		STMFD		R13!,{R14}
				MOV			R7,R9
				LDMFD		R13!,{R15}
			

lessthan		STMFD		R13!,{R14}
				MOV			R7,R12
				LDMFD		R13!,{R15}

;counter for second part of the lab aka reflex

COUNTER2		
				MOV			R10,#1
				MOV32		R0, #0x4E20				; set delay multipler to 20000 for 2 second delay
				AND 		R6, R7, #0xFF			; Take in the first 8 bits of the input (R7)	
			
				BL			DISPLAY_NUM				; Branch to DISPLAY_NUM to display the first 8 bits
				BL 			DELAY					; Delays for 2 seconds
				
				
				LSR			R6, R7,#8				; Right shifts to shift the next 8 bits right 8 places
				AND			R6, R6, #0xFF			; Take in the 8 bits of the input
	
				BL 			DISPLAY_NUM				; Branch to DISPLAY_NUM to display the next 8 bits
				BL 			DELAY					; adds a 2 seconds delay
				
				
				LSR			R6, R7,#16				; Right shifts to shift the 8 bits right 16 places
				AND			R6, R6, #0xFF			; Take in the 8 bits of the input
			
				BL			DISPLAY_NUM				; Branch to DISPLAY_NUM to display the next 8 bits
				BL 			DELAY					; adds a 2 second delay
				
				LSR			R6, R7,#24				; Right shifts to shift the 8 bits right 24 places
				AND			R6,R6,#0xFF				; Take in the 8 bits of the input
				
				BL			DISPLAY_NUM				; Branch to DISPLAY_NUM to display the next 8 bits
				;MOV			R0, #0xC350				; Set delay multipler to 100 000 for 5 second delay
				MOV			R0,#0x2710
				BL 			DELAY					; Branch to delay 2 to delay 5 seconds.
				
				MOV			R7,#0					; Resets R7
				B			__MAIN					; Relaunch main program
								; Keep looping
				; add delay of 2 seconds
			
				
DISPLAY_NUM		STMFD		R13!,{R1, R2, R4, R8, R14}

; Usefull commaands:  RBIT (reverse bits), BFC (bit field clear), LSR & LSL to shift bits left and right, ORR & AND and EOR for bitwise operations

				RBIT		R1, R6					; Reverses the bits
				AND			R8, R1, #0xF8000000		; Gets the 5 most significant bit and stores into R8
				LSR		    R8, R8,#25				; Right shifts to get rid of the trailing zeroes and set the MSB to LSB
				
				LDR			R12,=PORTTWO			; Loads PINS 2.0 TO 2.7 into R10
				STRB		R8,[R12]				; Sends R8 to the pins 2.2 to 2.6
				MOV			R8,#0					; resets R8
				
				AND			R8, R1,#0x4000000		; Gets the 6th significant bit and stores into R8
				LSL			R2, R8, #5				; Left shifts to get rid of leading zeroes.
				MOV			R8,#0					; Resets R8 to 0
				
				AND			R8,R1,#0x3000000		; Gets the 7th and 8th MSBs, stores into R8
				LSL			R4, R8, #4				; left shift 4 times to put the 7th/8th bits into the 29th and 30th bits of R4
				ORR			R2, R2, R4				; add R4 and R2 to get port one config. 
				LSR			R2, R2, #24				; get rid of trailing zeros
				
				LDR			R12,=PORTONE			; Loads PINS 1.24 TO 1.31 into R10
				STRB		R2,[R12]				; Sends R2 to the pins 1.28,1.29,1.31
				
				
				
				LDMFD		R13!,{R1, R2, R4, R8, R15}

; R11 holds a 16-bit random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 holds a non-zero 16-bit number.  If a zero is fed in the pseudo-random sequence will stay stuck at 0
; Take as many bits of R11 as you need.  If you take the lowest 4 bits then you get a number between 1 and 15.
;   If you take bits 5..1 you will get a number between 0 and 15 (assuming you right shift by 1 bit).
;
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program OR ELSE!
; R11 can be read anywhere in the code but must only be written to by this subroutine



RandomNum		STMFD		R13!,{R1, R2, R3, R14}	; sets stack pointer to registers, descending wise:then R13-> R14->R3-> R2->R1

				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				LDMFD		R13!,{R1, R2, R3, R15}





;this delay delays for 0.1 milli second


;delay for reflex program
DELAY2	STMFD		R13!,{R5,R14}
		MOV			R5, #0x48		; Smaller value, to accomodate for CMP check, by trial and error 
		MUL 		R5, R5, R0		;	multiply by delay multipliyer 
;loop and decrement to count down
loop4	
		CMP			R10,#1			; Constantly checks the Flag for button press
		BNE			COUNTER2		; If not zero, Branch to counter2, which displays the number
		
		SUBS	R5,#1	
		BNE		loop4	
		LDMFD		R13!,{R5,R15}


DELAY	STMFD		R13!,{R5,R14}
		MOV			R5, #0x7A		;0.1ms delay 
		MUL 		R5, R5, R0		;multiply by delay multipliyer 
;loop and decrement to count down
DEL	
		SUBS	R5,#1				
		BNE		DEL	
		LDMFD		R13!,{R5,R15}

LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]
PORTONE			EQU		0x2009c037
PORTTWO			EQU		0x2009c054	

IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 
INTERRUPT		EQU		0xE000E100
; set bit 21 on this address ISE_EINT3
IO2IntClr		EQU		0x400280AC

FIO2PIN1		EQU		0x2009c055


				ALIGN 

				END 
