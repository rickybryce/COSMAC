; COUNTER FOR COSMAC MICROCONTROLLER TRAINING UNIT
; EF1 INCREMENTS THE COUNTER
; EF2 RESETS THE COUNTER
; COMPILED WITH A18 ASSEMBLER
; IN DEBIAN LINUX, I CREATED THE FOLLOWING SCRIPT
; NAMED ASM18

; #!/bin/bash
;./a18 $1.asm -l $1.lst -o $1.hex

; THEN MAKE IT EXECUTABLE chmod +x ASM18
; TO COMPILE:  ./ASM18 FILENAME
; --RICKY BRYCE

GPIO1:      EQU 7000H
SEGMENT:    EQU 7102H
DIGIT:      EQU 7101H
ONES:       EQU 8100H
TENS:       EQU 8101H
BREAK:      EQU 2756H

    org    8000H ; MICROCONTROLLER TRAINING UNIT STARTS AT 8000H FOR RAM
R0    EQU    0  ; MAIN PROGRAM COUNTER
R1    EQU    1
R2    EQU    2  ; GPIO
R3    EQU    3  ; DELAY SUBROUTINE COUNTER
R4    EQU    4  ; SEGMENT ACTUAL
R5    EQU    5  ; DIGIT ACTUAL
R6    EQU    6  ; DISPLAY CODE FOR DIGITS
R7    EQU    7  ; DELAY LOOP
R8    EQU    8  ; LOOP COUNTER FOR SCAN
R9    EQU    9  ; VALUES
RA    EQU    10 ; DISPLAY BUFFER
RB    EQU    11 ; SCAN_DIGIT
RC    EQU    12 ; ONES COUNTER
RD    EQU    13 ; TENS COUNTER
RE    EQU    14
RF    EQU    15

INIT:   LOAD    R3, DELAY   ; LOAD R3 WITH DELAY LOCATION
        LOAD    R4, SEGMENT ; LOAD R4 WITH ACTUAL SEGMENT LOCATION
        LOAD    R5, DIGIT   ; LOAD R5 WITH ACTUAL DIGIT LOCATION
        LOAD    R2, GPIO1   ; LOAD 2 WITH GPIO1 (LEDS)
        LDI     00H         ; LOAD 0 TO ACCUMULATOR
        LOAD    RC, ONES    ; LOAD RC WITH ONES
        LDI     00H         ; RELOAD ACCUMULATOR WITH ZERO
        STR     RC          ; STORE THIS TO THE ONES WORKSPACE
        LOAD    RD, TENS    ; LOAD RD WITH TENS LOCATION
        LDI     00H         ; RELOAD ACCUMULATOR WITH ZERO
        STR     RD          ; ZERO THE TENS PLACE
        STR     R2          ; ZERO THE LEDS


MAIN:   LOAD    RA, BUFFER5 ; LOAD A WITH BUFFER 5 (ONES)
        LOAD    R9, VALUE0  ; LOAD R9 WITH VALUE CODES FOR DIGITS
        BR      COUNT       ; GO COUNT
CONT:   LOAD    RB, SCAN_DIGIT  ; SCAN THE DIGIT
        LDI     6       ; LOAD ACCUMULATOR WITH 6 SINCE THERE ARE 6 DIGITS
        PLO     R8      ; LOOP COUNT
LOOP:   LDN     RB      ; GET DIGIT CONTROL
        XRI     0FFH    ; COMPLEMENT IT
        STR     R5      ; WRITE TO DIGIT
        LDN     RA      ; GET BYTE FROM BUFFER
        STR     R4      ; WRITE TO SEGMENT
        SEP     R3      ; DELAY
        LDI     0       ; ZERO ACCUMULATOR
        STR     R4      ; TURN OFF SEGMENTS
        INC     RA      ; INCREMENT DISPLAY BUFFER
        INC     RB      ; INCREMENT DIGIT TO SCAN
        DEC     R8      ; DECREMENT THE LOOP COUNTER
        GLO     R8      ; RELOAD A WITH CURRENT LOOP COUNTER VALUE
        BNZ     LOOP    ; UNTIL 6 DIGITS
        BR      MAIN    ; BACK TO MAIN

        ; DELAY LOOP
RET_DELAY: SEP  R0      ; SET PROGRAM COUNTER BACK TO R0, EXITING
DELAY:  LDI     1       ; LOAD 1 TO ACCUMULATOR
        PLO     R7      ; PLACE 1 INTO R7
DELAY1: DEC     R7      ; DECREMENT R7
        GLO     R7      ; LOAD R7 TO ACCUMULATOR
        BNZ     DELAY1  ; IF NOT YET ZERO, RE-RUN LOOP
        BR      RET_DELAY   ; EXIT SUBROUTINE


