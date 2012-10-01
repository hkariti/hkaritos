#include "common.h"

#define COMMAND_STR_BASE ((char*)0x2000)
#define NUM_OF_COMMANDS (3)

asm(".code16gcc\n");

extern char getc();

extern void puts(char* s);

extern void putc(char c);


struct cmd_entry {
	char* name;
	void (*ptr)(void);
};

void prompt();
char* read_line();
void parse(char*);
void help_cmd();

