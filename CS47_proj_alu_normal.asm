.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
# frame store
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12

start: 
	beq $a2, 0x2b, start_add # goes to add 
	beq $a2, 0x2d, start_minus # goes to subtraction
	beq $a2, 0x2a, start_multiply # goes to multiplication 
	beq $a2, 0x2f, start_divide # goes to division 
      
start_add:  
	add $v0, $a0, $a1
	j end 

start_minus:
	sub $v0, $a0, $a1 
	j end 
start_multiply: 
	mul $v0, $a0, $a1
	mfhi $v1 
	j end
start_divide:
	div $a0, $a1 
	mflo $v0 
	mfhi $v1 
	j end 



end: 
#frame restore 
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12



	jr $ra
