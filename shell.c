#include "shell.h"
#include "string.h"
#include "mem.h"

void prompt() {
	char cmdline[MAX_CMDLINE_LENGTH];

	while (1) {
		puts("> ");
		if (read_line(cmdline, MAX_CMDLINE_LENGTH))
			parse(cmdline);
	}
}

struct cmd_args* split_cmd(char* cmd) {
	struct cmd_args* args;
	char* p;
	unsigned int len, argc;
	char* arg_list[10];

	// Allocate cmd_args struct
	args = malloc(sizeof(struct cmd_args));
	if (args == NULL) return NULL;

	while (*cmd == ' ') cmd++; // Skip leading spaces

	argc = 0;

	// Fill the internal argument list with the characters between the spaces
	while ( (p = strchr(cmd, ' ', MAX_CMDLINE_LENGTH)) != NULL) {
		len = p - cmd;
		arg_list[argc] = malloc(len+1); // Extra byte for null terminator
		strncpy(arg_list[argc], cmd, len);
		*(arg_list[argc] + len) = NULL;
		cmd = p+1;
		argc++;
		if (argc == 10) return NULL; // Too many arguments
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
		if (strcmp(commands[i].name, splitted_cmd->argv[0])  == 0) {
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
	printf("I have %d arguments.\r\n", argc);
	printf("My name is %s.\r\n", argv[0]);

	if (argc > 1) {
		printf("My first argument is %s\r\n", argv[1]);
	}
}

