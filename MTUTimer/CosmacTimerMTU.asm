; ASSEMBLED WITH THE
; William Coley A18 cross-assembler

; TO ASSEMBLE, I CREATED A SCRIPT CALLED ASM18
; #!/bin/bash
; ./a18 $1.asm -l $1.lst -o $1.hex
; then run; ./asm18 CosmacTimerMTU
; EF1 Starts and Stops the Timer
; EF2 Resets the Timer
; Don't forget to add character and line delays.

; RICKY BRYCE

GPIO1:      EQU 7000H 
SEGMENT:    EQU 7102H
DIGIT:      EQU 7101H
HUNDREDTHS: EQU 8300H
TENTHS:     EQU 8301H
ONES:       EQU 8302H
TENS:       EQU 8303H
HUNDREDS:   EQU 8304H
THOUSANDS:  EQU 8305H
FREERUN:    EQU 8306H
EFLAGS:     EQU 8307H
BREAK:      EQU 2756H


    ORG    8000H        ; 1802 TRAINING UNIT STARTS AT 8000
R0    EQU    0          ; REGISTER DEFINITIONS
R1    EQU    1
R2    EQU    2
R3    EQU    3
R4    EQU    4
R5    EQU    5
R6    EQU    6
R7    EQU    7
R8    EQU    8
R9    EQU    9
RA    EQU    10
RB    EQU    11
RC    EQU    12
RD    EQU    13
RE    EQU    14
RF    EQU    15

START:  LOAD    R3, DELAY       ; DELAY LOOP
        LOAD    R4, SEGMENT     ; SEGMENTS TO TURN ON
        LOAD    R5, DIGIT       ; DIGITS CONTAIN SEGMENTS
        LOAD    RF, FREERUN     ; FREE RUNNING TIMER
        LDI     00H             ; CLEAR D
        STR     RF              ; STORE D TO FREE RUNNING CLOCK
        LOAD    RE, GPIO1       ; GPIO1 IS THE LEDS
        LDI     00H             ; LOAD D WITH 0 AGAIN
        LOAD    RD, EFLAGS      ; RD WILL CONTAIN THE EF BITS
        LDI     00H             ; RELOAD D WITH 0
        STR     RD              ; ZERO FLAGS
        LOAD    RC, HUNDREDTHS  ; LOAD RC WITH HUNDREDTHS
        LDI     00H             ; RELOAD D WITH 0
        STR     RC              ; ZERO HUNDREDTHS
        LOAD    RC, TENTHS      ; RELOAD RC WITH TENTHS
        LDI     00H             ; D BECOMES ZERO
        STR     RC              ; ZERO TENTHS
        LOAD    RC, ONES        ; LOAD RC WITH ONES
        LDI     00H             ; RELOAD D WITH 0
        STR     RC              ; ZERO ONES
        LOAD    RC, TENS        ; RELOAD  RC WITH TENS
        LDI     00H             ; LOAD 0 TO D
        STR     RC              ; CLEAR TENS
        LOAD    RC, HUNDREDS    ; LOAD RC WITH HUNDREDS
        LDI     00H             ; LOAD D WITH 0
        STR     RC              ; CLEAR HUNDREDS
        LOAD    RC, THOUSANDS   ; RELOAD RC WITH THOUSANDS
        LDI     00H             ; ZERO REGISTER D
        STR     RC              ; CLEAR THOUSANDS
        REQ                     ; RESET Q OUTPUT ON PROCESSOR
MAIN:   LOAD    RA, BUFFER5
        LOAD    R9, VALUES
        LBR     CHKEF1
CONT2:  BNQ     CONT
        SEX     RF
        LDI     01H
        ADD
        STR     RF
        XRI     1FH                             ;CALIBRATE
        LBZ     COUNT
CONT:   LOAD    RB, SCAN_DIGIT
        LDI     6
        PLO     R8      ;LOOP COUNT
LOOP:   LDN     RB      ;GET DIGIT CONTROL
        XRI     0FFH    ;COMPLEMENT IT
        STR     R5      ;WRITE TO DIGIT
        LDN     RA      ;GET BYTE FROM BUFFER
        STR     R4      ;WRITE TO SEGMENT
        SEP     R3      ;DELAY
        LDI     0       ;TURN OFF DISPLAY
        STR     R4
        INC     RA
        INC     RB
        DEC     R8
        GLO     R8
        BNZ     LOOP    ;UNTIL 6 DIGITS
        BR      MAIN
RET_DELAY: SEP  R0
DELAY:  LDI     1
        PLO     R7
DELAY1: DEC     R7
        GLO     R7
        BNZ     DELAY1
        BR      RET_DELAY
BUFFER5:     DB 0BDH
BUFFER4:     DB 0BDH
BUFFER3:     DB 0BDH
BUFFER2:     DB 0BDH
BUFFER1:     DB 0BDH
BUFFER0:     DB 0BDH
SCAN_DIGIT: DB 20H, 10H, 8, 4, 2, 1
VALUES:     DB 0BDH, 030H, 09BH, 0BAH, 036H, 0AEH, 0AFH, 038H, 0BFH, 03EH


