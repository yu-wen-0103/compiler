#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

char *getword(char *text,char *word)
{
  char *ptr=text;
  char *qtr=word;
  char *textend;
  textend=text+strlen(text);
  *(word)='\0';
  while(isspace(*ptr))
  {
    ptr++;
  }
  while(!isspace(*ptr)&&ptr<textend)
  {
    *qtr++=*ptr++;
  }
  *qtr='\0';
  if(*(word)=='\0')
  {
    return NULL;
  }
  else 
  {
    return ptr;
  }
}

int main()
{
  char *input=malloc(sizeof(char)*1000);
  char *ptr;
  char *word=malloc(sizeof(char)*1000);
  char **all_word=malloc(sizeof(char*)*1000);
  for(int i=0;i<1000;i++)
  {
      *(all_word+i)=malloc(sizeof(char)*1000);
  }
  int i=0;
  int flag=0;
  char *temp=malloc(sizeof(char)*1000);
  char *temp2=malloc(sizeof(char)*1000);
  int issame=0;
  char **all_word2=malloc(sizeof(char*)*1000);
  for(int i=0;i<1000;i++)
  {
      *(all_word2+i)=malloc(sizeof(char)*1000);
  }
  int k=0;
  int v=0;
  int m=0;
  while(fgets(input,1000,stdin)!=NULL)
  {
    ptr=input;
    while((ptr=getword(ptr,word))!=NULL)
    {
      strcpy(*(all_word+i),word);
      i++;
    }
  }
  
  //判斷數字或字串
  flag=0;
  for(int j=0;j<i;j++)
  {
    if(atoi(*(all_word+j))==0)
    {
      flag=1;
      break;
    }
  }

  //number
  if(flag==0)
  {
    for(int j=0;j<i-1;j++)
    {
      for(int k=j+1;k<i;k++)
      {
        if(atoi(*(all_word+j))<atoi(*(all_word+k)))
        {
          strcpy(temp,*(all_word+j));
          strcpy(*(all_word+j),*(all_word+k));
          strcpy(*(all_word+k),temp);
        }
      }
    }
  }

  //string
  if(flag==1)
  {
    for(int j=0;j<i-1;j++)
    {
      for(int k=j+1;k<i;k++)
      {
        if(strcmp(*(all_word+j),*(all_word+k))>0)
        {
          strcpy(temp2,*(all_word+j));
          strcpy(*(all_word+j),*(all_word+k));
          strcpy(*(all_word+k),temp2);
        }
      }
    }
  }

  //find same
  for(int n=0;n<i;n++)
  {
    issame=0;
    for(m=0;m<n;m++)
    {
      if(strcmp(*(all_word+m),*(all_word+n))==0)
      {
        issame=1;
      }
    }
    if(issame==0)
    {
      strcpy(*(all_word2+v),*(all_word+m));
      v++;
    }
  }
  for(int u=0;u<v;u++)
  {
    printf("%s\n",*(all_word2+u));
  }
  return 0;
}
