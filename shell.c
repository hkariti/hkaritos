#include "shell.h"
#define NULL 0
#define COMMAND_STR_BASE ((char*)0x2000)
#define NUM_OF_COMMANDS (3)


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
		else { // Add the read chars to a string and print them one by one 
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

void parse(char* user_cmd) {
	struct cmd_entry commands[NUM_OF_COMMANDS] = {
		{"help", &help_cmd},
		{"exit", &help_cmd},
		{"ls", &help_cmd},
	};

	unsigned int i = 0;

	if (*user_cmd == NULL) return; // Skip empty commands

	while (i < NUM_OF_COMMANDS) {
		if (strcmp(user_cmd, commands[i].name) == 0) {
			(commands[i].ptr)(); // Call the function
			return;
		}
		i++;
	}

	// If we reach here, no command has matched
	puts(user_cmd);
	puts(": unknown command.\r\n");

	return;
}
