#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main()
{
  int maxScore,minScore,n,i,j,temp,num=0;
  float avgScore,all=0;
  int * number=malloc(sizeof(int)* n);
  scanf("%d",&n);
  for(i=0;i<n;i++)
  {
    scanf("%d",&num);
    *(number+i)=num;
    all=all+(*(number+i));
  }
  avgScore=all/n;
  maxScore=*(number);
  minScore=*(number);
  for(i=1;i<n;i++)
  {
    if(*(number+i)>maxScore)
    {
      maxScore=*(number+i);
    }
    if(*(number+i)<minScore)
    {
      minScore=*(number+i);
    }
  }
  printf("maxScore=%d\n",maxScore);
  printf("minScore=%d\n",minScore);
  printf("avgScore=%.2f\n",avgScore);
  for(i=0;i<n-1;i++)
  {
    for(j=i+1;j<n;j++)
    {
      if(*(number+j)<*(number+i))
      {
        temp=*(number+i);
        *(number+i)=*(number+j);
        *(number+j)=temp;
      }
    }
  }
  printf("Min to Max=");
  for(i=0;i<n;i++)
  {
    printf("%d ",*(number+i));
  }
  printf("\n");
  printf("Max to Min=");
  for(i=n-1;i>=0;i--)
  {
    printf("%d ",*(number+i));
  }
  printf("\n");
  free(number);
  return 0;
}
