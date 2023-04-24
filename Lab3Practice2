;Student ID 10706715
;Lab3 Practice 
    processor 18F8722
    config OSC=HS, WDT=OFF, LVP=OFF
    radix decimal
    org 0x00
    
;-------------SFR's----------------    
LATA	equ 0xF89	; Q3 NPN RA4
TRISA	equ 0xF92	;

LATF	equ 0xF8E	;
TRISF	equ 0xF97	;
	
PORTC	equ 0xF82	; RC2
TRISC	equ 0xF94	;
	
PORTB	equ 0xF81	; RB0 active low
TRISB	equ 0xF93	;

LATH	equ 0xF90	;Q1 Q2
TRISH	equ 0xF99	; 
ADCON	equ 0xFC1	;
;-----Define vars-----------------
var_count330us  equ 0x101   ; Basic loop counter
var_count50ms	equ 0x04    ; 50m counte
var_incLed	equ 0x05    ;

;---Set up pins------------------ 
    MOVLW    D'15'	;
    MOVWF    ADCON	; Set inputs 
    BCF	    TRISA,4	; set q3 output 
    BCF	    LATA,4	; turn off q3
    CLRF    TRISH	;
    BSF	    LATH,0	; Turn of Q1
    BSF	    LATH,1	; Turn off Q2
    CLRF    TRISF	; Set leds as output
    CLRF    LATF	; Turn off all leds
   
    
;------Init--------------------------
    CLRF    var_incLed		;reset to 0
    BSF	    LATA,4		;Turn on Q3 LEDs
    CALL    SUB_CheckSW		; Hold untill SW0 pressed
L_MAIN	

    CALL    SUB_50ms		; Delay 50ms
    CALL    SUB_IncLed		; increment Led 1 value
    CALL    SUB_CheckDone	; Pass if not done
    CALL    SUB_CheckPB		; Hold if pb2 pressed
    BRA	    L_MAIN		;
    
    
SUB_IncLed			;Increment Led value
    MOVF    var_incLed,w	; load current led index value
    INCF    var_incLed		;
    MOVFF   var_incLed,LATF	;
    RETURN			;Exit 
    
SUB_CheckDone			; Hold if Counter = 255
    MOVLW   D'255'		;	
    CPFSLT  var_incLed		;
    CALL    SUB_HOLD		;
    RETURN			;
    
SUB_HOLD			; Block forever
L3				;
    BRA L3			;Loop forever
    RETURN			;never exit
  
;-----SubRoutines---------------
SUB_CheckSW			;Block untill SW[0] On
L4				;
    BTFSS   PORTC,2		; RC2 Active high
    BRA	    L4			; Block untill pressed
    RETURN			;
    
SUB_CheckPB			;Block while Pb2  pressed
L5				;
    BTFSS   PORTB,0		;RB0 Active Low
    BRA	    L5			;Hold when Pressed 
    RETURN			; exit

    
    ;---Delays----------------------------   
SUB_330us	
    MOVLB   D'1'		; Set BSR
    MOVLW   D'103'		;
    MOVWF   var_count330us,1    ;
L1				;
    NOP				;
    NOP				;
    NOP				;    
    NOP				;
    NOP				;
    DECF    var_count330us,1    ;
    BNZ	    L1			;Loop 103*7*0.4 +3*0.4 = 
    RETURN			;exit
    
SUB_50ms
    MOVLW   D'151'		;
    MOVWF   var_count50ms	;
L2				;
    CALL    SUB_330us		;	
    DECF    var_count50ms	;
    BNZ	    L2			;
    RETURN			;

;-------------
    end
