#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>
#define     Max 10

struct  node{
    int     num;
    int     coin;	
    int     total;  //the total coin that from root to this node
    struct  node *r_child;
    struct  node *l_child;
};

int     maxcoin=0;
int     cnt=1;

struct  node *insert(struct node *T,int num,int coin,int total){
    if(T==NULL){
        struct node *newleaf=malloc(sizeof(struct node));
        newleaf->num=num;
        newleaf->coin=coin;
        newleaf->total=total+coin;
        newleaf->r_child=NULL;
        newleaf->l_child=NULL;
        if(maxcoin<=newleaf->total){	//find out the max total coin during inserting the node
            maxcoin=newleaf->total;
        }
        return newleaf;
    }
    else if(num<T->num){
        T->l_child=insert(T->l_child,num,coin,T->total);
    }
    else if(num>T->num){
        T->r_child=insert(T->r_child,num,coin,T->total);
    }
    return T;
}

int height(struct node* T) { 
    if (T==NULL) 
        return 0; 
    else{
        int lheight = height(T->l_child); 
        int rheight = height(T->r_child); 
        if (lheight > rheight) 
            return(lheight+1); 
        else return(rheight+1); 
    } 
}

void printGivenLevel(struct node* T, int level,struct node *root) { 
    if (T == NULL)
        return;
    if (level == 1){
        if(T->total==maxcoin){
            struct  node *tmp=root;
            printf("Trajectory %d:",cnt);
            cnt++;
            while(tmp!=NULL){
                printf(" %d",tmp->num);
                if(T->num<tmp->num){
                    tmp=tmp->l_child;
                }
                else{
                    tmp=tmp->r_child;
                }
            }
            printf("\n");
        }
    }
    else if (level > 1){
        printGivenLevel(T->l_child, level-1, root); 
        printGivenLevel(T->r_child, level-1, root); 
    } 
} 

void print(struct node* T) //use level order to find the max total coin
{ 
    int h = height(T); 
    int i; 
    for (i=1; i<=h; i++) 
        printGivenLevel(T, i, T); 
} 

int     main(){
    char    input[Max],number[Max]={0},coin[Max]={0};
    char    *ptr,*qtr,*rp;
    int     num=0,coin_int=0;
    struct  node *bst=NULL;

    while(fgets(input,Max,stdin)!=NULL){	
        if(input[strlen(input)-1]=='\n'){
            input[strlen(input)-1]='\0';
        }
        if(strcmp(input,"00")==0){	//when you meet "00", ending.
            break;
        }
        else{
            ptr=input;
            qtr=number;
            while(*ptr!=','){
                *qtr++=*ptr++;
            }
            *qtr='\0';
            num=atoi(number);
            ptr++;
            rp=coin;
            while(*ptr!='\0'){
                *rp++=*ptr++;
            }
            *rp='\0';
            coin_int=atoi(coin);
            bst=insert(bst,num,coin_int,0);
        }
    }
    print(bst);
    printf("Coins: %d",maxcoin);
    return 0;
}
