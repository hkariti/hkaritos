#include "shell.h"
#define COMMAND_STR_BASE ((char*)0x2000)


char* read_line() {
	char c;
	int i = 0;
	char* cmd = COMMAND_STR_BASE;

	while ( (c = getc() ) != 13 ) { // Read until newline
		if (c == 0x08) { // Handle backspace
			if (i == 0) continue;
			i--;
			puts("\b \b");
		}
		else {
			*(cmd+i) = c;
			i++;
			putc(c);
		}
	}

	*(cmd+i) = 0; // Add a NULL terminator

	puts("\r\n");
	return cmd;
}
