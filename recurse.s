.text

main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, num_prompt
    syscall
    #printing the prompt "Please enter an integer"

    li $v0, 5
    syscall
    move $t5, $v0
    #read the integer and put it into $t5

    move $a0, $t5
    jal f

    move $a0, $v0 #move v0 to a0 (the stuff to be printed)
    li $v0, 1 #code to print an integer
    syscall

    li $v0, 10
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4

jr $ra

 
f:
   #base case is correct
   bgt $a0, $0, recurse
   li $v0, 5
   jr $ra

recurse:
    addi $sp, $sp, -12 #store 3 registers to stack
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    #call f recursively
    add $s0, $a0, $s0
    addi $a0, $a0, -1 #pass argument via $a0, N-1
    jal f
    sw $v0,8($sp)

    li $t0, 2
    mul $v0, $v0, $t0 #2*f(N-1)
    sub $v0, $v0, $t0 #2*f(N-1)] -2

    li $t1, 4
    lw $a0, 4($sp) #retrive original value of N
    addi $a0, $a0, 1 #N+1
    mul $a0, $a0, $t1

    add $v0, $v0, $a0
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra


.data
    num_prompt: .asciiz "Please enter an integer: "
