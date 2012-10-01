#include "common.h"

#define MAX_CMDLINE_LENGTH (100)
#define NUM_OF_COMMANDS (3)


extern char getc();

extern void puts(char* s);

extern void putc(char c);


struct cmd_entry {
	char* name;
	void (*ptr)(void);
};

void prompt();
int read_line(char*, unsigned int);
void parse(char*);
void help_cmd();

