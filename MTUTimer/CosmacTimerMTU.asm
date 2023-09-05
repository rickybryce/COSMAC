; CLOCK PROGRAM FOR COSMAC MICROCONTROLLER TRAINING UNIT
; EF1 STARTS AND PAUSES THE TIMER
; EF2 RESETS THE TIMER
; COMPILED WITH A18 ASSEMBLER
; IN DEBIAN LINUX, I CREATED THE FOLLOWING SCRIPT
; NAMED ASM18

; #!/bin/bash
;./a18 $1.asm -l $1.lst -o $1.hex

; THEN MAKE IT EXECUTABLE chmod +x ASM18
; TO COMPILE:  ./ASM18 FILENAME


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


    ORG    8000H
R0    EQU    0  ; PROGRAM COUNTER
R1    EQU    1
R2    EQU    2
R3    EQU    3
R4    EQU    4  ; SEGMENT
R5    EQU    5
R6    EQU    6  ; BUFFER WORKSPACE
R7    EQU    7  ; DELAY
R8    EQU    8  ; LOOP COUNT FOR DIGIT SCAN
R9    EQU    9  ; VALUES
RA    EQU    10 ; BUFFERS
RB    EQU    11 ; SCAN DIGIT
RC    EQU    12 ; INDIRECT REGISTER
RD    EQU    13 ; EFLAGS
RE    EQU    14 ; GPIO
RF    EQU    15 ; FREERUN

INIT:  LOAD    R3, DELAY     ; INITIALIZE REGISTERS
        LOAD    R4, SEGMENT     ; INDIVIDUAL SEGMENTS OF DIGIT
        LOAD    R5, DIGIT       ; TURN ON DIGIT
        LOAD    RF, FREERUN     ; DELAY LOOP (FREE RUNNING)
        LDI     00H             ; LOAD ZERO TO ACCUMULATOR
        STR     RF              ; CLEAR FREERUN
        LOAD    RE, GPIO1       ; RE WILL BE FORGPIO
        LDI     00H             ; RELOAD ZERO TO ACCUMULATOR
        LOAD    RD, EFLAGS      ; RD WILL BE FOR EFLAGS
        LDI     00H             ; RELOAD ZERO TO ACCUMULATOR
        STR     RD              ; CLEAR EFLAGS
        LOAD    RC, HUNDREDTHS  ; RC BECOMES HUNDREDTHS MEMORY
        LDI     00H             ; RELOAD ZERO
        STR     RC              ; CLEAR HUNDREDTHS
        LOAD    RC, TENTHS      ; NOW, RC BECOMES TENTHS
        LDI     00H             ; RELOAD ZERO
        STR     RC              ; CLEAR TENTHS
        LOAD    RC, ONES        ; NOW LOAD RC WITH ONES
        LDI     00H             ; RELOAD ZERO
        STR     RC              ; CLEAR ONES
        LOAD    RC, TENS        ; RC BECOMES TENS
        LDI     00H             ; RELOAD ZERO
        STR     RC              ; CLEAR TENS
        LOAD    RC, HUNDREDS    ; RC BECOMES HUNDREDS
        LDI     00H             ; RELOAD ZERO
        STR     RC              ; CLEAR HUNDREDS
        LOAD    RC, THOUSANDS   ; FINALLY RC=THOUSANDS MEMORY
        LDI     00H             ; RELOAD ZERO
        STR     RC              ; CLEAR THOUSANDS
        REQ                     ; SHUT OFF Q OUTPUT (RESET)

MAIN:   LOAD    RA, BUFFER5     ; RA BECOMES BUFFERS MEMORY
        LOAD    R9, VALUES      ; R9 BECOMES VALUES MEMORY
        LBR     CHKEF1          ; CHECK EF BUTTONS
CONT2:  BNQ     CONT            ; IF Q IS NOT SET, CONTINUE
        SEX     RF              ; SET INDEX REGISTER TO FREE RUN
        LDI     01H             ; LOAD ACCUMULATOR WITH 1
        ADD                     ; ADD 1 TO FREERUN
        STR     RF              ; UPDATE FREERUN
        XRI     1FH             ; CALIBRATE TIME
        LBZ     COUNT           ; IF TIME IS REACHED, THEN COUNT
CONT:   LOAD    RB, SCAN_DIGIT  ; OUTPUT TO TURN ON DIGITS
        LDI     6               ; WE HAVE 6 DIGITS
        PLO     R8      ; LOOP COUNT
