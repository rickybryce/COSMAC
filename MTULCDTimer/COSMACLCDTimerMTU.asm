; LCD Timer for COSMAC 1802 
; Microprocessor Training Unit
; No user input in this program.
; It will run as soon as you hit GO
; Time will also appear on the LEDs

; Used with a18 assembler.
; William Coley A18 cross-assembler

; TO ASSEMBLE, I CREATED A SCRIPT CALLED ASM18
; #!/bin/bash
; ./a18 $1.asm -l $1.lst -o $1.hex
; then run; ./asm18 CosmacTimerMTU
; EF1 Starts and Stops the Timer
; EF2 Resets the Timer
; Don't forget to add character and line delays.

; RICKY BRYCE

GPIO:       EQU 7000H  ; LEDS
LCD_CWR:	EQU	7200H  ; CONTROL WRITE
LCD_DWR:	EQU	7201H  ; DATA WRITE
LCD_CRD:	EQU	7202H  ; CONTROL READ
LCD_DRD:	EQU	7203H  ; DATA READ
TUNE0:      EQU 0A0H   ; TUNE LOOP 0 TIME +1
TUNE1:      EQU 10H    ; TUNE LOOP 1 TIME +1
TUNE2:      EQU 08H    ; TUNE LOOP 2 TIME +1
TUNEF1:     EQU 01H    ; TUNE FINE LOOP TIME +1 ; 20 300S 1 SLOW
TUNEF2:     EQU 01H    ; TUNE FINE LOOP TIME +1
TUNEF3:     EQU 10H    ; TUNE FINEST LOOP TIME +1 ; 40 300S 1 SLOW

; MAP REGISTERS
R0	EQU	0 ; MAIN PROGRAM COUNTER
R1	EQU	1 ; INTERRUPT VECTOR
R2	EQU	2 ; NORMALLY, STACK POINTER, BUT HERE, WILL BE MODE
R3	EQU	3 ; SUBROUTINE PROGRAM COUNTER WAIT FOR LCD READY
R4	EQU	4 ; CONTROL WRITE - LCD
R5	EQU	5 ; CONTROL READ - LCD
R6	EQU	6 ; DATA WRITE - LCD
R7	EQU	7 ; DATA READ - LCD
R8	EQU	8 ; LOW FOR ONES, HIGH FOR TENS
R9	EQU	9 ; LOW FOR HUNDREDS; HIGH FOR THOUSANDS
RA	EQU	10 ; GPIO
RB	EQU	11 ; COUNTER
RC	EQU	12 ; DELAY LOOP 0
RD	EQU	13 ; DELAY LOOP 1
RE	EQU	14 ; DELAY LOOP 2
RF	EQU	15 ; FINE DELAY LOOP

        org	8000H ; COSMAC MTU STARTS AT 8000H
        ; initialize registers
        
        ; REMOVE VVV
        ;LDI	00H ; LOAD ACCUMULATOR WITH ZERO
        ;STR	RB  ; INITIALIZE COUNTER
        ;LDI	70H ; LOAD D WITH 70H
        ;PHI	RA  ; 
        ; REMOVE AAA
INIT:      
        LOAD  RA, GPIO      ; LEDS
        LOAD  R4, LCD_CWR   ; CONTROL WRITE   
        LOAD  R5, LCD_CRD   ; CONTROL READ
        LOAD  R6, LCD_DWR   ; DATA WRITE 
        LOAD  R7, LCD_DRD   ; DATA READ
        LOAD  R3, LCD_READY ; LCD READY FOR NEW DATA
        
        LDI	00H ; LOAD 0 FROM ACCUMULATOR
        PHI RB  ; CLEAR COUNTER HIGH
        PLO RB  ; CLEAR COUNTER LOW
        PHI RC  ; CLEAR DELAY HIGH
        PLO RC  ; CLEAR DELAY LOW
        PHI RD  ; CLEAR DELAY HIGH
        PLO RD  ; CLEAR DELAY LOW
        PHI RE  ; CLEAR DELAY HIGH
        PLO RE  ; CLEAR DELAY LOW
        PHI RF  ; CLEAR DELAY HIGH
        PLO RF  ; CLEAR DELAY LOW
        PHI	R7  ; CLEAR DATA READ
        PLO	R7  ; CLEAR DATA READ
        PHI	R8  ; CLEAR TENS
        PLO	R8  ; CLEAR ONES
        PHI	R9  ; CLEAR THOUSANDS
        PLO	R9  ; CLEAR HUNDREDS
        STR RA  ; CLEAR GPIO
        PHI R2  ; CLEAR ONESHOT
        PLO R2  ; SET MODE TO STOP

        BR  MAIN
        
        
          ;LCD DRIVERS
RET_LCD1:	
        SEP	R0 ; SET THE PROGRAM COUNTER TO MAIN (EXIT SUBROUTINE)
            ; SUBROUTINE IS BELOW, AND EXECUTED BY A CHANGE OF PC TO R3
            ; WE JUMP INTO LCD_READY
