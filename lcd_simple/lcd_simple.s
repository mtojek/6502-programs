PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  ldx #$ff
  txs

  ; Init: define output pins
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Function set: set 8-bit mode, 2-line display; 5x8 font
  jsr lcd_instruction

  lda #%00001110 ; Display on/off: display on, cursor on, blink off
  jsr lcd_instruction  

  lda #%00000110 ; Increment and shift cursor, don't shift display
  jsr lcd_instruction

  ; Send characters
  lda #"H"       ; Write data to DDRAM
  jsr print_char
  
  lda #"e"       ; Write data to DDRAM
  jsr print_char  

  lda #"l"       ; Write data to DDRAM
  jsr print_char
  
  lda #"l"       ; Write data to DDRAMA
  jsr print_char

  lda #"o"       ; Write data to DDRAM
  jsr print_char 

loop:
  jmp loop

lcd_instruction:
  pha

  sta PORTB

  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send an instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA

  pla
  rts

print_char:
  sta PORTB

  lda #RS        ; Clear RW/E bits
  sta PORTA
  lda #(RS | E)  ; Set RS | E bit to send an instruction
  sta PORTA
  lda #RS        ; Clear RW/E bits
  sta PORTA
  rts

  .org $fffc
  .word reset
  .word $0000
