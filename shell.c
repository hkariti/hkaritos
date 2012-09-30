#include "shell.h"
#define COMMAND_STR_BASE ((char*)0x2000)


char* read_line() {
	char c;
	unsigned int i = 0;
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

int strlen(char* s) {
	unsigned int i = 0;

	while (*(s+i)) i++;

	return i;
}

void parse(char* cmd) {
	char* cur;
	void** ptr = 0;
	extern void* cmds;

	unsigned int l;

	if (*cmd == 0) return; // Skip empty commands

	cur = (char*)cmds;
	puts(cmds);
	while (*cur) { // Loop until we reach the end of the command list
		l = strlen(cur);
		if (strcmp(cmd, cur) == 0) {
			ptr = (void**)(cur + l + 1); // Set ptr to the command's address
			(**(void (**)(void))ptr)(); // Call the function
			return;
		}
		else {
			cur += l + 1 + 4; // Skip the command name (l + 1) and the command's address (4)
		}
	}

	puts(cmd);
	puts(": unknown command.\r\n");

	return;
}

	

