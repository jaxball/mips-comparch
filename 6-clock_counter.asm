# Title: 	Lab6 assignment - Clock Counter
# Description:	this is a template file for lab6

.kdata	

s1:	.word 10
s2:	.word 11


PrintAskedPrompt:   .asciiz "Print Asked: "	# Prints the prompt ---> Print Asked
putColonInString:   .asciiz ":"			# Column printed ---> :
NumberOfTimesPropmpt:   .asciiz " time. Time is "   # Prints the prompt ---> time. Time is (followed by the time here)
NumberOfLinesOutput:   .asciiz "\n"		 # Prints out the new line
Sayhi: .asciiz "helloworld" 


.data


KeyboardData: .word 0xffff0004
KeybordStatus: .word 0xffff0000

.text


 triggerInterrupt:			
	lw $t5, KeyboardData		
	lw $t3, KeybordStatus		
	
	
	mfc0 $a0, $12			
	ori $a0, 0xff11			
	mtc0 $a0, $12			
	
	lui $t0, 0xFFFF			
	ori $a0, $0, 2
	sw $a0, 0($t0)		


 outerLoop:
	addi $s3, $0, 0 

	loop:
	    addi $s3, $s3, 1
	    bge $s3, 2, secondsPlusPlus 
	    j loop

main:
	li $s1, 0
	j triggerInterrupt
	
    
secondsPlusPlus:
	addi $s3, $0, 0		
	addi $s7, $s7, 1	
	beq $s7, 60, minutesPlusPlus
	j outerLoop


minutesPlusPlus:
	addi $s7, $0, 0		
	addi $s4, $s4, 1	
	beq $s4, 60, hoursPlusPlus
	j outerLoop

	
hoursPlusPlus:
	addi $s4, $0, 0		
	addi $t6, $t6, 1	
	beq $t6, 24, daysPlusPlus
	j outerLoop

	
daysPlusPlus:
	addi $t6, $0, 0
	addi $t7, $t7, 1			
	beq $t7, 20, triggerOutputExc 	
	j outerLoop
 
triggerOutputExc:

	addi $s5, $0, 5
	teqi $0, 0
	j outerLoop
  	 	 	
.ktext 0x80000180

   	bge $s5, 3, setCounterToZero
	lw $s2, 0($t5)	# keyboard display
	beq $s2, 49, display

kdone:   
	
   	mtc0 $0, $13			# Clear Cause register
	mfc0 $k0, $12			# Set Status register
	andi $k0, 0xfffd		# clear EXL bit
	ori  $k0, 0x11			# Interrupts enabled
	mtc0 $k0, $12			# write back to status

	lw $v0, s1				# Restore other registers
	lw $a0, s2

	.set noat				# tell the assembler not to use $at
	move $at, $k1			# Restore $at
	.set at					# tell the assembler okay to use $at

	eret					# return to EPC


display:

	la $a0, PrintAskedPrompt
	jal outputString
	add $a0, $0, $s1
	jal print
	la $a0, NumberOfTimesPropmpt
	jal outputString
	

	jal oD
	la $a0, putColonInString
	jal outputString
	

	jal oH
	la $a0, putColonInString
	jal outputString
	
	jal oM
	la $a0, putColonInString
	jal outputString
	
	jal oS
	la $a0, NumberOfLinesOutput
	jal outputString
	
	addi $s1, $s1, 1
	beqz $0, kdone
	
	
setCounterToZero:
   	addi $t7, $0, 0 	
   	addi $t6, $0, 0 	
   	addi $s4, $0, 0		
   	addi $s7, $0, 0 

   	addi $s5, $0, 0 	
   	
   	j kexceptdone


outputString:
	li $v0, 4		
	syscall			
	jr $ra			
	
print:
	li $v0, 1
	syscall
	jr $ra
	
oD:

	add $a0, $s0, $t7
	add $t1, $ra, $0
	
	jal print
	jr $t1
	
oH:

	add $a0, $s0, $t6
	add $t1, $ra, $0
	
	jal print
	jr $t1
	
oM:

	add $a0, $s0, $s4
	add $t1, $ra, $0
	
	jal print
	
	jr $t1
	
oS:

	add $a0, $s0, $s7
	add $t1, $ra, $0
	
	jal print
	jr $t1
	
kexceptdone:

	mtc0 $0, $13			# Clear Cause register
	mfc0 $k0, $12			# Set Status register
	andi $k0, 0xfffd		# clear EXL bit
	ori  $k0, 0x11			# Interrupts enabled
	mtc0 $k0, $12			# write back to status

	.set noat				# tell the assembler not to use $at
	move $at, $k1			# Restore $at
	.set at					# tell the assembler okay to use $at

	# this part for restoring exception
	mfc0 $k0,$14   
   	addi $k0,$k0,4
   	mtc0 $k0,$14 
   	
	eret
