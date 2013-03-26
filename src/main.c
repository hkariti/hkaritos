#include "common.h"
#include "shell.h"
#include "string.h"
#include "interrupts.h"
#include "keyboard.h"

struct int_vector old_int9, old_int16;

void set_interrupts() {

	get_int(9, &old_int9.segment, &old_int9.offset);
	get_int(0x16, &old_int16.segment, &old_int16.offset);

	setup_int(9, get_cs(), handle_int9);
	setup_int(0x16, get_cs(), handle_int16);
}

void init() {
	puts("Hello there, starting up now...\r\n");
	puts("Setting up interrupts.\r\n");
	set_interrupts();
	prompt();
}

