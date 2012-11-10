#include "string.h"

int strlen(char* s) {
	unsigned int i = 0;

	while (*(s+i)) i++;

	return i;
}

char* itoa(unsigned int n, unsigned char base) {
	static char str[MAX_NUM_STR_LEN+1];
	unsigned int i = MAX_NUM_STR_LEN;
	unsigned int d;

	if (base != 10 && base != 16) return NULL;

	// Terminate the string first
	str[i] = 0;
	
	// Handle special case for zero
	if (n == 0) {
		i--;
		str[i] = ASCII_ZERO;
	}

	// Fill the numer backwards as a string (lowest digit to largest)
	while (n > 0 && i > 0) {
		i--;
		d = n % base ;
		n /= base;
		if (d < 10) {
			str[i] = (char)(ASCII_ZERO + d);
		}
		else {
			d -= 10; // 10 is like zero when we start counting from ascii 'a'
			str[i] = (char)(ASCII_A + d);
		}
	}

	return str + i;
}
	
int printf(char* fmt, ...) {
	unsigned int start_mark = 0;
	unsigned int i = 0;
	unsigned int chars_printed = 0;
	void* nextarg = (void*)&fmt + sizeof(char*);

	// Print the string between the % placeholders and handle each placeholder type
	while (fmt[i] != NULL) {
	   if (fmt[i] == '%') {
		   // Print the text until the start of the % placeholder
		   fmt[i] = NULL;
		   chars_printed += puts(fmt+start_mark);
		   fmt[i] = '%';
		   
		   // Handle each placeholder type
		   i++;
		   switch (fmt[i]) {
			   case 'd':
				   chars_printed += puts(itoa(*(int*)nextarg, 10));
				   nextarg+=sizeof(int);
				   break;
			   case 'x':
				   chars_printed += puts(itoa(*(int*)nextarg, 16));
				   nextarg+=sizeof(int);
				   break;
			   case 's':
				   chars_printed += puts(*(char**)nextarg);
				   nextarg+=sizeof(char*);
				   break;
		   }

		   // Move the mark to the start of the next block (after the handled placeholder)
		   start_mark = i+1;
	   }
	   i++;
	}

	// Print the text that remains after the last placeholder
	chars_printed += puts(fmt+start_mark);

	return chars_printed;
}
	
