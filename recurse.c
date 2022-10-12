#include<stdio.h>
#include<stdlib.h>

int f(int n){
    if (n == 0){
        return 5;
    }
    else {
        return 4*(n+1) + 2*f(n-1)-2;
    }
}

int main(int argc, char *argv[]){
    int num = atoi(argv[1]);
    int ret = f(num);
    printf("%d", ret);
}

