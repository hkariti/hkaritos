SRCDIR := src
INCLUDEDIR := include
CFLAGS = -m32 -fno-builtin -nostdlib -I${INCLUDEDIR}

.PHONY: all clean

all: disk1
	if [ -x "`which qemu-system-i386`" ]; then \
		qemu-system-i386 -no-kvm -s -hda disk1 ; \
	else \
		echo No qemu? ; \
	fi
	#sleep 1
	#vncviewer :0; exit 0
	#pkill qemu; exit 0

disk1: loader
	dd if=loader of=disk1 conv=sync
	dd if=main of=disk1 conv=notrunc,sync seek=1
	/bin/echo -ne "\x55\xaa" | dd bs=1 seek=510 of=disk1 conv=notrunc

loader: ${SRCDIR}/loader.s.m4 main
	m4 -DSHELL_SIZE=$(shell du --apparent-size -B 512 main | awk '{print $$1}') ${SRCDIR}/loader.s.m4 > loader.s
	nasm loader.s -o loader

shell.o: ${SRCDIR}/shell.c ${INCLUDEDIR}/shell.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/shell.c -o shell.o

string.o: ${SRCDIR}/string.c ${INCLUDEDIR}/string.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/string.c -o string.o

mem.o: ${SRCDIR}/mem.c ${INCLUDEDIR}/mem.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/mem.c -o mem.o

boot.o: ${SRCDIR}/boot.s
	nasm ${SRCDIR}/boot.s -f elf -o boot.o

aux.o: ${SRCDIR}/aux.s
	nasm ${SRCDIR}/aux.s -f elf -o aux.o

interrupts.o: ${SRCDIR}/interrupts.s
	nasm ${SRCDIR}/interrupts.s -f elf -o interrupts.o

main.o: ${SRCDIR}/main.c ${INCLUDEDIR}/string.h ${INCLUDEDIR}/interrupts.h ${INCLUDEDIR}/shell.h ${INCLUDEDIR}/common.h
	gcc ${CFLAGS} -c ${SRCDIR}/main.c -o main.o

main: main.o link.ld aux.o boot.o shell.o string.o mem.o interrupts.o
	ld -T link.ld -m elf_i386 -o main boot.o main.o aux.o shell.o string.o mem.o interrupts.o

clean:
	rm -f disk1 *.o loader* shell 
