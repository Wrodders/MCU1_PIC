;Written by Winston Rodrigo
;Student ID 10706715
;Program to Cycle 7seg Display 0-99
    processor 18F8722
    config OSC=HS, WDT=OFF, LVP=OFF
    radix decimal
    org 0x00
;----------Include----------------
    #include <p18f8722.inc>
;----------Pin Define--------------
;Q1 RH0	    PNP Active Low  LATH->OutputLevel
;Q2 RH1	    PNP Active Low  LATH->OutputLevel
;Q3 RA4	    NPN Active High LATA->OutputLevel
;Display Pattern RF0-7	    LATF->OutputLevel
;------------DelayVars-------------
var_100us_cnt	equ 0x19    ;
var_10ms_cnt	equ 0x20    ;
var_200ms_cnt	equ 0x21    ;
;------7 Seg BitMask deff--------------------
;7Seg Bit Pattern -> GFEDCdpAB
var_7seg_0  equ 0x01
    MOVLW   B'01111011'	    ;
    MOVWF   var_7seg_0	    ;Represents symbol 0
    COMF    var_7seg_0	    ;7seg is active low
var_7seg_1  equ	0x02	    ;
    MOVLW   B'00001010'	    ;
    MOVWF   var_7seg_1	    ;Represents symbol 1
    COMF    var_7seg_1	    ;
var_7seg_2  equ	0x03	    ;
    MOVLW   B'10110011'	    ;
    MOVWF   var_7seg_2	    ;Represents symbol 2
    COMF    var_7seg_2	    ;
var_7seg_3  equ	0x04	    ;
    MOVLW   B'10011011'	    ;Represents symbol 3
    MOVWF   var_7seg_3	    ;
    COMF    var_7seg_3	    ;
var_7seg_4  equ	0x05	    ;
    MOVLW   B'11001010'	    ;	
    MOVWF   var_7seg_4	    ;Represents sym 4
    COMF    var_7seg_4	    ;
var_7seg_5  equ	0x06	    ;
    MOVLW   B'11011001'	    ;
    MOVWF   var_7seg_5	    ;Rep sym 5
    COMF    var_7seg_5	    ;
var_7seg_6  equ	0x07	    ;
    MOVLW   B'11111001'	    ;
    MOVWF   var_7seg_6	    ;Rep sym 6
    COMF    var_7seg_6	    ;	
var_7seg_7  equ	0x08	    ;
    MOVLW   B'00001011'	    ;
    MOVWF   var_7seg_7	    ;Rep sym 7
    COMF    var_7seg_7	    ;
var_7seg_8  equ	0x09	    ;
    MOVLW   B'11111011'	    ;
    MOVWF   var_7seg_8	    ;Rep sym 8
    COMF    var_7seg_8	    ;
var_7seg_9  equ	0xA	    ;
    MOVLW   B'11001011'	    ;
    MOVWF   var_7seg_9	    ;Rep sym 9 
    COMF    var_7seg_9	    ;
;
;----------MAIN--------------
;Initilaize Pin Output Levels
    SETF    LATH	    ;Q1 Q2 PNP Init Off- Active Low
    CLRF    LATA	    ;Q3 NPN Init off- Active High
    CLRF    LATF	    ;Clear Display Bitmask
;Set Pin Directions 
    MOVLW   B'11111100'	    ;	
    MOVWF   TRISH	    ;Sets Q1 Q2 RH0 RH1 Output
    CLRF    TRISF	    ;Sets LEDs RF0-7 Output
    CLRF    TRISA	    ;Sets Q3 RA4 Output
;Init loop params-----------
var_U1_cnt  equ	0x15	    ;U1 Loop counter 10^0
var_U2_cnt  equ 0x16	    ;U2 Loop Counter 10^1
var_Led_cnt equ	0x17	    ;LED Loop counter 10^2
var_Led_msk equ	0x18	    ;Led Bit Mask

L_MAIN
;Set FSRs to point to start of 7seg table -> 0x01
    LFSR    0,0x01	    ;*FSR0L->0x01 == var_7seg_0
    LFSR    1,0x01	    ;*FSR1L->0x01 == var_7seg_0;
    CLRF    var_Led_msk	    ;Clear Led mask
    MOVLW   10		    ;7 Seg has sym range 0-9
    MOVWF   var_U1_cnt	    ;Set U1 loop count
    MOVWF   var_U2_cnt	    ;Set U1 loop count
    MOVWF   var_Led_cnt	    ;Set Led Loop Count
