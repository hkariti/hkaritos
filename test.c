#include "shell.h"


char str[] = "some string";
char str2[] = "some string";

void testfunc() {
	
	if (strcmp(str, str2) == 0) {
		puts("(strings are identical) ");
		str[0] = 'S';
	}
	else {
		puts("(strings differ) ");
		str[0] = 's';
	}
}	