LOOP:   LDN     RB      ; GET DIGIT CONTROL
        XRI     0FFH    ; COMPLEMENT IT (ACTIVE LOW)
        STR     R5      ; WRITE TO DIGIT
        LDN     RA      ; GET BYTE FROM BUFFER
        STR     R4      ; WRITE TO SEGMENT
        SEP     R3      ; DELAY
        LDI     0       ; TURN OFF DISPLAY
        STR     R4      ; ZERO SEGMENT
        INC     RA      ; INCREMENT BUFFER
        INC     RB      ; INCREMENT DIGIT
        DEC     R8      ; DECREMENT LOOP COUNT
        GLO     R8      ; GET THE LOOP NUMBER
        BNZ     LOOP    ; CONTINUE UNTIL 6 DIGITS
        BR      MAIN    ; GO TO MAIN ROUTINE


RET_DELAY: SEP  R0      ; EXIT SUBROUTINE SET PC BACK TO R0
DELAY:  LDI     1       ; LOAD 1 TO ACC
        PLO     R7      ; PLACE 1 INTO R7
DELAY1: DEC     R7      ; DECREMENT R7
        GLO     R7      ; GET R7 AGAIN
        BNZ     DELAY1  ; CONTINUE UNTIL R7=0
        BR      RET_DELAY ; EXIT SUBROUTINE


BUFFER5:     DB 0BDH ; ZERO THOUSANDS
BUFFER4:     DB 0BDH ; ZERO HUNDREDS
BUFFER3:     DB 0BDH ; ZERO TENS
BUFFER2:     DB 0BDH ; ZERO ONES
BUFFER1:     DB 0BDH ; ZERO TENTHS
BUFFER0:     DB 0BDH ; ZERO HUNDREDTHS
SCAN_DIGIT: DB 20H, 10H, 8, 4, 2, 1 ; BIT NUMBERS TO TURN ON EACH DISPLAY
                ; VALUES THAT REPRESENT NUMBERS
VALUES:     DB 0BDH, 030H, 09BH, 0BAH, 036H, 0AEH, 0AFH, 038H, 0BFH, 03EH


LIHNTH: LBR     IHNTH

ZERO:   BN2     LIHNTH
UNCZRO: LOAD    RC, HUNDREDTHS  ; LOAD RC WITH HUNDREDS
        LDI     00H             ; LOAD ZERO TO ACC
        STR     RC              ; ZERO HUNDREDTHS
        LOAD    RC, TENTHS      ; LOAD RC WITH TENTHS
        LDI     00H             ; ZERO ACC
        STR     RC              ; RESET TENTHS
        LOAD    RC, ONES        ; LOAD RC WITH ONES
        LDI     00H             ; ZERO ACC
        STR     RC              ; RESET ONES
        LOAD    RC, TENS        ; LOAD RC WITH TENS
        LDI     00H             ; ZERO ACC
        STR     RC              ; RESET TENS
        LOAD    RC, HUNDREDS    ; LOAD RC WITH HUNDREDS
        LDI     00H             ; ZERO ACC
        STR     RC              ; SERO HUNDREDS
        LOAD    RC, THOUSANDS   ; LOAD RC WITH THOUSANDS
        LDI     00H             ; LOAD ZERO TO ACC
        STR     RC              ; ZERO THOUSANDS
        LBR     UPDB            ; UPDATE

COUNT:  LDI     00H             ; LOAD ZERO TO ACCUMULATOR
        STR     RF              ; ZERO FREERUN
IHNTH:  LOAD    RC, HUNDREDTHS  ; RC BECOMES HUNDREDTHS
        SEX     RC              ; SET INDEX REGISTER TO RC
        LDI     02H             ; LOAD 02H (TOO SLOW FOR 01)
                                ; SO WE ONLY COUNT BY 2
        ADD                     ;INCREMENT TIMER
        STR     RC      ;HUNDREDTHS NOW CONTAINS THE HUNDREDTHS VALUE
        LDN     RC              ; LOAD HUNDREDTHS
        XRI     0AH             ; SEE IF IT'S REACHED 0A
        LBZ     ITNTH           ; IF SO, INC TENTHS, RESET HUNDREDTHS
        LBR     UPDB            ; IF NOT, UPDATE THE DISPLAY

ITNTH:  LOAD    RC, HUNDREDTHS  ; RELOAD RC WITH HUNDREDTHS
        LDI     0H              ; LOAD ZERO TO ACC
        STR     RC              ; ZERO HUNDREDTHS
        LOAD    RC, TENTHS      ; RELOAD RC WITH TENTHS
        SEX     RC              ; SET THE INDEX REGISTER TO RC
        LDI     01H             ; LOAD 1 TO THE ACCUMULATOR
        ADD                     ; ADD 1 TO TENTHS
        STR     RC      ;RC NOW CONTAINS THE TENTHS VALUES
        LDN     RC              ; RELOAD RC
        XRI     0AH             ; CHECK IT FOR 0AH
        LBZ     IONES           ; IF SO, THEN RESET TENTHS, INC ONES
        LBR     UPDB            ; OTHERWISE UPDATE

