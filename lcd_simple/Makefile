build:
	vasm -Fbin -dotdir -o program.out lcd_simple.s
	hexdump -C program.out
	wc program.out

clean:
	rm -f *.out
