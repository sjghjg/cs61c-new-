.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    bge x0 a1 error_38
    bge x0 a2 error_38
    bge x0 a4 error_38
    bge x0 a5 error_38
    bne a2 a4 error_38
    # Prologue
    addi sp sp -40
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw ra 36(sp)
   
    mv s1 a0        # address first input arr pointer
    mv s7 a1
    mv s8 a5
    mv s3 a3        # address second input arr pointer
    mv s5 a4        # output row/col
    mv s6 a6        # output memorry address pointer
    li s0 0         # count first arr pointer 
    li s4 0         # index output
    li s2 0         # count second arr pointer


    
outer_loop_start:
    # first arr pointer
    slli t1 s0 2
    add t1 t1 s1
    mv a0 t1
    # second arr pointer
    slli t3 s2 2
    add t3 t3 s3
    mv a1 t3
    
    mv a2 s5
    li a3 1
    mv a4 s8

inner_loop_start:
    # j and link to dot
    jal dot
    # store value to output matrix
    slli t4 s4 2
    add t4 t4 s6
    sw a0 0(t4)
    addi s4 s4 1
    # adjust count input arr pointer 
    addi s2 s2 1
    blt s2 s8 outer_loop_start

inner_loop_end:
    li s2 0
    add s0 s0 s5
    addi s7 s7 -1
    bgt s7 x0 outer_loop_start

outer_loop_end:
    
    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw ra 36(sp)
    addi sp sp 40
    jr ra

error_38:
    li a0 38
    j exit