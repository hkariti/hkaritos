#include "shell.h"
#define NULL 0
#define COMMAND_STR_BASE ((char*)0x2000)
#define NUM_OF_COMMANDS (3)
#define ASCII_ZERO (48)

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

int strlen(char* s) {
	unsigned int i = 0;

	while (*(s+i)) i++;

	return i;
}

char* itoa(unsigned int n) {
	char* str = (char*)0x3000;
	unsigned int i = 10;
	int d = 0;

	// Terminate the string first
	str[i] = 0;
	
	// Handle special case for zero
	if (n == 0) {
		i--;
		str[i] = ASCII_ZERO;
	}

	while (n > 0 && i > 0) {
		i--;
		d = n % 10;
		n /= 10;
		str[i] = (char)(ASCII_ZERO + d);
	}

	return str + i;
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
