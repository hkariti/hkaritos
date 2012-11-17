#include "shell.h"
#include "string.h"
#include "mem.h"

// Prompt the user for a command
void prompt() {
	char cmdline[MAX_CMDLINE_LENGTH];

	while (1) {
		puts("> ");
		if (read_line(cmdline, MAX_CMDLINE_LENGTH))
			parse(cmdline);
	}
}

// Split the cmdline into words and make the argv array
struct cmd_args* split_cmd(char* cmd) {
	struct cmd_args* args;
	char* p;
	unsigned int len, argc;
	char* arg_list[MAX_ARGUMENTS_NUM];

	// Allocate cmd_args struct
	args = malloc(sizeof(struct cmd_args));
	if (args == NULL) return NULL;

	while (*cmd == ' ') cmd++; // Skip leading spaces

	argc = 0;

	// Fill the internal argument list with the characters between the spaces
	while ( (p = strchr(cmd, ' ', MAX_CMDLINE_LENGTH)) != NULL) {
		len = p - cmd;
		arg_list[argc] = malloc(len+1); // Allocate extra byte for null terminator
		strncpy(arg_list[argc], cmd, len);
		*(arg_list[argc] + len) = NULL; // Set the NULL terminator
		cmd = p+1; // Move the marker to the beginning of the next word
		argc++;
		if (argc == MAX_ARGUMENTS_NUM) return NULL; // Too many arguments
	}

	// Fill the last argument, until the end of the string
	len = strlen(cmd);
	arg_list[argc] = malloc(len+1);
	strncpy(arg_list[argc], cmd, len);
	*(arg_list[argc] + len) = NULL;
	argc++;

	// Fill the cmd_args struct
	args->argc = argc;
	args->argv = malloc(argc*sizeof(char*));

	// Copy the internal argument list to the returned struct
	for (argc = 0; argc < args->argc; argc++) {
		args->argv[argc] = arg_list[argc];
	}

	return args;
}

// Read a single line from the keyboard
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

// Parse a command line and run the requested command
void parse(char* user_cmd) {
	struct cmd_entry commands[] = {
		{"help", &help_cmd},
		{"exit", &help_cmd},
		{"ls", &help_cmd},
		{"print", &print_cmd},
	};

	unsigned int num_of_commands = sizeof(commands)/sizeof(struct cmd_entry);
	unsigned int i = 0;

	struct cmd_args* splitted_cmd;

	splitted_cmd = split_cmd(user_cmd);	

	if (!user_cmd || *user_cmd == NULL) return; // Skip empty commands

	
	while (i < num_of_commands) {
		if (strcmp(commands[i].name, splitted_cmd->argv[0]) == 0) {
			(commands[i].ptr)(splitted_cmd->argc, splitted_cmd->argv); // Call the function
			return;
		}
		i++;
	}

	// If we reach here, no command has matched
	puts(splitted_cmd->argv[0]);
	puts(": unknown command.\r\n");

	return;
}


void help_cmd(int argc, char** argv) {
	int n;
	puts("Welcome to my shell. Commands:\r\n");
	puts("help                      Show this message\r\n");
}

void print_cmd(int argc, char** argv) {
	void* ptr;
	int size = 16;
	int i;

	if (argc == 1) {
		printf("Usage: %s ADDR [LENGTH]\r\n", argv[0]);
		return;
	}
	if (argc > 2) size = atoi(argv[2], 10);

	if (size == 0) {
		printf("Invalid size: %d\r\n", size);
		return;
	}

	ptr = (void*)atoi(argv[1], 16);

	for (i=0; i<size; i++) {
		// Print the address every 16 bytes
		if (i % 16 == 0) printf("0x%4x: ", ptr+i);

		printf("%2x ", *(unsigned char*)(ptr+i));

		// Two spaces in the middle (8 bytes)
		// New line after every 16 bytes
		if (i % 16 == 7) puts(" "); 
		if (i % 16 == 15) puts("\r\n");
	}

	if (i % 16 > 0)
		printf("\r\n");

}

