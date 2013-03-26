#include "common.h"

#define MAX_CMDLINE_LENGTH (100)
#define MAX_ARGUMENTS_NUM (10)


extern char getc();

extern unsigned int puts(char* s);

extern void putc(char c);


struct cmd_entry {
	char* name;
	void (*ptr)();
};

struct cmd_args {
	unsigned int argc;
	char** argv;
};

void prompt();
int read_line(char*, unsigned int);
void parse(char*);
void help_cmd(int, char**);
void print_cmd(int, char**);
void get_int_cmd(int, char**);
struct cmd_args* split_cmd(char*);

