#include	<stdio.h>
#include    <stdlib.h>
#include    <string.h>
#define 	Max 100

void main(){

    char grade = 'B';

    switch(grade){
    case 'A' :
        printf("Excellent!" );
        break;
    case 'B' :
    case 'C' :
        printf("Well done" );
        break;
    case 'D' :
        printf("You passed" );
        break;
    case 'F' :
        printf("Better try again" );
        break;
    default :
        printf("Invalid grade" );
    }
    printf("Your grade is  %c", grade );
}