#include "mem.h"

void* malloc(unsigned int s) {
	static void* base = 0x5000;
	void* alloc = base;

	base+=s;

	return alloc;
}
