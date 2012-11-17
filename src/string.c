#include "string.h"

// Count the number of bytes in a string
int strlen(char* s) {
	unsigned int i = 0;

	while (*(s+i)) i++;

	return i;
}

// Find a specific character in a string
char* strchr(char* s, char c, unsigned int n) {
	int i;

	for (i = 0 ; i < n; i++) {
		if (s[i] == c) return s+i;
		if (s[i] == NULL) break;
	}

	return NULL;
}

// Copy a string
char* strncpy(char* dest, char* src, unsigned int n) {
	char* d = dest;

	while (n > 0) {
		*dest = *src;
		if ( *src == NULL ) break;

		src++;
		dest++;
		n--;
	}

	return dest;
}

// Convert a number to an ASCII string
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

// Convert an ASCII string to a number
unsigned int atoi(char* str, unsigned char base) {
	unsigned int ret;
	ret = atoi2(str, (char**)NULL, base);
	return ret;
}

unsigned int atoi2(char* str, char** endptr, unsigned char base) {
	unsigned int n = 0;

	if (base != 10 && base != 16) return 0;
	
	if (endptr != NULL) *endptr = NULL;

	while (*str != 0) {
	 // Ignore characters out of the requested base's range and update endptr
		if ( (*str < ASCII_ZERO || *str > ASCII_A + 5 ) ||
			(*str > ASCII_ZERO + 9 && *str < ASCII_A) ||
			(base == 10 && *str > ASCII_ZERO + 9) ) {
				if (endptr != NULL) *endptr = str;
				break;
		}
		

		n *= base;
		if (*str < ASCII_A) {
			n += *str - ASCII_ZERO;
		}
		else {
			n += *str - ASCII_A + 10;
		}

		str++;
	}

	return n;
}
	
// Print a message according to a format
int printf(char* fmt, ...) {
	char* block_start_ptr;
	char* field_ptr;
	char* padding_ptr;
	char padding_chr;
	unsigned int chars_printed = 0;
	unsigned int field_min_len, field_len, padding_len;
	void* nextarg = (void*)&fmt + sizeof(char*);

	// Print the string between the % placeholders and handle each placeholder type
	block_start_ptr = fmt;
	while (*fmt != NULL) {
	   if (*fmt == '%') {
		   // Print the text until the start of the % placeholder
		   *fmt = NULL;
		   chars_printed += puts(block_start_ptr);
		   *fmt = '%';
		   fmt++;

		   // Handle field length specifiers
		   field_min_len = atoi2(fmt, &fmt, 10);

		   // Handle each placeholder type
		   switch (*fmt) {
			   case 'd':
				   field_ptr = (char*)itoa(*(int*)nextarg, 10);
				   padding_chr = '0';

				   nextarg+=sizeof(int);
				   break;
			   case 'x':
				   field_ptr = itoa(*(int*)nextarg, 16);
				   padding_chr = '0';

				   nextarg+=sizeof(int);
				   break;
			   case 's':
				   field_ptr = *(char**)nextarg;
				   padding_chr = ' ';

				   nextarg+=sizeof(char*);
				   break;
			   default:
				   field_ptr = NULL;
				   field_len = NULL;
		   }

		   // Pad the field if necessary
		   field_len = strlen(field_ptr);
		   if (field_min_len > field_len) {
				   padding_len = field_min_len - field_len;
				   padding_ptr = (char*)malloc(padding_len + 1);
				   memset((void*)padding_ptr, padding_chr, padding_len);
				   chars_printed += puts(padding_ptr);
				   free(padding_ptr);
		   }

		   // Print the field's content (padding was printed already)
		   chars_printed += puts(field_ptr);

		   // Move the mark to the start of the next block (after the handled placeholder)
		   block_start_ptr = fmt+1;
	   }
	   fmt++;
	}

	// Print the text that remains after the last placeholder
	chars_printed += puts(block_start_ptr);

	return chars_printed;
}
	
// Fill a memory region with a constant byte
void* memset(void* p, char c, unsigned int n) {
	unsigned int i;
	for (i = 0; i < n; i++) 
		*(char*)(p+i) = c;

	return p;
}
