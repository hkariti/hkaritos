asm(".code16gcc\n");

extern char getc();

extern void puts(char* s);

extern void putc(char c);

extern int strcmp(char* s1, char* s2);

extern void help_cmd();

struct cmd_entry {
	char* name;
	void (*ptr)(void);
};