LCD_READY:	
        LDN	R5 ; LOAD REGISTER R5
        ANI	80H ; SEE IF BIT 7 IS HIGH
        BNZ LCD_READY ; IF SO, STAY HERE
        BR	RET_LCD1  ; SET PROGRAM COUNTER BACK TO ZERO
        
MAIN:       
        SEP	R3  ; CHECK TO SEE IF THE LCD IS READY
        LDI	01H ; LOAD 1 TO D
        STR	R4  ; ENABLE LCD
        SEP	R3  ; WAIT FOR LCD TO BECOME READY
            
            ; WRITE TO THE DISPLAY
        GHI	R9    ; GET THOUSANDS
        ADI 30H   ; ADD 30 TO CONVERT TO ASCII
        STR	R6    ; THEN STORE THIS TO R6
        SEP	R3    ; WAIT FOR LCD TO BECOME READY
        GLO	R9    ; GET HUNDREDS
        ADI 30H   ; ADD 30 TO CONVERT TO ASCII
        STR	R6    ; STORE THIS TO R6
        SEP	R3    ; WAIT FOR LCD
        GHI	R8    ; GET TENS
        ADI 30H   ; CONVERT TO ASCII
        STR	R6    ; SEND TO DISPLAY
        SEP	R3    ; WAIT FOR LCD
        GLO	R8    ; GET THE ONES
        ADI 30H   ; CONVERT TO ASCII
        STR	R6    ; SEND TO DISPLAY
        SEP	R3    ; WAIT FOR LCD READY
        GLO R2    ; GET THE MODE
        BNZ  TIMER ; GO TO TIMER LOGIC
WAITEF1:
        BN1 WAITEF1 ; HOLD UNTIL READY AFTER RESET
        
        
            ; SET UP DELAYS
                        ;R8 is two LSDS
                        ;R9 is two MSDS
                        ;RA is for the GPIO
                        ;RB is the counter
                        ;RC is loop 0
                        ;RD is loop 1
                        ;RE is loop 2
                        ;RF is loop 3 fine tune
TIMER:		;SEP	R0      ; PROGRAM COUNTER REGISTER BECOMES 0
INIT0:		LDI	TUNE0    ; LOAD ACCUMULATOR WITH 10H FOR CALIBRATION
            PLO	RC      ; LOAD RC WITH VALUE OF TUNE0
DLY0:       DEC RC
INIT1:		LDI	TUNE1    ; RELOAD ACCUMULATOR WITH 10H (MORE CALIBRATION)
            PLO	RD      ; LOAD RD WITH 10H
DLY1:       DEC RD
INIT2:		LDI	TUNE2    ; LOAD ACCUMULATOR WITH 1E ; WAS DEH
            PLO	RE      ; PLACE THIS INTO RE
            NOP
            NOP
            NOP
DLY2:       DEC	RE      ; THEN DECREMENT RE
            BR CHKEF    ; CHECK EF1 AND EF2 INPUTS (BOTTOM OF FILE)
CONTDLY:    ; CONTINUE WITH DELAY
            
            GLO	RE      ; GET THE LOW BYTE OF RE
            BNZ	DLY2    ; BRANCH BACK TO DLY2 IF NOT ZERO
            GLO	RD      ; THEN GET THE LOW BYTE OF RD
            BNZ	DLY1    ; IF NOT ZERO, THEN GO TO INIT2
            GLO	RC      ; GET THE LOW BYTE OF RC
            BNZ	DLY0    ; IF NOT YET ZERO, THEN RE-RUN DLY1
            
            ; FINE TUNE
INIT3:	    LDI	TUNEF1    ; LOAD ACCUMULATOR WITH 10H ; WAS F0H
            PLO	RF      ; PLACE THIS INTO THE LOW BYTE OF RF
DLY3:       DEC	RF      ; THEN DECREMENT RF
INIT4:	    LDI	TUNEF2    ; LOAD ACCUMULATOR WITH 10H ; WAS F0H
            PLO	RE      ; PLACE THIS INTO THE LOW BYTE OF RF
DLY4:       DEC	RE      ; THEN DECREMENT RF
            GLO	RE      ; SEE WHAT THE LOW BYTE OF RF IS
            NOP
            
            BNZ	DLY4    ; IF NOT ZERO, RE-RUN DLY3
            GLO	RF      ; SEE WHAT THE LOW BYTE OF RF IS
            NOP         ; NOP FOR CALIBRATION
            NOP
            NOP
            NOP
            BNZ	DLY3    ; IF NOT ZERO, RE-RUN DLY3
            

            
            ; FINEST TUNE
INIT5:	    LDI	TUNEF3    ; LOAD ACCUMULATOR WITH 10H ; WAS F0H
            PLO	RF      ; PLACE THIS INTO THE LOW BYTE OF RF
DLY5:       DEC	RF      ; THEN DECREMENT RF
            GLO	RF      ; SEE WHAT THE LOW BYTE OF RF IS
            ;NOP         ; NOP FOR CALIBRATION
            ;NOP
            BNZ	DLY5    ; IF NOT ZERO, RE-RUN DLY3
            

            
            GLO	RB      ; COUNTER
            ADI	01H     ; ADD 1 TO COUNTER
            PLO	RB      ; STORE BACK TO COUNTER
            STR	RA      ; STORE TO GPIO
