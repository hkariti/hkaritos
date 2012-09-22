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

shell.boot: shell.s
	nasm shell.s -o shell.boot

clean:
	rm -f disk1 loader.boot shell.boot
