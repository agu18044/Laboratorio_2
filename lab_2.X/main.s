; Archivo:     main.S
; Dispositivo: PIC16F887
; Autor:       Diego Aguilar
; Compilador:  pic-as (v2.30), MBPLABX v5.40
;
; Programa:    contador 
; Hardware:    LEDs 
;
; Creado: 3 agosto, 2021
; Última modificación: 3 agosto, 2021

PROCESSOR 16F887
 #include <xc.inc>
 
;configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT  // Oscilador interno sin salidas
    CONFIG WDTE=OFF  // WDT disabled (reinicio repetitivo del pic)
    CONFIG PWRTE=ON  // PWRT enabled (espera de 72ms al iniciar)
    CONFIG MCLRE=OFF // El pin MCLR se utiliza como I/0
    CONFIG CP=OFF    // Sin proteccion de codigo
    CONFIG CPD=OFF   // Sin proteccion de datos
    
    CONFIG BOREN=OFF // Sin reinicio cuando el voltaje de alimentacion baja de 4V
    CONFIG IESO=OFF  // Reinicio sin cambio de reloj de interno a externo
    CONFIG FCMEN=OFF // Cambio de reloj externo a interno en caso de fallo
    CONFIG LVP=ON    // Programacion en bajo voltaje permitida
    
;configuration word 2
    CONFIG WRT=OFF   // Proteccion de autoescritura por el programa desactivada
    CONFIG BOR4V=BOR40V  // Reinicio abajo de 4V, (BOR21V=2.1V)
    
PSECT udata_bank0  ;common memory
    cont_small: DS 1 ;1 byte
    cont_big:   DS 1

PSECT resVect, class=CODE, abs, delta=2
;-----------vector reset--------------;
ORG 00h     ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main
 
PSECT code, delta=2, abs
ORG 100h    ; posicion para le codigo
 
 ;-----------configuracion--------------;

main:
    call    config_io

loop:
    btfsc   PORTA, 0  
    call    inc_portb
    call    delay_small
    
    btfsc   PORTA, 1
    call    dec_portb
    call    delay_small
    
    btfsc   PORTA, 2
    call    inc_portc
    call    delay_small
    
    btfsc   PORTA, 3
    call    dec_portc
    call    delay_small
    
    btfsc   PORTA, 4
    call    suma
    call    delay_small
    
    btfsc   PORTD, 4
    bsf	    PORTE, 0
    
    btfss   PORTD,4
    bcf	    PORTE, 0
    
    
    goto    loop

inc_portb:
    btfsc   PORTA, 0
    goto    $-1
    incf    PORTB
    btfsc   PORTB, 4
    clrf    PORTB
    return

dec_portb:
    movlw   00001111B
    btfsc   PORTA, 1
    goto    $-1
    decfsz  PORTB
    btfsc   PORTB, 7 
    movwf   PORTB
    return
    
inc_portc:
    btfsc   PORTA, 2
    goto    $-1
    incf    PORTC
    btfsc   PORTC, 4
    clrf    PORTC
    return

dec_portc:
    movlw   00001111B
    btfsc   PORTA, 3
    goto    $-1
    decfsz  PORTC
    btfsc   PORTC, 7 
    movwf   PORTC
    return

suma:
    btfsc   PORTA, 4       ;Ubicacion  del pushbutton
    goto    $-1            ;
    movf    PORTB, 0       ;Se selecciona el valor inicial
    addwf   PORTC, 0       ;Valor que se va a sumar
    movwf   PORTD          ;Asigna valor a los leds de salida del puerto D
    return

       
config_io:
    ; Configuracion de los puertos
    banksel ANSEL	; Se selecciona bank 3
    clrf    ANSEL	; Definir puertos digitales
    clrf    ANSELH
    
    bsf	    STATUS, 5  ; banco 01
    bcf	    STATUS, 6
    bsf     TRISA, 0    ; se establecen como inputs para los pushbuttons
    bsf     TRISA, 1
    bsf     TRISA, 2
    bsf     TRISA, 3
    bsf     TRISA, 4
    clrf    TRISB
    clrf    TRISC
    clrf    TRISD
    clrf    TRISE
  
    bcf	    STATUS, 5  ; banco 00
    bcf	    STATUS, 6
    clrf    PORTB
    clrf    PORTA
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    return
 
delay_big:         
   movlw    50		; valor inciial del contador
   movwf   cont_big
   call    delay_small  ; rutina de delay
   decfsz  cont_big, 1  ; decrementar el contador
   goto    $-2          ; ejecutar dos lineas atras
   return
 
delay_small:         
   movlw    150		 ; valor incial del contador
   movwf   cont_small
   decfsz  cont_small, 1 ; decrementar el contador
   goto    $-1           ; ejecutar linea anterior
   return