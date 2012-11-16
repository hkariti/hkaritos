SRCDIR := src
INCLUDEDIR := include
CFLAGS = -m32 -fno-builtin -nostdlib -I${INCLUDEDIR}

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

disk1: loader shell
	dd if=loader of=disk1 conv=sync
	dd if=shell of=disk1 conv=notrunc,sync seek=1
	/bin/echo -ne "\x55\xaa" | dd bs=1 seek=510 of=disk1 conv=notrunc

loader: ${SRCDIR}/loader.s
	nasm ${SRCDIR}/loader.s -o loader

shell.o: ${SRCDIR}/shell.c ${INCLUDEDIR}/shell.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/shell.c -o shell.o

string.o: ${SRCDIR}/string.c ${INCLUDEDIR}/string.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/string.c -o string.o

mem.o: ${SRCDIR}/mem.c ${INCLUDEDIR}/mem.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/mem.c -o mem.o

boot.o: ${SRCDIR}/boot.s
	nasm ${SRCDIR}/boot.s -f elf -o boot.o

shell: link.ld boot.o shell.o string.o mem.o
	ld -T link.ld -m elf_i386 -o shell boot.o shell.o string.o mem.o

clean:
	rm -f disk1 *.o loader shell
