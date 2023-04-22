;Student ID 10706715
;Lab3 Practice 
    processor 18F8722
    config OSC=HS, WDT=OFF, LVP=OFF
    radix decimal
    org 0x00

;Define SFR's
LATA	equ 0xF89		;RA3
TRISA	equ 0xF92		;
LATF	equ 0xF8E		;
TRISF	equ 0xF97		;
PORTB	equ 0xF81		; PB2 RB0
TRISB	equ 0xF93		;
PORTJ	equ 0xF88		; PB1 RJ5
TRISJ	equ 0xF9A		;
LATH	equ 0xF90		;
TRISH	equ 0xF99		;

ADCON1	equ 0xFC1		;
	MOVLW	D'15'		; Configure difital Input
	MOVWF	ADCON1		;
	
; Define Variables 
var_SW	equ 0x01		; Store Switches Values 
var_LM	equ 0x02		; Loop Multplier
	MOVLW	D'1'		;
	MOVWF	var_LM		; Set defult multiplier to 1
var_BCount   equ 0x400		; Loop Counter basic
var_Count40ms equ 0x401		; 40ms loop counter

 ;Initialize Pins
	BCF	TRISA,4		; Set Q3 as output
	BCF	LATA,4		; Turn Off Q3 NPN Active High
	SETF	TRISH		; Set Q1 Q2 output
	SETF	LATH		; Q1 Q2 PNP Active Low Ensure 7seg is off
	CLRF	TRISF		; Set displays to output
	CLRF	LATF		; Turn off LEDs	
	SETF	TRISB		;input PB2
	SETF	TRISJ		;input PB1

;Set up
	BSF	LATA,4		; TURN ON Q3
	CALL    SUB_CHECKPB2	; Block untill PB2 RJ5 pressed

L_MAIN		
	BTFSC	PORTJ,5		;Check if PB1 is pressed
	BRA	PASS		; return if pressed 
	CALL	SUB_LED400	;
PASS				;
	CALL	SUB_LED40	;    
	BRA	L_MAIN		; loop Forever 
	
	
	
;------ Delays ------
SUB_200us	
	MOVLW	D'71'		;Set loop 71 times
	MOVLB	4		;Set BSR to 4
	MOVWF	var_BCount,1	;Store 71 in 0x400 using BSR
L1 
	NOP			;
	NOP			;
	NOP			;
	NOP			;
	DECF	var_BCount,1	;
	BNZ	L1		;
	RETURN			; Exit after 71 Loops 6*0.4*71 +4*0.4
	
SUB_40ms
	MOVLB	4		;
	MOVLW	D'200'		;
	MOVWF	var_Count40ms,1	;Set loop counter to 200 in 0x401
L2				;
	CALL	SUB_200us	; Delay 200us
	DECF	var_Count40ms,1	;
	BNZ	L2		; loop 200 * 200us = 40ms
	RETURN			; exit

SUB_400ms    
	MOVLW	D'10'		;
	MOVWF	var_LM		;
L3				;
	CALL	SUB_40ms	;
	DECF	var_LM		;   
	BNZ	L3		;
	RETURN			;

;------LEDs--------	
SUB_LED40
	BSF	LATF,0		;TURN ON
	CALL	SUB_40ms	;
	BCF	LATF,0		;TURN OFF
	CALL	SUB_40ms	;    
	RETURN			;
	
SUB_LED400
L_M2				;
	BSF	LATF,0		; TURN ON
	CALL	SUB_400ms	;
	BCF	LATF,0		; TURN OFF
	CALL	SUB_400ms	;
	BRA	L_M2		; Loop forever 
	
SUB_CHECKPB2			; Start Sequence signal
L4
	BTFSC	PORTB,0		; Check PB2 RJ5 
	BRA	L4		; BLOCKING LOOP
	RETURN			; exit 
;---------------------
	end
