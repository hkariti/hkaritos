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
	
