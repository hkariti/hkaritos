#include "mem.h"

void* malloc(unsigned int s) {
	static void* base = (void*)0x5000;
	void* alloc = base;

	base+=s;

	return alloc;
}

void free (void* p) {
	return;
}