L_U1_INC    
    CALL    SUB_MUX_200ms   ;Multiplexes LATF with FSR0 FSR1 for 1000ms
;---Increment U1 U2 Led------    
    DECF    var_U1_cnt	    ;Decrement U1 Loop Counter
    BZ	    L_U2_INC	    ;Exit after 10 loops
    INCF    FSR0L	    ;Let FSR0L point to next address
    BRA	    L_U1_INC	    ;Loop Back to increment U1
L_U2_INC
    LFSR    0,0x01	    ;Reset FSR0L pointer
    MOVLW   10		    ;
    MOVWF   var_U1_cnt	    ;Reset U1 Loop Counter
    INCF    FSR1L	    ;Let FSR1L point to next symbol
    DECF    var_U2_cnt	    ;Decrement U2 loop counter
    BZ	    L_Led_INC	    ;Exit after 10 Loops == 10*10L_U1
    BRA	    L_U1_INC	    ;Loop Back to Increment U1
L_Led_INC
    MOVF    var_Led_msk,W   ;Test if 1st time incrementing
    BZ	      L_Led_1inc
    MOVF    var_Led_msk, W  ;Left Shift ledmask
    ADDWF   var_Led_msk	    ;Double == <<1
L_Led_rst    
    LFSR    0,0x01	    ;Reset FSR0L pointer
    LFSR    1,0x01	    ;Reset FSR1L pointer
    MOVLW   10		    ;
    MOVWF   var_U2_cnt	    ;Reset U2 symbo
    DECF    var_Led_cnt	    ;Decrement
    BZ	    L_MAIN	    ;Exit Loop after 10 loops
    BRA	    L_U1_INC	    ;Loop Back to increment U1
    
 L_Led_1inc
    BSF	    var_Led_msk,0   ;Set Bitmask to B'000000001'
    BRA	    L_Led_rst	    ;Loop Back in w/o left shifting mask
    
;----------SUBROUTINES------
SUB_MUX_10us
;Multiplexes RF-7 LATCH Values over Q1 Q2 Q3
    MOVLW   19
    MOVWF   var_100us_cnt    ;Delay = 28*13*0.4us = 98.8us
L_MUX_100us
    MOVF    INDF0,W	    ;Load value at address pointed by FSR0L
    MOVWF   LATF	    ;Set RF0-7 rep symbol at address pointed by FSR0L
    BCF	    LATH,0	    ;Turn ON Q1 RH0
    BSF	    LATH,0	    ;Turn OFF Q1
    MOVF    INDF1,W	    ;Load value at address pointed by FSR1L
    MOVWF   LATF	    ;Set RF0-7 rep symbol at address pointed by FSR1L
    BCF	    LATH,1	    ;Turn ON Q2 RH0
    BSF	    LATH,1	    ;Turn OFF Q2
    MOVF    var_Led_msk,W   ;Load led mask pattern
    MOVWF   LATF	    ;Set RF0-7 to rep led mask pattern
    BSF	    LATA,4	    ;Turn ON Q3 RA0
    BCF	    LATA,4	    ;Turn OFF Q3 RA0
    DECF    var_100us_cnt   ;
    BNZ	    L_MUX_100us	    ;Loop 35 times
    RETURN		    ;Exit Subroutine
SUB_MUX_10ms
    MOVLW   100
    MOVWF   var_10ms_cnt    ;Delay = 100*10us = 10ms
L_MUX_10ms
    CALL    SUB_MUX_10us    ;Delay by 10us
    DECF    var_10ms_cnt    ;
    BNZ	    L_MUX_10ms	    ;Loop 100 times
    RETURN		    ;EXIT Subroutine
SUB_MUX_200ms
    MOVLW   20		    ;
    MOVWF   var_200ms_cnt   ;Delay = 20*10ms = 200ms
L_MUX_200ms
    CALL    SUB_MUX_10ms    ;Delay by 10ms
    DECF    var_200ms_cnt   ;
    BNZ	    L_MUX_200ms	    ;Loop 10 times
    RETURN		    ; EXIT subroutine
end
    
    
    
	
	