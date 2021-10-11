void main()
{
   int a;
   int b;
   int i;

   i = 0;
   a = 0;
   b = a * (100 + 123);
   for(i = 1 ; i < 10 ; i++){
      a = b + 10;
   }
   for(i = 14 ; i >= 4 ; i--){
      a = -a;
      b = b - a;
   }
   printf("a = %d", a);
}
