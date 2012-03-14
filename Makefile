.PHONY: all clean

all: disk1
	qemu -hda disk1 
	#sleep 1
	#vncviewer :0; exit 0
	#pkill qemu; exit 0

disk1: read.boot hello.boot
	dd if=read.boot of=disk1 conv=notrunc
	dd if=hello.boot of=disk1 conv=notrunc seek=1

read.boot: read.s
	nasm read.s -o read.boot 

hello.boot: hello.s
	nasm hello.s -o hello.boot

clean:
	rm -f disk1 read.boot hello.boot