BUFFER5:     DB 0BDH    ; ONES
BUFFER4:     DB 0BDH    ; TENS
BUFFER3:     DB 0BDH
BUFFER2:     DB 0BDH
BUFFER1:     DB 0BDH
BUFFER0:     DB 0BDH
SCAN_DIGIT: DB 20H, 10H, 8, 4, 2, 1 ; HEX VALUE TO ENERGIZE EACH DIGIT

; CODES TO DISPLAY EACH DIGIT
VALUE0:     DB 0BDH ; CODE FOR VALUE 0
VALUE1:     DB 030H ; CODE FOR VALUE 1
VALUE2:     DB 09BH ; CODE FOR VALUE 2
VALUE3:     DB 0BAH ; CODE FOR VALUE 3
VALUE4:     DB 036H ; CODE FOR VALUE 4
VALUE5:     DB 0AEH ; CODE FOR VALUE 5
VALUE6:     DB 0AFH ; CODE FOR VALUE 6
VALUE7:     DB 038H ; CODE FOR VALUE 7
VALUE8:     DB 0BFH ; CODE FOR VALUE 8
VALUE9:     DB 03EH ; CODE FOR VALUE 9


COUNT:  BQ      CHKEF   ; IF Q IS ON, CHECK EF INPUTS
UP:     BN1     ZERO    ; INCREMENT AND STORE COUNTER
        LDN     RC      ; LOAD THE ONES
        SEX     RD      ; SET THE INDEX REGISTER TO TENS
        ADD             ; ADD THEM TOGETHER
        XRI     12H     ; SEE IF THEY EQUAL 12H (9 and 9)
        BZ      CONT    ; IF NOT, THEN CONTINUE
        LDI     01H     ; RELOAD 1 WITH ACCUMULATOR
        SEQ             ; TURN ON Q OUTPUT
        SEX     RC      ; SET INDEX REGISTER TO rc
        ADD             ; INCREMENT COUNTER
        STR     RC      ; STORE VALUE BACK TO ONES
        XRI     0AH     ; SEE IF IT'S REACHED A YET
        BZ      ITENS   ; TIME TO INCREMENT TENS
        BR      UPDB    ; UPDATE DISPLAYS

ZERO:   BN2     CONT    ; IF 2 NOT PRESSED, CONTINUE
        LDI     00H     ; ZERO ACCUMULATOR
        STR     RC      ; ZERO ONES
        STR     RD      ; ZERO TENS
        STR     RE      ; CLEAR RE
        STR     RF      ; CLEAR RF
        SEQ             ; TURN ON Q OUTPUT
        BR      UPDB    ; UPDATE THE DISPLAY

ITENS:  LDI     0H      ; RELOAD 0 TO ACCUMULATOR
        STR     RC      ; ONES NOW CONTAIN A ZERO
        SEX     RD      ; SET INDEX REGSTER TO TENS
        LDI     01H     ; LOAD A 1 TO ACCUMULATOR
        ADD             ; ADD 1 TO TENS
        STR     RD      ; STORE BACK TO TENS
        BR      UPDB    ; UPDATE DISPLAYS



CHKEF:  B1      CONT    ; IF EF1 IS PRESSED, CONTINUE
        B2      CONT    ; IF EF2 IS PRESSED, CONTINUE
        REQ             ; OTHERWISE RESET Q
        BR      CONT    ; THEN CONTINUE


UPDB:   
        LDN     RD          ; TENS GET LOADED TO ACCUMULATOR
        SHL                 ; SHIFT LEFT 4 SPACES
        SHL                 ; TO CONVER TO BCD
        SHL
        SHL
        SEX     RC          ; SET X REGISTER TO RC              
        OR
        STR     R2          ; SEND TO LED'S
        
        LOAD    R9, VALUE0  ; START R9 AT VALUE ZERO
        SEX     RC          ; SET INDEX REGISTER TO ONES
        GLO     R9          ; GET THE STARTING VALUE LOCATION (CODE)
        ADD                 ; ADD THEM TOGETHER
        PLO     R9          ; R9 NOW SET TO WHERE WE NEED DATA FOR ONES
        LOAD    R6, BUFFER0 ; R6 BECOMES ONES
        LDN     R9          ; LOAD THE CORRECT CODE FOR DIGIT
        STR     R6          ; STORE THIS CODE TO BUFFER
UTENS:  LOAD    R9, VALUE0  ; RELOAD R9 WITH STARTING VALUE
        SEX     RD          ; SET INDEX REGISTER TO TENS COUNTER
        GLO     R9          ; GET THE LOW BYTE OF R9
        ADD                 ; ADD THE TENS DIGIT
        PLO     R9          ;R9 NOW SET TO WHERE WE NEED DATA FOR TENS
        LOAD    R6, BUFFER1 ; LOAD R6 WITH TENS MEMORY LOCATION
        LDN     R9          ; LOAD ACCUMULATOR WITH DATA
        STR     R6          ; DISPLAY THIS CODE
        BR      CONT        ; CONTINUE
        END
