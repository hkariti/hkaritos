.PHONY: all clean

all: disk1
	if [ -x "`which qemu-system-i386`" ]; then \
		qemu-system-i386 -hda disk1 ; \
	else \
		echo No qemu? ; \
	fi
	#sleep 1
	#vncviewer :0; exit 0
	#pkill qemu; exit 0

disk1: loader.boot shell.boot
	dd if=loader.boot of=disk1 conv=sync
	dd if=shell.boot of=disk1 conv=notrunc,sync seek=1
	/bin/echo -ne "\x55\xaa" | dd bs=1 seek=510 of=disk1 conv=notrunc

loader.boot: loader.s
	nasm loader.s -o loader.boot 

shell.o: shell.s
	nasm shell.s -f elf -o shell.o

test.o: shell.c shell.h
	gcc -m32 -c shell.c -fno-builtin  -nostdlib -o test.o

shell.boot: shell.o test.o link.ld
	ld -T link.ld -m elf_i386 -o shell.boot shell.o test.o

clean:
	rm -f disk1 *.o *.boot