IONES:  LOAD    RC, TENTHS      ; LOAD RC WITH TENTHS
        LDI     0H              ; ZERO ACCUMULATOR
        STR     RC              ;CLEAR TENTHS
        LOAD    RC, ONES        ; RELOAD RC WITH ONES
        SEX     RC              ; SET RC AS THE INDEX REGISTER
        LDI     01H             ; LOAD 01H TO ACC
        ADD                     ; ADD 1 TO ONES
        STR     RC      ;RC NOW CONTAINS THE ONES VALUES
        LDN     RC              ; RELOAD ONES
        XRI     0AH             ; SEE IF IT'S REACHED 0AH
        LBZ     ITENS           ; IF SO, THEN RESET ONES, INCREMENT TENS
        LBR     UPDB            ; OTHERWISE, UPDATE

ITENS:  LOAD    RC, ONES        ; LOAD RC WITH ONES
        LDI     0H              ; ZERO ACC
        STR     RC              ;ONES ARE NOW ZERO
        LOAD    RC, TENS        ; RELOAD RC WITH TENS
        SEX     RC              ; SET RC AS THE INDEX REGISTER
        LDI     01H             ; LOAD 1 TO ACCUMULATOR
        ADD                     ; ADD ONE TO TENS
        STR     RC              ; STORE INCREMENTED VALUE TO TENS
        LDN     RC              ; RLOAD RC
        XRI     0AH             ; CHECK TO SEE IF IT'S REACHED A
        LBZ     IHUN            ; IF SO, RESET TENS, INCREMENT HUNDREDS
        LBR     UPDB            ; OTHERWISE, UPDATE

IHUN:   LOAD    RC, TENS        ; LOAD RC WITH TENS
        LDI     0H              ; ZERO ACC
        STR     RC              ; TENS NOW CONTAINS A ZERO
        LOAD    RC, HUNDREDS    ; SET RC TO HUNDREDS
        SEX     RC              ; SET THE INDEX REGISTER TO RC
        LDI     01H             ; LOAD 1 TO ACC
        ADD                     ; ADD 1 TO HUNDREDS
        STR     RC              ; HUNDREDS NOW HAVE THE INCREMENTED VALUE
        LDN     RC              ; RELOAD HUNDREDS
        XRI     0AH             ; SEE IF IT'S REACHED A
        LBZ     ITHOU           ; IF SO, RESET HUNDREDS, INCREMENT THOUSANDS
        LBR     UPDB            ; OTHERWISE, UPDATE

ITHOU:  LOAD    RC, HUNDREDS    ; LOAD RC WITH HUNDREDS
        LDI     0H              ; LOAD ZERO TO ACC
        STR     RC              ; STORE ZERO TO HUNDREDS
        LOAD    RC, THOUSANDS   ; RC BECOMES THOUSANDS
        SEX     RC              ; SET INDEX REGISTER TO RC
        LDI     01H             ; LOAD 1 TO ACC
        ADD                     ; INCREMENT THOUSANDS
        STR     RC              ; THOUSANDS NOW CONTAIN INCREMENTED VALUE
        LDN     RC              ; RELOAD THOUSANDS
        XRI     0AH             ; CHECK TO SEE IF IT'S REACHED A
        LBZ     UNCZRO          ; IF SO, RESTART TIMER
        LBR     UPDB            ; OTHERWISE UPDATE

CONT1:  LBR     CONT            ; CONTINUE (SHORT TO LONG BRANCH ADAPTER)


UPDB:   NOP     ; UPDATE LOGIC
UHNTH:  LOAD    R9, VALUES      ; R9 IS VALUES
        LOAD    RC, HUNDREDTHS  ; START RC WITH HUNDREDTHS
        SEX     RC              ; INDEX REGISTER WILL BE RC
        GLO     R9              ; GET THE LOW BYTE
        ADD                     ; ADD LOW BYTE TO GET BIT PATTERN
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR HUNDREDTHS
        LOAD    R6, BUFFER0     ; R6 BECOMES BUFFER ZERO
        LDN     R9              ; LOAD VALUE OF HUNDREDTHS
        STR     R6              ; STORE TO R6 (BUFFER0 WORKSPACE)

