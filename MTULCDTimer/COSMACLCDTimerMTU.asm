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


LCD_CWR:	EQU	7200H
LCD_DWR:	EQU	7201H
LCD_CRD:	EQU	7202h
LCD_DRD:	EQU	7203H
                        
R0	EQU	0
R1	EQU	1
R2	EQU	2
R3	EQU	3
R4	EQU	4
R5	EQU	5
R6	EQU	6
R7	EQU	7
R8	EQU	8
R9	EQU	9
RA	EQU	10
RB	EQU	11
RC	EQU	12
RD	EQU	13
RE	EQU	14
RF	EQU	15

        org	8000H
        ; initialize registers
        
        LDI	00H
        STR	RB 
        LDI	70H
        PHI	RA
        LDI	00H
        PLO	RA
        PHI RB
        PLO RB
        PHI	R7
        PLO	R7
        PHI	R8
        PLO	R8
        PHI	R9
        PLO	R9
        STR RA
        BR  MAIN
        
        
          ;LCD DRIVERS
RET_LCD1:	SEP	R0
LCD_READY:	LDN	R5
            ANI	80H
            BNZ LCD_READY
            BR	RET_LCD1
        
        ;  INITIALIZE LCD REGISTERS
MAIN:       LOAD	R4, LCD_CWR      
            LOAD	R5, LCD_CRD

            LOAD    R6, LCD_DWR    
            LOAD	R3, LCD_READY
        
            SEP	R3
            LDI	01H
            STR	R4
            SEP	R3
            
            ; WRITE TO THE DISPLAY
        GHI	R9
        ADI 30H
        STR	R6
        SEP	R3
        GLO	R9
        ADI 30H
        STR	R6
        SEP	R3
        GHI	R8
        ADI 30H
        STR	R6
        SEP	R3
        GLO	R8
        ADI 30H
        STR	R6
        SEP	R3
        BR  TIMER
        
        
            ; SET UP DELAYS
                                    ;R8 is two LSDS
                        ;R9 is two MSDS
                        ;RA is for the GPIO
                        ;RB is the counter
                        ;RC is loop 0
                        ;RD is loop 1
                        ;RE is loop 2
                        ;RF is loop 3 fine tune
TIMER:		SEP	R0
INIT0:		LDI	010H
DLY0:		PLO	RC
INIT1:		LDI	010H
DLY1:		PLO	RD
INIT2:		LDI	0DEH
DLY2:		PLO	RE
            DEC	RE
            GLO	RE
            BNZ	DLY2
            DEC	RD
            GLO	RD
            BNZ	DLY1
            DEC	RC
            GLO	RC
            BNZ	DLY0
INIT3:	    LDI	0F0H
DLY3:	    PLO	RF
            DEC	RF
            GLO	RF
            NOP
            BNZ	DLY3
            
            GLO	RB
            ADI	01H
            PLO	RB
            STR	RA
ONES:		GLO	R8
            ADI	01H
            PLO	R8
            GLO	R8
            XRI	0AH
            BNZ	MAIN
            BR	TENS
TENS:		LDI	00H
            PLO	R8
            GHI R8
            ADI	01H
            PHI	R8
            GHI	R8
            XRI	0AH
            BNZ	MAIN
            BR	HUNDREDS
HUNDREDS:	LDI	00H
            PHI	R8
            GLO	R9
            ADI	01H
            PLO	R9
            GLO	R9
            XRI	0AH
            BNZ	MAIN
            BR  THOUSANDS
THOUSANDS:	LDI	00H
            PLO	R9
            GHI	R9
            ADI	01H
            PHI	R9
            GHI	R9
            XRI	0AH
            BNZ	MAIN
            BR	ZERO
ZERO:		LDI	00H
            PLO	R9
            BR	MAIN
            END
