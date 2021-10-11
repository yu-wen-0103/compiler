#include	<stdio.h>
#include    <stdlib.h>
#include    <string.h>
#define 	Max 100

void main(int argc, char ** argv)
{
	int n;
	int a = 0, i=0 , * num = malloc(sizeof(int)* Max);
	float b;
	char ccc, dd[3][5];
	char * s;
	int i;
	ccc = 't';
	scanf("%f%c", &b, dd[1]);
	s = malloc(sizeof(char)* n);
	a = 1;
		
	while(!a){
		a = 3;
	}
		
	b = a + 1;

	if(a==4 && b==2){
		a = a+1;
	}
	
	if (ccc == 't'){
		if(a == 3){
	    	a ++;
		}
		ccc = 'a';
	}
	else{
		if(b != 4){
			b *= 4;
			b = a%2; 
		}
		ccc = 'b';
	}

	for(i = 1; i <= 10 ; i++){
		b += i;
	}
		
	printf("num:%d %d", a, b);
	free(num);
	return 0;
}
