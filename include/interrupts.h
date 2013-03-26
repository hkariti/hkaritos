#include "common.h"

void* get_int(unsigned char int_num, void** segment, void** offset);
void* setup_int(unsigned char int_num, void* segment, void* offset);
void* get_cs();

struct int_vector {
	void* segment;
	void* offset;
};
