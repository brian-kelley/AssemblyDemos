all:
	nasm -fmacho64 src.asm -o src.o
	ld -macosx_version_min 10.6 /usr/lib/crt1.o -lc src.o -o WaveDemo
