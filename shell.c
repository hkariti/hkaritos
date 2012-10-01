#include "shell.h"
#include "string.h"

void prompt() {
	char cmdline[MAX_CMDLINE_LENGTH];

	while (1) {
		puts("> ");
		if (read_line(cmdline, MAX_CMDLINE_LENGTH))
			parse(cmdline);
	}
}

int read_line(char* cmdline, unsigned int maxlen) {
	char c;
	unsigned int i = 0;

	// Read until newline or end of allocated space
	while ( (c = getc() ) != 13 && i < maxlen) { 
		if (c == 0x08) { // Handle backspace
			if (i == 0) continue;
			i--;
			puts("\b \b");
		}
		else { // Add the read chars to a string and print them one by one 
			cmdline[i] = c;
			i++;
			putc(c);
		}
	}

	cmdline[i] = 0; // Add a NULL terminator

	puts("\r\n");
	return i;
}

void parse(char* user_cmd) {
	struct cmd_entry commands[NUM_OF_COMMANDS] = {
		{"help", &help_cmd},
		{"exit", &help_cmd},
		{"ls", &help_cmd},
	};

	unsigned int i = 0;
	unsigned int ret;

	if (!user_cmd || *user_cmd == NULL) return; // Skip empty commands

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