LIHNTH: LBR     IHNTH

ZERO:   BN2     LIHNTH
UNCZRO: LOAD    RC, HUNDREDTHS
        LDI     00H
        STR     RC
        LOAD    RC, TENTHS
        LDI     00H
        STR     RC
        LOAD    RC, ONES
        LDI     00H
        STR     RC
        LOAD    RC, TENS
        LDI     00H
        STR     RC
        LOAD    RC, HUNDREDS
        LDI     00H
        STR     RC
        LOAD    RC, THOUSANDS
        LDI     00H
        STR     RC
        LBR     UPDB

COUNT:  LDI     00H
        STR     RF
IHNTH:  LOAD    RC, HUNDREDTHS
        SEX     RC
        LDI     02H
        ADD     ;INCREMENT TIMER
        STR     RC      ;RC NOW CONTAINS THE HUNDREDTHS VALUE
        LDN     RC
        XRI     0AH
        LBZ     ITNTH
        LBR     UPDB

ITNTH:  LOAD    RC, HUNDREDTHS
        LDI     0H
        STR     RC      ;RC NOW CONTAINS A ZERO
        LOAD    RC, TENTHS
        SEX     RC
        LDI     01H
        ADD
        STR     RC      ;RD NOW CONTAINS THE TENTHS VALUES
        LDN     RC
        XRI     0AH
        LBZ     IONES
        LBR     UPDB

IONES:  LOAD    RC, TENTHS
        LDI     0H
        STR     RC      ;RC NOW CONTAINS A ZERO
        LOAD    RC, ONES
        SEX     RC
        LDI     01H
        ADD
        STR     RC      ;RD NOW CONTAINS THE ONES VALUES
        LDN     RC
        XRI     0AH
        LBZ     ITENS
        LBR     UPDB

ITENS:  LOAD    RC, ONES
        LDI     0H
        STR     RC      ;RC NOW CONTAINS A ZERO
        LOAD    RC, TENS
        SEX     RC
        LDI     01H
        ADD
        STR     RC      ;RD NOW CONTAINS THE TENS VALUES
        LDN     RC
        XRI     0AH
        LBZ     IHUN
        LBR     UPDB

IHUN:   LOAD    RC, TENS
        LDI     0H
        STR     RC      ;RC NOW CONTAINS A ZERO
        LOAD    RC, HUNDREDS
        SEX     RC
        LDI     01H
        ADD
        STR     RC      ;RD NOW CONTAINS THE HUNDREDS VALUES
        LDN     RC
        XRI     0AH
        LBZ     ITHOU
        LBR     UPDB

ITHOU:  LOAD    RC, HUNDREDS
        LDI     0H
        STR     RC      ;RC NOW CONTAINS A ZERO
        LOAD    RC, THOUSANDS
        SEX     RC
        LDI     01H
        ADD
        STR     RC      ;RD NOW CONTAINS THE THOUSANDS VALUES
        LDN     RC
        XRI     0AH
        LBZ     UNCZRO
        LBR     UPDB

CONT1:  LBR     CONT


UPDB:   NOP
UHNTH:  LOAD    R9, VALUES
        LOAD    RC, HUNDREDTHS
        SEX     RC
        GLO     R9
        ADD
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR HUNDREDTHS
        LOAD    R6, BUFFER0
        LDN     R9
        STR     R6

UTNTHS: LOAD    R9, VALUES
        LOAD    RC, TENTHS
        SEX     RC
        GLO     R9
        ADD
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR TENTHS
        LOAD    R6, BUFFER1
        LDN     R9
        STR     R6


UONES:  LOAD    R9, VALUES
        LOAD    RC, ONES
        SEX     RC
        GLO     R9
        ADD
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR ONES
        LOAD    R6, BUFFER2
        LDN     R9
        STR     R6
        STR     RE

UTENS:  LOAD    R9, VALUES
        LOAD    RC, TENS
        SEX     RC
        GLO     R9
        ADD
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR TENS
        LOAD    R6, BUFFER3
        LDN     R9
        STR     R6

UHNDRD: LOAD    R9, VALUES
        LOAD    RC, HUNDREDS
        SEX     RC
        GLO     R9
        ADD
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR HUNDREDS
        LOAD    R6, BUFFER4
        LDN     R9
        STR     R6

UTHOU:  LOAD    R9, VALUES
        LOAD    RC, THOUSANDS
        SEX     RC
        GLO     R9
        ADD
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR THOUSANDS
        LOAD    R6, BUFFER5
        LDN     R9
        STR     R6


CHKEF1: B2      EF2P
        BN1     RSFLAG
        LDN     RD
        BZ      ACTOK
        LBR     CONT2

ACTOK:  BQ      RESQ
        LBR     SETQ


RSFLAG: LDI     00H
        STR     RD
        LBR     CONT2

RESQ:   REQ
        LDI     01H
        STR     RD
        LBR     CONT2

SETQ:   SEQ
        LDI     01H
        STR     RD
        LBR     CONT2

EF2P:   REQ
        LBR     UNCZRO
        END
