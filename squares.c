#include<stdio.h>
#include<stdlib.h>

int main(int argc, char *argv[]){
        int num = atoi(argv[1]);
        int ret = num*num;
        printf("%d\n", ret);
}