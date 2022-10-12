.text
.align 2

# $a0 = dest, $a1 = src
strcpy:
	lb $t0, 0($a1)
	beq $t0, $zero, done_copying
	sb $t0, 0($a0)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j strcpy

	done_copying:
	jr $ra

# $a0 = string buffer to be zeroed out
strclr:
	lb $t0, 0($a0)
	beq $t0, $zero, done_clearing
	sb $zero, 0($a0)
	addi $a0, $a0, 1
	j strclr

	done_clearing:
	jr $ra

# $a0, $a1 = strings to compare
# $v0 = result of strcmp($a0, $a1)
strcmp:
	lb $t0, 0($a0)
	lb $t1, 0($a1)

	bne $t0, $t1, done_with_strcmp_loop
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, strcmp
	li $v0, 0
	jr $ra
		

	done_with_strcmp_loop:
	sub $v0, $t0, $t1
	jr $ra

# add a new node
newnode:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)

    move $s2, $a0 #move the pointer from #a0 to $s2; a0= pointer to name
    #allocate memory for new node
    li $a0, 24 #need 24 bytes for a new nde
    li $v0, 9
    syscall #dynamically allocate memory

    move $s1, $v0 #move the $v0 (struct) into $s1
    #call helper function to move data from $a0 to inside the struct
    move $a0, $s1 #destination
    move $a1, $s2 #move name to $a1
    jal strcpy

    #sw $s2, 0($s1) #node->value = value of string from strcpy

    sw $0, 16($s1) #patientNode-> left = NULL;
    sw $0, 20($s1) #patientNode-> right = NULL;

    move $v0, $s1

    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12

    jr $ra #return patientNode;

#recursive function to find parent of the given node
#check to see if current string matches the one pass the method
#pass the method two arguments, a string and the node to start searching from
#store the parent name in the buffer, go through the tree recursively
#to find the parent with strcmp

findparent:
    addi $sp, $sp, -4 #store 3 registers to stack
    sw $ra, 0($sp)
    
    

    # base case
    # if (root == NULL) return NULL;
    move $t8, $a0 #the node
    move $t9, $a1 #the name string
    bne $t8, $0, findparentnotnull
        move $v0, $0
        j exit
    findparentnotnull:

    #compare two strings to see if they are equal
    move $a0, $t8 #root->name
    move $a1, $t9
    addi $sp, $sp, -8
    sw $t8, 0($sp)
    sw $t9, 4($sp)
    jal strcmp #if(strcmp(root->name, parent)==0, return)
    lw $t8, 0($sp)
    lw $t9, 4($sp)
    addi $sp, $sp, 8

    beq $v0, $0, returnroot
        lw $a0, 16($t8) #struct node* left = findParent(root->left, parent string);
        move $a1, $t9
        addi $sp, $sp, -8
        sw $t8, 0($sp)
        sw $t9, 4($sp)
        jal findparent
        lw $t8, 0($sp)
        lw $t9, 4($sp)
        addi $sp, $sp, 8

        move $t0, $v0

        lw $a0, 20($t8) #struct node* right = findParent(root->right, parent string);
        move $a1, $t9
        addi $sp, $sp, -12
        sw $t8, 0($sp)
        sw $t9, 4($sp)
        sw $t0, 8($sp)
        jal findparent
        lw $t8, 0($sp)
        lw $t9, 4($sp)
        lw $t0, 8($sp)
        addi $sp, $sp, 12

        move $t1, $v0

        #return left == NULL ? right : left)
        beq $t0, $0, returnright
            move $v0, $t0 #return the left node
            j exit
        returnright:
            move $v0, $t1 #return the right node
            j exit
    returnroot:
        move $v0, $t8
        j exit


    exit:
        #put back the stack
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra #return root


#printing the tree preorder
preorder:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s4, 4($sp)
    sw $s5, 8($sp)

    move $s4, $a0  #$s4 is the node we're currently at
    bne $s4, $0, notnull #if (root == NULL) return NULL;
        move $v0, $0
        j doneprinting
    
    notnull:
    #syscall to print the string
    print:
    li $v0, 4
    move $a0, $s4
    syscall

    lw $s5, 16($s4) #node->left
    move $a0, $s5 #preorder(node->left)
    jal preorder

    lw $s5, 20($s4) #node->right
    move $a0, $s5 #preorder(node->right)
    jal preorder

    doneprinting:
    lw $ra, 0($sp) #pop the stack when done
    lw $s4, 4($sp)
    lw $s5, 8($sp)
    addi $sp, $sp, 12
    jr $ra


