.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    bge x0 a3  error_stride
    bge x0 a4 error_stride
    # Prologue
    bge x0 a2 error_len
    addi sp sp -8
    sw s0 0(sp)
    sw s1 4(sp)
    # total_iterate
    li s0 0
    #output
    li s1 0
    #frst_arr_item_address
    li t2 0
    #scnd_arr_item_address
    li t3 0

loop_start:
    mul t0 a3 s0
    mul t1 a4 s0
    slli t2 t0 2
    slli t3 t1 2
    add t0 t2 a0
    add t1 t3 a1
    lw t4 0(t0)
    lw t5 0(t1)
    mul t6 t4 t5
    add s1 s1 t6
    addi s0 s0 1
    blt s0 a2 loop_start

loop_end:
    # Epilogue
    mv a0 s1
    lw s0 0(sp)
    lw s1 4(sp)
    addi sp sp 8
    jr ra
    
error_stride:
    li a0 37
    j exit
    
error_len:
    li a0 36
    j exit