UTNTHS: LOAD    R9, VALUES      ; R9 IS VALUES
        LOAD    RC, TENTHS      ; RC IS NOW TENTHS
        SEX     RC              ; SET THE INDEX REGISTER TO RC
        GLO     R9              ; GET THE BITT PATTERN ADDRESS
        ADD                     ; FIND THE RIGHT BITT PATTERN
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR TENTHS
        LOAD    R6, BUFFER1     ; R6 BECOMES BUFFER 1
        LDN     R9              ; LOAD THE BIT PATTERN TO MEMORY
        STR     R6              ; STORE THIS TO BUFFER1


UONES:  LOAD    R9, VALUES      ; BE SURE R9 IS CODED VALUES
        LOAD    RC, ONES        ; RC BECOMES ONES
        SEX     RC              ; SET THE INDEX REGISTER TO RC
        GLO     R9              ; GET STARTING VALUE CODE FROM FROM R9
        ADD                     ; FIND THE BIT PATTERN TO DISPLAY
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR ONES
        LOAD    R6, BUFFER2     ; R6 BECOMES BUFFER2
        LDN     R9              ; LOAD THE BIT PATTERN FOR THE VALUE
        STR     R6              ; STORE THIS TO BUFFER2
        STR     RE              ; STORE THE PATTERN TO GPIO

UTENS:  LOAD    R9, VALUES      ; RELOAD R9 WITH VALUES
        LOAD    RC, TENS        ; RC WILL BECOME TENS
        SEX     RC              ; CHANGE THE INDEX REGISTER TO RC
        GLO     R9              ; GET THE LOW VALUE FROM R9
        ADD                     ; FIND THE BIT PATTERN TO DISPLAY
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR TENS
        LOAD    R6, BUFFER3     ; R6 BECOMES BUFFER 3
        LDN     R9              ; LOAD THE BIT PATTERN FROM VALUES
        STR     R6              ; STORE THIS TO BUFFER3

UHNDRD: LOAD    R9, VALUES      ; R9 BECOMES VALUES
        LOAD    RC, HUNDREDS    ; RC BECOMES HUDREDS
        SEX     RC              ; CHANGE THE INDEX REGISTER TO RC
        GLO     R9              ; GET THE LOW BYTE OF VALUES
        ADD                     ; FIND THE BIT PATTERN TO DISPLAY
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR HUNDREDS
        LOAD    R6, BUFFER4     ; R6 BECOMES BUFFER4
        LDN     R9              ; LOAD THE BIT PATTERN
        STR     R6              ; STORE THIS TO BUFFER4

UTHOU:  LOAD    R9, VALUES      ; LOAD R9 WITH START OF BIT PATTERNS
        LOAD    RC, THOUSANDS   ; RC BECOMES THOUSANDS
        SEX     RC              ; RC BECOMES INDEX REGISTER
        GLO     R9              ; GET THE STARTING ADDRESS OF VALUES
        ADD                     ; FIND THE BIT PATTERN WE NEED
        PLO     R9  ;R9 NOW SET TO WHERE WE NEED DATA FOR THOUSANDS
        LOAD    R6, BUFFER5     ; R6 NOW BECOMES BUFFER5
        LDN     R9              ; LOAD THE BIT PATTERN WE NEED
        STR     R6              ; STORE THIS TO BUFFER5


CHKEF1: B2      EF2P    ; IF 2 IS PRESSED, SHUT OFF Q, AND RESET
        BN1     RSFLAG  ; IF 1 IS NOT PRESSED, RESET FLAGS
        LDN     RD      ; LOAD EFLAGS
        BZ      ACTOK   ; IF IT'S ZERO, THEN OK TO ACT (ONESHOT)
        LBR     CONT2   ; CONTINUE

ACTOK:  BQ      RESQ    ; IF Q IS ON, RESET Q
        LBR     SETQ    ; OTHERWISE TURN ON Q


RSFLAG: LDI     00H     ; LOAD 0 TO ACCUMULATOR
        STR     RD      ; RESET EFLAGS
        LBR     CONT2   ; CONTINUE

RESQ:   REQ             ; SHUT OFF Q
        LDI     01H     ; LOAD 1 TO ACCUMULATOR
        STR     RD      ; SET EFLAGS
        LBR     CONT2   ; CONTINUE

SETQ:   SEQ             ; TURN ON Q
        LDI     01H     ; LOAD 1 TO ACCUMULATOR
        STR     RD      ; SET EFLAGS
        LBR     CONT2   ; JUMP TO CONT2

EF2P:   REQ             ; SHUT OFF Q
        LBR     UNCZRO  ; JUMP TO UNCONDITIONAL ZERO
        END
