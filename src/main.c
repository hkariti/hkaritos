#include "common.h"
#include "shell.h"
#include "string.h"
#include "keyboard.h"

void init() {
	puts("Hello there, starting up now...\r\n");
	keyboard_init();
	prompt();
}

