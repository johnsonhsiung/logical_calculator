# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	.macro extract_bit($tar, $reg, $arg) #goes into $t0 
	srl $tar, $reg, $arg # shift right $reg by amount $arg 
	andi $tar, $tar, 1 
	.end_macro 
	
	.macro insert_bit($tar, $ins_tar, $reg, $arg) # uses $t0 
	sll $t0, $reg, $arg 
	or $tar, $t0, $ins_tar
	.end_macro 
	
	.macro replicate_bit($tar, $reg)
	andi $t0, $reg, 1 
	beq $t0, $zero, replicate_zero 
	li $tar, 0xFFFFFFFF
	j end 
	replicate_zero: 
	move $tar, $zero 
	end: 
	.end_macro 
	

	
	
	
	




