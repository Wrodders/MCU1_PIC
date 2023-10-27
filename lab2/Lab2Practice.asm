; Program Demonstrating Lab 2 Practive Functionality
; Written by Winston Scott
; Student ID: 10706715
    
; Advanced Example 
; When pressing PB1, show the letter ‘U’ on the left-hand 7-segment display.
; Simultaneously, treat the right-most 3 switches as a 3-bit unsigned number.  
; Extend this number to be an 8-bit unsigned number, 
; and show the result on the LEDs LD1-8.
; Simultaneously, use the left-most 4 switches as a 4-bit twos complement.
; Store this number in a memory location in Bank 1.
; If number is > than 5,show the number ‘6’ on the right-hand 7-segment display, 
; otherwise this display should be blank.
    
    processor 18F8722
    config OSC=HS, WDT=OFF, LVP=OFF
    radix decimal
    org 0x00

; Define SFRs
LATA	equ 0xF89	    ; Q3 NPN Active High
TRISA	equ 0xF92	    ;
PORTA	equ 0XF80	    ;
			    ;
LATB	equ 0xF8A	    ; 
TRISB	equ 0xF93	    ;
PORTB	equ 0xF81	    ; PB2 RB0 Pressed -> High
			    ;
LATC	equ 0xF8B	    ; 
TRISC	equ 0xF94	    ;
PORTC	equ 0xF82	    ; 4 LSB SW 
			    ;
LATF	equ 0xF8E	    ; U1/U2/LED Display Pattern 
TRISF	equ 0xF97	    ; 
PORTF	equ 0xF85	    ;  
			    ;
LATH	equ 0xF90	    ; Q1 RH0 Q2 RH1 PNP Active High
TRISH	equ 0xF99	    ;
PORTH	equ 0xF87	    ; 4 MSB SW
			    ;
LATJ	equ 0xF91	    ;
TRISJ	equ 0xF9A	    ;
PORTJ	equ 0xF88	    ; PB1 RJ5 Pressed -> High
			    ;	
ADCON1 equ 0xFC1	    ; Digital Input Configuration 
			    ;
;GFEDCdpBA
cnst_7seg_U equ 0x02	    ;
    MOVLW   B'01111010'	    ; U Mask
    MOVWF   cnst_7seg_U	    ; Store in 0x02
    COMF    cnst_7seg_U	    ;7 Seg Actve Low
cnst_7seg_6 equ 0x03	    ; 
    MOVLW   B'11111001'	    ; 6 Mask
    MOVWF   cnst_7seg_6	    ; Store in oxo3
    COMF    cnst_7seg_6	    ;    
cnst_7seg_NULL equ 0x04	    ;
    SETF cnst_7seg_NULL	    ; Blank Display Mask
var_SW_LSB  equ 0x05	    ; Variable SW1 LSB Values
    CLRF    0x05	    ; Init to 0
var_SW_MSB  equ 0x06	    ;
    MOVLB   1		    ; Select Bank 1
    CLRF    0x06,1	    ; Init to 0
    MOVLB   0		    ; Reset BankSel to Bank 0
  
; Init PORT F LED Display
    CLRF    TRISF		;Set Port F as Output
    CLRF    LATF		;Set Port F Low 

; INIT PORT H Q1 Q2 SW 7-4
    MOVLW   B'00000011'		; Q1 Q2 PNP Active Low
    MOVWF   LATH		; Turn OFF Q1 Q2 NEED TO TUR OFF BEFORE SWITCH
    MOVLW   D'15'		;
    MOVWF   ADCON1		; Sets Dual Input Pins as Digital 
    MOVLW   B'11111100'		; Q1 Q2 RH0 RH1 
    MOVWF   TRISH		; 
; INIT PORT A Q3
    BCF	    TRISA,4		; Q3 Output
    BCF	    LATA,4		; Q3  NPN Active High 
; INIT PORT C SW 3-0
    SETF    TRISC,1		;Set Port C as Input
; INIT PORT J	PB1 Active High
    BSF	    TRISJ,5		;Set RJ5 as input
;MAIN FUNCTION 
MAIN
   ;Read SW1 LSB as uint3 and extend to uint8
   MOVF	    PORTC,W		; Load LSB Switch vals
   ANDLW    B'00011100'		; Mask C4-C2
   MOVWF    var_SW_LSB		; Store LSB uint3 0x05 
   RRNCF    var_SW_LSB,f	; var -> 0000 1110 
   RRNCF    var_SW_LSB,f	; var -> 0000 0111
   ;Read  SW1 MSB as 2's comp and store in Bank
   MOVF	    PORTH,W		;Load HSB Switch Vals
   ANDLW    B'11110000'		;Mask RH7-4
   ;Extend to 2's comp int4
   MOVLB    1			;Selet Bank 1
   MOVWF    var_SW_MSB,1	;Store at 0x06 of Bank 1 = 0x106 
   SWAPF    var_SW_MSB,f,1	;Val Mask  -> 0000 1111
   ;Check if > 5
   MOVF	    var_SW_MSB,W,1	;Load value in 0x106 to Wreg
   BTFSS    var_SW_MSB,3,1	;Skip Next line if val is -ve using Bank 1
   CALL	    SUB_CHECK_5		;Displays 6 on U1 if val > 5
   ;Check if Pb1 Pressed 
   BTFSS    PORTJ,5		;PB1 RJ5 Presser ->
   CALL	    SUB_PB1		;Display U on U1 if PB1 High
   CALL	    SUB_LED		;Display SW LSB uint3 as uint8 on LEDs
				;
   BRA	    MAIN		;Loop Forever
  
   
;---- SUB ROUTINES -----   
SUB_CHECK_5	;Checks if number is >5
   SUBLW    5			; 5 - Wreg(var_SW_MSB)
   BNN	   PASS			; Skip next if WREG >=5
   CALL	    SUB_SW6		; Display 6 on U1
PASS				; 
   RETURN			;
 
SUB_PB1		;Displays U on U2
    CALL SUB_CLR_DISPLAY	;Clear Displays and Pins
    MOVF    cnst_7seg_U,W	;Load U Mask
    MOVWF LATF			;
    BCF	LATH,1			;TURN ON Q1 RH1
    NOP				;
    BSF	LATH,1			;TURN OFF
    RETURN			; (5+SUB_CLR)*0.4us = 3.2us
    
SUB_SW6		;Displays 6 on U1
    CALL SUB_CLR_DISPLAY	;Clear Displays and Pins    
    MOVF    cnst_7seg_6,W	;Load 6 Mask
    MOVWF   LATF		;
    BCF	    LATH,0		;TURN ON Q0 RH0
    NOP				;
    BSF	    LATH,0		;TURN OFF
    RETURN			;
    
SUB_LED		;Displays 3 bit on Leds
    CALL SUB_CLR_DISPLAY	;Clear Displays and Pins
    MOVF    var_SW_LSB,W	;Loads MSB 3bit 
    MOVWF   LATF		;
    BSF	    LATA,4		;TURN ON Q3
    NOP				;
    BCF	    LATA,4		;TURN OFF
    RETURN			;
    
SUB_CLR_DISPLAY    
    SETF    LATH		;TURN OFF Q1 Q2
    BCF	    LATA,4		;TURN OFF Q3
    CLRF    LATF		;Clear Displays
    RETURN			;
;-------------------
    end 
