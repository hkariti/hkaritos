.PHONY: all clean

all: disk1
	if [ -x "`which qemu-system-i386`" ]; then \
		qemu-system-i386 -s -hda disk1 ; \
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

shell.o: shell.c shell.h common.h
	gcc -m32 -c shell.c -fno-builtin  -nostdlib -o shell.o

string.o: string.c string.h common.h
	gcc -m32 -c string.c -fno-builtin  -nostdlib -o string.o

boot.o: boot.s
	nasm boot.s -f elf -o boot.o

shell.boot: link.ld boot.o shell.o string.o
	ld -T link.ld -m elf_i386 -o shell.boot boot.o shell.o string.o

clean:
	rm -f disk1 *.o *.boot
