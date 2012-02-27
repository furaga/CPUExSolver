#include<iostream>
#include<sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
using namespace std;

typedef union{int32_t i; float f;} conv;

int main()
{
	uint32_t u = 0xffFFffFF;
	int32_t s = 0xffFFffFF;
	cout << (0xffFFffFF) << endl;
	cout << (u >> 2) << endl;
	cout << ((unsigned)s >> 2) << endl;
	cout << (s >> 2) << endl;
	
	conv a;
	a.f = (float)32;
	cout << a.i << endl;

	return 0;
}
