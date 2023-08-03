.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it

	addi $sp, $sp, -52
	sw $fp, 52($sp)
	sw $ra, 48($sp)
	sw $a0, 44($sp)
	sw $a1, 40($sp)
	
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)

	addi $fp, $sp, 52

start: 
	beq $a2, 0x2b, start_add # goes to add 
	beq $a2, 0x2d, start_minus # goes to subtraction
	beq $a2, 0x2a, start_multiply # goes to multiplication 
	beq $a2, 0x2f, start_divide # goes to division 
      
start_add:  
	li $t9, 32 # for-loop upper bound 
	li $t8, 0 # loop index 
	li $s1, 0 # initalize first carry bit 
	li $v0, 0 # initalize return register 
	
for_start_add:	
	beq $t8, $t9, for_end_add
	
	srlv $t0, $a0, $t8 # shift right a by amount of for loop 
	andi $t0, $t0, 1 
	
	srlv $t1, $a1, $t8 # shift right b by amount of for loop 
	andi $t1, $t1, 1  # now the bit at ith position should be the first value of $t0 and $t1 
	
	
	xor $s0, $t0, $t1 # the bits for summation: a xor b 
	and $s3, $t0, $t1 # the bits for AB 
	xor $s2, $s0, $s1 # for Y: CI xor a xor b 
	and $t0, $s1, $s0 # for carryout: CI(A xor B) 
	or $s1, $t0, $s3 # for carryout: CI(A xor B) + AB 
	
	
	move $t2, $s2 # move Y to $t2
	sllv $t2, $t2, $t8 # shift it left by for loop index for insertion 
	or $v0, $v0, $t2 # combine current $v0 with shifted value 
	addi $t8, $t8, 1 # for loop counter ++ 
	j for_start_add

for_end_add: 
	j end 

start_minus:
	li $t9, 32 # for-loop upper bound 
	li $t8, 0 # loop index 
	li $s1, 1 # initalize first carry bit 
	li $v0, 0 # initalize return register 
	
for_start_minus:	
	beq $t8, $t9, for_end_minus
	
	srlv $t0, $a0, $t8 # shift right a by amount of for loop 
	andi $t0, $t0, 1 
	
	srlv $t1, $a1, $t8 # shift right b by amount of for loop 
	andi $t1, $t1, 1  # now the bit at ith position should be the first value of $t0 and $t1 
	xor $t1, $t1, 1 # xor with 1 to invert the bits
	
	
	xor $s0, $t0, $t1 # the bits for summation: a xor b 
	and $s3, $t0, $t1 # the bits for AB 
	xor $s2, $s0, $s1 # for Y: CI xor a xor b 
	and $t0, $s1, $s0 # for carryout: CI(A xor B) 
	or $s1, $t0, $s3 # for carryout: CI(A xor B) + AB 
	
	
	move $t2, $s2 # move Y to $t2
	sllv $t2, $t2, $t8 # shift it left by for loop index for insertion 
	or $v0, $v0, $t2 # combine current $v0 with shifted value 
	addi $t8, $t8, 1 # for loop counter ++ 
	j for_start_minus
	
for_end_minus:
	
	j end 
start_multiply: 
	li $s2, 0 # I = 0 
	li $s3, 0 # H = 0 
	move $s1, $a1 # L = Multiplier 
	move $s0, $a0 # M = Multiplicand 
	li $s7, 32 # for loop
	move $s6, $zero # for loop 
	extract_bit($t5, $s1, 31) # extract 31st bit of multiplier to check for negativity 
	extract_bit($t6, $s0, 31) # multiplicand 
	beq $t5, 1, invert_multiplier # if multiplier is negative, jump to invert_multiplier
	beq $t6, 1, invert_multiplicand # if multiplicand is negative, jump to invert_multiplicand 
	j for_start_multiply # nothing needs to be inverted, so jump to for loop
	
invert_multiplier: 
	lui $t2, 0xFFFF 
	ori $t2, $t2, 0xFFFF # t2 is now 0xFFFFFFFF
	xor $s1, $s1, $t2 # xor with 0xFFFFFFFF will invert all bits in the register
	move $a0, $s1  
	li $a1, 1 
	jal plus_logical_procedure
	move $s1, $v0 
	beq $t6, 1, invert_multiplicand # check to see if second number is also negative
	j for_start_multiply
invert_multiplicand: 
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xFFFF
	xor $s0, $s0, $t2 # invert bits of multiplicand
	move $a0, $s0  
	li $a1, 1 
	jal plus_logical_procedure
	move $s0, $v0 
