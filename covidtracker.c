#include<stdio.h>
#include<stdlib.h>
#include<string.h>

struct node {
    char name[80];
    struct node *left;
    struct node *right;
};

void deallocate (struct node* node){
    if (node == NULL) return;
    deallocate(node->left);
    deallocate(node->right);
    free(node);
}

    //creates a new node with the given name
struct node* newNode (char value[80]){
    //Allocate memory for new node
    struct node* patientNode = (struct node*) malloc (sizeof (struct node));
    //assign name to this new node
    strcpy(patientNode->name, value);
    //Initializes left and right children as NULL
    patientNode-> left = NULL;
    patientNode-> right = NULL;
    return patientNode;
}

struct node* patientZero;

//recursive function to find parent of the given node
struct node* findParent (struct node* root, char parent[80]){
    if (root == NULL) return NULL;
    //compare two strings to see if they are equal
    if( strcmp(root->name, parent)==0 ){
        return root;
    }
    struct node* left = findParent(root->left, parent);
    struct node* right = findParent(root->right, parent);
    return left == NULL ? right : left;
    }

/*printing the tree*/
void preorder (struct node* node){
    if (node == NULL){
        return;
    }
    printf("%s\n", node->name);
    preorder (node->left);
    preorder (node->right);
}

int main (int argc, char *argv[]){

    /*create root of the tree*/
    char a[] = "BlueDevil";
    patientZero = newNode(a);

    FILE* ptr = fopen(argv[1], "r");
    char infected[80];
    char infecter[80];

    if (ptr == NULL){
        printf("no such file\n");
        exit(1);
    } 
    /* read characters until end of file*/
   
    while(fscanf(ptr, "%s %s", infected, infecter) != EOF){
        if (strcmp(infected,"DONE")==0){
            break;
        }
        struct node* parent = findParent(patientZero, infecter);
        struct node* newPatient = newNode(infected);
        if(parent->left == NULL){
            parent -> left = newPatient;
            //add the node to the tree if there is no child
        }
        else{
            if (strcmp(infected,parent->left->name)<0){
                struct node* child = parent->left;
                parent-> left = newPatient;
                parent-> right = child;
            }
            else {
                parent-> right = newPatient;
            }
            /*if the new node is alphabetically smaller than the child already existed
            swap it with the one already existed*/
        }
    }
    fclose(ptr);
    preorder(patientZero);
    deallocate(patientZero);
    return 0;
}