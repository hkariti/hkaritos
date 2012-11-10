#include "mem.h"

void* malloc(unsigned int s) {
	static void* base = BASE_ALLOC_ADDR;
	void* alloc = base;

	base+=s;

	return alloc;
}