for_start_multiply:
	beq $s7, $s6, for_end_multiply # for loop condition 
	replicate_bit($s4, $s1) # replicate the bit 
	and $s5, $s0, $s4 # X = M $ R 
	#addu $s3, $s3, $s5 # H = H + X 
	move $a0, $s3  
	move $a1, $s5
	jal plus_logical_procedure
	move $s3, $v0 
	srl $s1, $s1, 1 # L = L >> 1 
	extract_bit($t1, $s3, 0) # H[0]
	insert_bit($s1, $s1, $t1, 31) # L[31] = H[0] 
	srl $s3, $s3, 1 # H = H >> 1 
	addi $s6, $s6, 1 # index++ 
	j for_start_multiply
for_end_multiply: 
	xor  $t7, $t5, $t6 # $t5 and $t6 was the information about 
			   # the negativity of the multiplicand and multiplier. 
			   # XOR checks to see if product should be negative. 
	beq  $t7, 0, positive_product # If XOR resulted in 0, it should be positive. 
	xor $s1, $s1, $t2 # inverts Low  
	xor $s3, $s3, $t2 # inverts Hi 
	move $a0, $s1 
	li $a1, 1
	jal plus_logical_procedure
	move $s1, $v0 
	#addi $s1, $s1, 1 # adds one 
positive_product:
	move $v0, $s1 # transfer value to return 
	move $v1, $s3
	j end
start_divide:
	li $s7, 32 # for loop
	move $s6, $zero # for loop 
	move $s0, $a0 # $s0 = Q = DVND
	move $s1, $a1 # $s1 = D = DVSR 
	move $s2, $zero # initialize R = 0 
	
	extract_bit($t5, $s0, 31) # extract 31st bit of DVND to check for negativity 
	extract_bit($t6, $s1, 31) # DVSR  
	beq $t5, 1, invert_DVND # if DVND is negative, jump to invert_DVND
	beq $t6, 1, invert_DVSR # if DVSR is negative, jump to invert_DVSR 
	j for_start_divide # nothing needs to be inverted, so jump to for loop
	
invert_DVND: 
	lui $t2, 0xFFFF 
	ori $t2, $t2, 0xFFFF # t2 is now 0xFFFFFFFF
	xor $s0, $s0, $t2 # xor with 0xFFFFFFFF will invert all bits in the register 
	#addi $s0, $s0, 1 # add 1 
	move $a0, $s0  
	li $a1, 1 
	jal plus_logical_procedure
	move $s0, $v0
	beq $t6, 1, invert_DVSR # check to see if second number is also negative
	j for_start_divide
invert_DVSR: 
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xFFFF
	xor $s1, $s1, $t2 # invert bits of multiplicand
	#addi $s1, $s1, 1 # add 1 
	move $a0, $s1  
	li $a1, 1
	jal plus_logical_procedure
	move $s1, $v0 
for_start_divide: 
	beq $s7, $s6, for_end_divide
	sll $s2, $s2, 1 # R = R << 1 
	extract_bit($t1, $s0, 31) # $t1 = Q[31] 	
	insert_bit($s2, $s2, $t1, 0) # R[0] = Q[31] 
	sll $s0, $s0, 1 # Q = Q << 1 
	move $a0, $s2 # load these registers to call logical_minus 
	move $a1, $s1 
	jal minus_logical_procedure # S = R - D 
	move $s3, $v0 # this procedure puts return value into $v0, so extract it 
	bltz $s3, for_increase_divide # if S < 0, increase index 
	move $s2, $s3 # R = S 
	ori $s0, $s0, 1 # Q[0] = 1 
for_increase_divide:
	addi $s6, $s6, 1
	j for_start_divide
for_end_divide: 
	xor  $t7, $t5, $t6 # $t5 and $t6 was the information about 
			   # the negativity of the divisor and dividend. 
			   # XOR checks to see if quotient should be negative. 
	beq  $t7, 0, positive_quotient # If XOR resulted in 0, it should be positive. 
	lui $t2, 0xFFFF # $t2 was used before, so it needs to be reloaded
	ori $t2, $t2, 0xFFFF # t2 is now 0xFFFFFFFF
	xor $s0, $s0, $t2 # inverts Low  
	#addi $s0, $s0, 1 # adds one 
	move $a0, $s0  
	li $a1, 1 
	jal plus_logical_procedure
	move $s0, $v0
