asm(".code16gcc\n");

extern char getc();

extern void puts(char* s);

extern void putc(char c);

extern int strcmp(char* s1, char* s2);

struct cmd_entry {
	char* name;
	void (*ptr)(void);
};

void prompt();
char* read_line();
int strlen(char*);
void parse(char*);
void help_cmd();

