.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    # Prologue
    
    mv s1 a1
    mv s2 a2
    mv s3 a3
    li s4 0
    
    # open file
    li a1 1
    jal fopen

    li t0 -1
    beq t0 a0 error_27
    mv s0 a0
    
    # write num rows in file 
    mv a0 s0
    sw s2 24(sp)
    addi a1 sp 24
    li a2 1
    li a3 4
    jal fwrite
    
    li t0 1
    bne a0 t0 error_30
    
    # write num cols in file   
    mv a0 s0
    sw s3 24(sp)
    addi a1 sp 24
    li a2 1
    li a3 4
    jal fwrite
    
    li t0 1
    bne a0 t0 error_30
    
    # write matrix elements
    mul s4 s2 s3
    mv a0 s0
    mv a1 s1
    mv a2 s4
    li a3 4
    jal fwrite
    
    bne a0 s4 error_30

    # close file
    mv a0 s0
    jal fclose
     
    bne a0 x0 error_28  
    
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    addi sp sp 28
    jr ra

error_27:
    li a0 27
    j exit
    
error_30:
    li a0 30
    j exit
    
error_28:
    li a0 28
    j exit
    