ONES:		GLO	R8   ; GET THE LOW VALUE OF R8 (ONES)
            ADI	01H  ; INCREMENT THE ONES
            PLO	R8   ; STORE IT BACK TO R8
            GLO	R8   ; GET THE LOW VALUE AGAIN
            XRI	0AH  ; CHECK FOR AH
            BNZ	MAIN ; IF IT HASN'T REACHED 0AH, WE CAN CONTINUE
            BR	TENS ; OTHERWISE, IT'S TIME TO EXECUTE THE TENS LOGIC
TENS:		LDI	00H  ; LOAD 0 TO ACCUMULATOR
            PLO	R8   ; ZERO THE ONES
            GHI R8   ; GET THE TENS
            ADI	01H  ; ADD ONE
            PHI	R8   ; PUT THE NEW VALUE BACK TO R8 (HIGH)
            GHI	R8   ; GET THE HIGH VALUE OF R8 (TENS)
            XRI	0AH  ; CHECK FOR AH
            BNZ	MAIN ; IF NOT ZERO, THEN WE CAN CONTINUE
            BR	HUNDREDS ; IF IT'S 0AH, THEN WE NEED TO WORK WITH HUNDREDS
HUNDREDS:	LDI	00H  ; LOAD 0 TO ACCUMULATOR
            PHI	R8   ; PLACE THIS INTO R8 HIGH (TENS)
            GLO	R9   ; GET THE LOW VALUE OF R9 (HUNDREDS)
            ADI	01H  ; ADD 1
            PLO	R9   ; STORE THIS TO R9 LOW (HUNDREDS)
            GLO	R9   ; GET THE LOW VALUE OF R9 (HUNDREDS)
            XRI	0AH  ; CHECK FOR AH
            BNZ	MAIN ; IF NOT ZERO, THEN CONTINUE
            BR  THOUSANDS ; OTHERWISE WORK WITH THOUSANDS
THOUSANDS:	LDI	00H  ; LOAD 0 TO ACCUMULATOR
            PLO	R9   ; PLACE THIS INTO R9 LOW (HUNDREDS)
            GHI	R9   ; GET THE VALUE OF R9 HIGH (THOUSANDS)
            ADI	01H  ; ADD 1
            PHI	R9   ; PUT THIS BACK TO R9 HIGH
            GHI	R9   ; GET R9 HIGH
            XRI	0AH  ; CHECK FOR AH
            BNZ	MAIN ; IF NOT REACHED A, CONTINUE
            BR	ZERO ; OTHERWISE ZERO
ZERO:		LDI	00H  ; LOAD ACCUMULATOR WITH ZERO
            PLO	R9   ; ZERO THOUSANDS
            BR	MAIN ; START AGAIN

MODEHLT:
            B2 INIT        ; INITIALIZE IF EF2 PRESSED
            B1 EF1PRESSED  ; RECHECK BUTTONS
            BN1 CLRHLTONS  ; CLEAR ONS IN THIS MODE
            LBR MODEHLT     ; CONTINUE LOOP
; PAGE BOUNDARY 
CLRHLTONS:  
            LDI 00H        ; LOAD 00H TO ACCUMULATOR
            PHI R2         ; CLEAR ONS 
            LBR MODEHLT     ; CONTINUE LOOP
            
            ; HANDLE MODES WHILE WE ARE HERE
            ; CLEAR EF1 ONE SHOT
CHKEF:      ; CHECK FOR EF1
            B2 INIT     ; IF EF2=0, RE-INITIALIZE (ACTIVE LOW)
            B1 EF1PRESSED
            BN1 EF1NOTPRESSED
EF1PRESSED: 
            GHI R2    ; CHECK ONESHOT
            BZ CHNGMODE ; CHANGE THE MODE
            GLO R2    ; CHECK MODE
            BZ MODEHLT  ; ENTER HALT MODE IF ZERO
            BR CONTDLY  ; IF MODE=1 AND NO ONESHOT, CONTINUE
            
EF1NOTPRESSED:
            LDI 00H     ; LOAD 0 TO ACCUMULATOR
            PHI R2      ; CLEAR ONE SHOT
            BR CONTDLY
            
CHNGMODE:
            ; AT THIS POINT, ONS=1 AND BUTTON PRESSED.  CHANGE MODE
            LDI 01H   ; SET THE ACCUMULATOR TO 1
            PHI R2    ; TURN ON ONE SHOT.  WE KNOW IT WAS OFF.
            GLO R2    ; CHECK THE MODE
            LBZ CHRUN  ; IF ZERO THEN CHANGE TO RUN MODE
            LBNZ CHHLT ; IF NOT ZERO, CHANGE TO HALT MODE
CHRUN:
            LDI 01H   ; LOAD 1 TO ACCUMULATOR
            PLO R2    ; SET MODE TO RUN
            LBR CONTDLY ; CONTINUE
CHHLT:
            LDI 00H    ; LOAD 0 TO ACCUMULATOR
            PLO R2    ; SET MODE TO HALT
            LBR MODEHLT ; ENTER HALT MODE
       


            END
