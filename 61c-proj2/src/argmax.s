.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    bge x0 a1 error_len
    addi sp sp -8
    sw s0 0(sp)
    sw s1 4(sp)
    li s0 0
    li s1 0
    li t2 0

loop_start:
    slli t0 s0 2
    add t0 a0 t0
    lw t1 0(t0)
    bge t2 t1 loop_continue
    mv t2 t1
    mv s1 s0

loop_continue:
    addi s0 s0 1
    bge s0 a1 loop_end
    j loop_start

loop_end:
    # Epilogue
    mv a0 s1
    lw s0 0(sp)
    lw s1 4(sp)
    addi sp sp 8
    jr ra
    
error_len:
    li a0 36
    j exit
