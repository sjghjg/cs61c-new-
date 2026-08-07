.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp sp -24
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw ra 20(sp)
    
    mv s0 a0
    mv s1 a1
    mv s2 a2
    
    # open file
    mv a0 s0
    li a1 0
    jal fopen
    mv s0 a0
    
    li t0 -1
    beq t0 a0 error_27
    
    # read rows
    mv a0 s0 
    mv a1 s1
    li a2 4
    jal fread
    
    li t0 4
    bne t0 a0 error_29
    
    # read cols
    mv a0 s0
    mv a1 s2
    li a2 4
    jal fread
    
    li t0 4
    bne t0 a0 error_29
    
    # allocate heap memorry
    lw t1 0(s1)
    lw t2 0(s2)
    mul s3 t1 t2
    slli s3 s3 2
    mv a0 s3
 
    jal malloc
    
    beqz a0 error_26
    mv s4 a0

    # read matrix
    mv a0 s0 
    mv a1 s4
    mv a2 s3
    jal fread
    
    bne a0 s3 error_29
    
    #close file
    mv a0 s0 
    jal fclose
    bne x0 a0 error_28
    
    # Epilogue
    mv a0 s4
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw ra 20(sp)
    addi sp sp 24
    jr ra
    
error_27:
    li a0 27
    j exit
    
error_29:
    li a0 29
    j exit
    
error_26:
    li a0 26
    j exit
    
error_28:
    li a0 28
    j exit
