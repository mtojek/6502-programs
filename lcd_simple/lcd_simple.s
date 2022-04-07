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

  ; Init: wait for LCD power
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop

  ; Init: next instructions
  lda #%00110000 ; Function set 3x
  jsr lcd_instruction
  jsr lcd_instruction
  jsr lcd_instruction

  lda #%00111000 ; Function set: set 8-bit mode, 2-line display; 5x8 font
  jsr lcd_instruction

  lda #%00001110 ; Display on/off: display on, cursor on, blink off
  jsr lcd_instruction

  lda #%00000001 ; Clear display
  jsr lcd_instruction

  lda #%00000110 ; Set entry mode: increment and shift cursor, don't shift display
  jsr lcd_instruction

  ; Send characters
  ldx #0
send_characters:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp send_characters

loop:
  jmp loop

message: .asciiz "github.com/mtojek"

lcd_wait:
  pha
  lda #%00000000 ; Port B is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB

  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111 ; Port B is output
  sta DDRB
  
  pla
  rts

lcd_instruction:
  pha

  jsr lcd_wait

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
  pha

  sta PORTB

  lda #RS        ; Clear RW/E bits
  sta PORTA
  lda #(RS | E)  ; Set RS | E bit to send an instruction
  sta PORTA
  lda #RS        ; Clear RW/E bits
  sta PORTA

  pla
  rts

  .org $fffc
  .word reset
  .word $0000
