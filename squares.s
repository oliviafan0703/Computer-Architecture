.text

main:
    li $v0, 4
    la $a0, num_prompt
    syscall
    #printing the prompt

    li $v0, 5
    syscall
    move $t5, $v0

    mul $s0 $t5, $t5

    li $v0, 1 #code to print an integer
    move $a0, $s0 #move t0 to a0 (the stuff to be printed)
    syscall

jr $ra

.data
    num_prompt: .asciiz "Please enter an integer: "
