#include "string.h"

int strlen(char* s) {
	unsigned int i = 0;

	while (*(s+i)) i++;

	return i;
}

char* itoa(unsigned int n) {
	static char str[MAX_NUM_STR_LEN+1];
	unsigned int i = MAX_NUM_STR_LEN;
	unsigned int d;

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
		d = n % 10;
		n /= 10;
		str[i] = (char)(ASCII_ZERO + d);
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
				   chars_printed += puts(itoa(*(int*)nextarg));
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
	
