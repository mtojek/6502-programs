PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e

value = $0300 ; 2 bytes
mod10 = $0302 ; 2 bytes
message = $0304 ; 6 bytes
counter = $030a ; 2 bytes

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  ldx #$ff
  txs

  bit PORTA ; Try: clear all interrupt flags
  bit PORTB

  lda #%01111111 ; Try: disable other interrupts
  sta IER
  lda #$82
  sta IER
  lda #$00
  sta PCR

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  ; Wait until LCD init is done
  jsr lcd_wait

  lda #%00001100 ; Display on; cursor off; blink off
  jsr lcd_instruction

  lda #0
  sta counter
  sta counter + 1

loop:
  lda #%00000010 ; Put cursor at home
  jsr lcd_instruction

  lda #0
  sta message

  ; Initialize value to be the number to convert
  sei
  lda counter
  sta value
  lda counter + 1
  sta value + 1
  cli

divide:
  ; Initialize the remainder to zero
  lda #0
  sta mod10
  sta mod10 + 1
  clc

  ldx #16

divloop:
  ; Rotate quotient and remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; a,y = dividend - devisor
  sec
  lda mod10
  sbc #10
  tay ; save low byte in Y
  lda mod10+1
  sbc #0
  bcc ignore_result ; branch if dividend < devisor
  sty mod10
  sta mod10 + 1

ignore_result:
  dex
  bne divloop
  rol value ; shift in the last bit of the quotient
  rol value + 1

  lda mod10
  clc
  adc #"0"
  jsr  push_char

  ; if value != 0, then continue dividing
  lda value
  ora value + 1
  bne divide ; branch if value not equal to 0

  ldx #0
print_clicks:
  lda clicks,x
  beq print_z
  jsr print_char
  inx
  jmp print_clicks

print_z:
  ldx #0
print:
  lda message,x
  beq print_end
  jsr print_char
  inx
  jmp print

print_end:
  lda #'!'
  jsr print_char
  jmp loop

; Add the character in the A register to the beginning of the 
; null-terminated string `message`
push_char:
  pha ; Push new first char onto stack
  ldy #0

char_loop:
  lda message,y ; Get char on the string and put into X
  tax
  pla
  sta message,y ; Pull char off stack and add it to the string
  iny
  txa
  pha           ; Push char from string onto stack
  bne char_loop

  pla
  sta message,y ; Pull the null off the stack and add to the end of the string

  rts

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

  jsr lcd_wait
  sta PORTB

  lda #RS        ; Clear RW/E bits
  sta PORTA
  lda #(RS | E)  ; Set RS | E bit to send an instruction
  sta PORTA
  lda #RS        ; Clear RW/E bits
  sta PORTA

  pla
  rts

nmi:
  rti

irq:
  pha
  txa
  pha
  tya
  pha

  inc counter
  bne exit_irq
  inc counter + 1
exit_irq:
  ldy #$ff
  ldx #$ff
delay:
  dex
  bne delay
  dey
  bne delay

  ; TODO read multiple buttons from PORTA
  bit PORTA ; Read from PORTA to clear the interrupt flag

  pla
  tay
  pla
  tax
  pla

  rti

clicks: .asciiz "Clicks: "

  .org $fffa
  .word nmi
  .word reset
  .word irq
