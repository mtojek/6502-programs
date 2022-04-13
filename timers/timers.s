PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004
T1CH = $6005
ACR  = $600B
IFR  = $600D
IER  = $600E

ticks = $00
toggle_time = $04

	.org $8000

reset:
	lda #%11111111 ; Set all pins on port A to output
	sta DDRA

	lda #0
	sta PORTA
	sta toggle_time

	jsr init_timer

loop:
	sec
	lda ticks
	sbc toggle_time
	cmp #25 ; Have 250ms elapsed
	bcc loop
	lda #$01
	eor PORTA
	sta PORTA
	lda ticks
	sta toggle_time

	jmp loop

init_timer:
	lda #0
	sta ticks
	sta ticks+1
	sta ticks+2
	sta ticks+3

	lda #%01000000
	sta ACR
	lda #$76
	sta T1CL
	lda #$16
	sta T1CH
	lda #%11000000
	sta IER
	cli
	rts

irq:
	bit T1CL
	inc ticks
	bne end_irq
	inc ticks+1
	bne end_irq
	inc ticks+2
	bne end_irq
	inc ticks+3
end_irq:
	rti

	.org $fffc
	.word reset
	.word irq