main:
    # uses $s3 to store Root Node
    #creating the first node (BlueDevil)

    la $a0, devil
    jal newnode
    move $s3, $v0

    inputloop: #start input

        #print the prompt "Please enter patient: "
        li $v0, 4
        la $a0, patient_prompt
        #syscall

        #read the string and put it into patient
        li $v0, 8
        la $a0, patient
        li $a1, 16 #buffer to store the string
        syscall
        la $s0, patient #store patient in $s0

        move $t7, $s0
        move $a1, $t7
        la $a0, done
        addi $sp, $sp, -4
        sw $t7, 0($sp)
        jal strcmp
        lw $t7, 0($sp)
        addi $sp, $sp, 4
        beq $v0, $0, exitandprint #if (strcmp(infected,"DONE")==0 {break;}

        #printing the prompt "Please enter an infecter: "
        li $v0, 4
        la $a0, infecter_prompt
        #syscall

        #read the string and put it into infecter
        li $v0, 8
        la $a0, infecter
        li $a1, 16
        syscall
        la $s1, infecter #store infecter in $s1


        move $a0, $s3 #load arg patientZero
        move $a1, $s1 #load arg infecter
        addi $sp, $sp, -4
        sw $t7, 4($sp)
        jal findparent #findParent (patientZero, infecter)
        lw $t7, 4($sp)
        addi $sp, $sp, 4

        move $t3, $v0 # $t3 struct node* parent = findParent (patientZero, infecter)

        move $a0, $s0 #load arg patient

        addi $sp, $sp, -12
        sw $t7, 0($sp)
        sw $t3, 4($sp)
        sw $t4, 8($sp)
        jal newnode #newNode(patient)
        lw $t7, 0($sp)
        lw $t3, 4($sp)
        lw $t4, 8($sp)
        addi $sp, $sp, 12

        move $t4, $v0 #$t4 struct node* newPatient = newNode(infected)

        lw $s5, 16($t3) #$s5 parent->left
        beq $s5, $0, addtotree #if (parent->left == NULL)
            #else 
            move $a0, $s0 #loads arg patient
            move $a1, $s5 #parent->left -> name

            

            addi $sp, $sp, -12
            sw $t7, 0($sp)
            sw $t3, 4($sp)
            sw $t4, 8($sp)
            jal strcmp
            lw $t7, 0($sp)
            lw $t3, 4($sp)
            lw $t4, 8($sp)
            addi $sp, $sp, 12

            

            blt $v0, $0, switchchildren #if (strcmp(infected, parent->left->name)<0)
                                        #if the new node is alphabetically smaller than the child already existed
                                        #swap it with the one already existed
                                #else
                sw $t4, 20($t3) #parent-> right = newPatient;
           
                j dontaddtotree
            switchchildren:
                lw $t6, 16($t3) #$t6 struct node* child = parent->left; $t6 = child
                sw $t4, 16($t3) #parent->left = newPatient;
                sw $t6, 20($t3) #parent->right = child;

               
                j dontaddtotree

        #parent -> left = newPatient;
        addtotree:
        sw $t4, 16($t3) #parent-> left = newPatient
     
        dontaddtotree:

        j inputloop
    
    #preorder print the tree
    exitandprint:
    move $a0, $s3
    
    jal preorder;

    li $v0, 10
    syscall
    

.data
.align 2
    patient_prompt: .asciiz "Please enter patient: "
    infecter_prompt: .asciiz "Please enter infecter: "
    devil: .asciiz "BlueDevil\n"
    patient: .space 16
    infecter: .space 16
    done: .asciiz "DONE\n"
    
    left_child_print: .asciiz "Added as Left Child\n"
    right_child_print: .asciiz "Added as Right Child\n"
    switch_child_print: .asciiz "Switched Positions with Left Child\n"

