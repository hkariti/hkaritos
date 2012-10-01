#include "shell.h"
#include "string.h"

void prompt() {
	char* line;

	while (1) {
		puts("> ");
		line = read_line();
		parse(line);
	}
}

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

void parse(char* user_cmd) {
	struct cmd_entry commands[NUM_OF_COMMANDS] = {
		{"help", &help_cmd},
		{"exit", &help_cmd},
		{"ls", &help_cmd},
	};

	unsigned int i = 0;
	unsigned int ret;

	if (*user_cmd == NULL) return; // Skip empty commands

	while (i < NUM_OF_COMMANDS) {
		if ((ret = strcmp(commands[i].name, user_cmd) ) == 0) {
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

void help_cmd() {
	puts("Welcome to my shell. Commands:\r\n");
	puts("help                      Show this message\r\n");
}
