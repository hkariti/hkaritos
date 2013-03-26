SRCDIR := src
INCLUDEDIR := include
CFLAGS = -m32 -fno-builtin -nostdlib -I${INCLUDEDIR}
AS = nasm
ASFLAGS = -f elf

OBJECTS = boot.o interrupts.o keyboard.o main.o aux.o shell.o string.o mem.o

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

main.o: string.h interrupts.h shell.h keyboard.h

main: link.ld ${OBJECTS}
	ld -T link.ld -m elf_i386 -o main ${OBJECTS}

clean:
	rm -f disk1 *.o loader* main 

vpath %.h ${INCLUDEDIR}

%.o : ${SRCDIR}/%.s
	$(AS) $(ASFLAGS) $< -o $@

%.o : ${SRCDIR}/%.c %.h common.h 
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

# Ugly hack, because our pattern rule requires .h file for every .c file
main.h:
