#include "common.h"

#define ASCII_ZERO (48)
#define ASCII_A (97)
#define MAX_NUM_STR_LEN (10)

extern int strcmp(char* s1, char* s2);
int strlen(char*);
char* strchr(char*, char, unsigned int);
char* strncpy(char*, char*, unsigned int);
char* itoa(unsigned int, unsigned char);
unsigned int atoi(char*, unsigned char);
unsigned int atoi2(char*, char**, unsigned char);
int printf(char*, ...);
void* memset(void*, char, unsigned int);
