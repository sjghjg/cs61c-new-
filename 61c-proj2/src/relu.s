.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    bge x0 a1 error_len
    addi sp sp -8
    sw s0 0(sp)
    sw s1 4(sp)
    li s0 0

loop_start:
    slli t0 s0 2
    add t0 a0 t0
    lw s1 0(t0)
    bge s1 x0 loop_continue
    sw x0 0(t0)

loop_continue: 
    addi s0 s0 1
    blt s0 a1 loop_start

loop_end:
    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    addi sp sp 8
    jr ra
    
error_len:
    li a0 36
    j exit
    
