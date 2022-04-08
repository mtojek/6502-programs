build:
	vasm -Fbin -dotdir -o program.out interrupts.s
	hexdump -C program.out
	wc program.out

arduino:
	hexdump program.out | cut -f2- -d " " | sed -e "s/ /, 0x/g"

clean:
	rm -f *.out
