.globl classify



.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

classify:
    li t0 5
    bne a0 t0 error_31
    addi sp sp -52
    sw s0 0(sp)
    sw s1 4(sp)

    sw s2 8(sp)

    sw s3 12(sp)

    sw s4 16(sp)

    sw s5 20(sp)

    sw s6 24(sp)

    sw s7 28(sp)

    sw s8 32(sp)

    sw s9 36(sp)

    sw s10 40(sp)

    sw s11 44(sp)

    sw ra 48(sp)

    

    li s0 0

    lw s1 4(a1)

    lw s2 8(a1)

    lw s3 12(a1)

    lw s4 16(a1)

    mv s5 a2

    li t0 0

    

    # Read pretrained m0

    mv a0 s1

    

    addi a1 sp 8

    addi a2 sp 12

    jal read_matrix

    

    lw s6 8(sp)

    lw s7 12(sp)

    mv s1 a0

    # Read pretrained m1

    mv a0 s2

    

    addi a1 sp 12

    addi a2 sp 16

    jal read_matrix

    

    lw s8 12(sp)

    lw s9 16(sp)

    mv s2 a0

    # Read input matrix

    mv a0 s3

    

    addi a1 sp 16

    addi a2 sp 20

    jal read_matrix



    lw s10 16(sp)

    lw s11 20(sp)

    mv s3 a0

    # Compute h = matmul(m0, input)

    mul s0 s6 s11

    slli t0 s0 2

    mv a0 t0

    jal malloc

    beqz a0 error_26

    mv a6 a0

    

    mv a0 s1

    mv a1 s6

    mv a2 s7

    mv a3 s3

    mv a4 s10

    mv a5 s11

    jal matmul



    # Compute h = relu(h)

    mv a0 a0

    mv a1 s0

    jal relu

    mv s1 a0

    # Compute o = matmul(m1, h)

    mul s0 s8 s11

    li t0 0

    slli t0 s0 2

    mv a0 t0

    jal malloc

    beqz a0 error_26

    mv a6 a0

    

    mv a3 s1

    mv a0 s2

    mv a1 s8

    mv a2 s9

    mv a4 s6

    mv a5 s11

    jal matmul

    

    # Write output matrix o

    mv a1 a0

    mv a0 s4

    mv a2 s0

    mv a3 s8

    jal write_matrix



    # Compute and return argmax(o)

    mv a1 s0

    jal argmax



    lw s0 0(sp)

    lw s1 4(sp)

    lw s2 8(sp)

    lw s3 12(sp)

    lw s4 16(sp)

    lw s5 20(sp)

    lw s6 24(sp)

    lw s7 28(sp)

    lw s8 32(sp)

    lw s9 36(sp)

    lw s10 40(sp)

    lw s11 44(sp)

    lw ra 48(sp)

    addi sp sp 52

    # If enabled, print argmax(o) and newline   

    bne x0 s5 return_none

    

    jal print_int

    li a0 10

    jal print_char

    

    jr ra   

error_31:

    li a0 31

    j exit



error_26:

    li a0 26

    j exit



return_none:

    jr ra