positive_quotient:
	beqz $t5, positive_remainder # checks to see if dividend was positive 
	lui $t2, 0xFFFF # dividend was not positive so convert remainder to negative 
	ori $t2, $t2, 0xFFFF # t2 is now 0xFFFFFFFF
	xor $s2, $s2, $t2
	#addi $s2, $s2, 1 
	move $a0, $s2  
	li $a1, 1 
	jal plus_logical_procedure
	move $s2, $v0
positive_remainder:
	move $v0, $s0 
	move $v1, $s2 
	j end 
end: 
#frame restore 
	
	lw $fp, 52($sp)
	lw $ra, 48($sp)
	lw $a0, 44($sp)
	lw $a1, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 52
	
	jr $ra 
	
	
minus_logical_procedure:  
	addi $sp, $sp, -44
	sw $fp, 44($sp)
	sw $ra, 40($sp)
	
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)

	addi $fp, $sp, 44

start_minus_procedure:
	li $t9, 32 # for-loop upper bound 
	li $t8, 0 # loop index 
	li $s1, 1 # initalize first carry bit 
	li $v0, 0 # initalize return register 
	
for_start_minus_procedure:	
	beq $t8, $t9, for_end_minus_procedure
	
	srlv $t0, $a0, $t8 # shift right a by amount of for loop 
	andi $t0, $t0, 1 
	
	srlv $t1, $a1, $t8 # shift right b by amount of for loop 
	andi $t1, $t1, 1  # now the bit at ith position should be the first value of $t0 and $t1 
	xor $t1, $t1, 1 # xor with 1 to invert the bits
	
	
	xor $s0, $t0, $t1 # the bits for summation: a xor b 
	and $s3, $t0, $t1 # the bits for AB 
	xor $s2, $s0, $s1 # for Y: CI xor a xor b 
	and $t0, $s1, $s0 # for carryout: CI(A xor B) 
	or $s1, $t0, $s3 # for carryout: CI(A xor B) + AB 
	
	
	move $t2, $s2 # move Y to $t2
	sllv $t2, $t2, $t8 # shift it left by for loop index for insertion 
	or $v0, $v0, $t2 # combine current $v0 with shifted value 
	addi $t8, $t8, 1 # for loop counter ++ 
	j for_start_minus_procedure
	
for_end_minus_procedure:
	
	lw $fp, 44($sp)
	lw $ra, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 44
	
	jr $ra 
	
plus_logical_procedure: 

	addi $sp, $sp, -48
	sw $fp, 48($sp)
	sw $ra, 44($sp)
	sw $a3, 40($sp)
	sw $s0, 36($sp)
	sw $s1, 32($sp)
	sw $s2, 28($sp)
	sw $s3, 24($sp)
	sw $s4, 20($sp)
	sw $s5, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)

	addi $fp, $sp, 48

start_add_procedure:  
	li $s7, 32 # for-loop upper bound 
	li $s6, 0 # loop index 
	li $s1, 0 # initalize first carry bit 
	li $v0, 0 # initalize return register 
	
for_start_add_procedure:	
	beq $s6, $s7, for_end_add_procedure
	
	srlv $s5, $a0, $s6 # shift right a by amount of for loop 
	andi $s5, $s5, 1 
	
	srlv $s4, $a1, $s6 # shift right b by amount of for loop 
	andi $s4, $s4, 1  # now the bit at ith position should be the first value of $t0 and $t1 
	
	
	xor $s0, $s5, $s4 # the bits for summation: a xor b 
	and $s3, $s5, $s4 # the bits for AB 
	xor $s2, $s0, $s1 # for Y: CI xor a xor b 
	and $s5, $s1, $s5 # for carryout: CI(A xor B) 
	or $s1, $s5, $s3 # for carryout: CI(A xor B) + AB 
	
	
	move $a3, $s2 # move Y to $t2
	sllv $a3, $a3, $s6 # shift it left by for loop index for insertion 
	or $v0, $v0, $a3 # combine current $v0 with shifted value 
	addi $s6, $s6, 1 # for loop counter ++ 
	j for_start_add_procedure 

for_end_add_procedure: 
	lw $fp, 48($sp)
	lw $ra, 44($sp)
	lw $a3, 40($sp)
	lw $s0, 36($sp)
	lw $s1, 32($sp)
	lw $s2, 28($sp)
	lw $s3, 24($sp)
	lw $s4, 20($sp)
	lw $s5, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 48
	
	jr $ra 
































