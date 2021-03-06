# Title: 	Lab4 assignment - Stack and number system change
# Author: 	Jason Lin
# Description:	Use stack and function call to implement number system change
# Date:         9/16/2016

.data 
listsz: .word 10         # Size of array. Number of integers to be input by user.
prompt1: .asciiz "Please enter decimal value: "
prompt2: .asciiz "Please enter system, 2 for binary, 8 for octal: "
prompt3: .asciiz "Invalid system, only binary and octal are allowed!\n"
prompt4: .asciiz "DEBUG: stack size = \n"
before: .asciiz "input to stack (reverse): "
after: .asciiz "Converted base: "
newline: .asciiz "\n"

.text 
main:
 	mfc0 $a0, $12			# read from the status register
	ori $a0, 0xff11			# enable all interrupts
	mtc0 $a0, $12			# write back to the status register

	lui $t0, 0xFFFF			# $t0 = 0xFFFF0000;
	ori $a0, $0, 2			# enable keyboard interrupt
	sw $a0, 0($t0)			# write back to 0xFFFF0000;
	
	# CONCLUDES INITIAL SETUP TO ENABLE INTERRUPTS #
 	
	li $s0, 2         # $s0 = 2, represents binary 
	li $s1, 8         # $s1 = 8, represents octal
	
	menu:
	
		li $v0, 4
		la $a0, prompt1	  # Print 'prompt1'
		syscall 
		
		li $v0,5	# Read decimal integer input by user
		syscall
		move $s2, $v0   # stor the decimal integer input to $s2
	
	choicelp:
	
		li $v0, 4
		la $a0, prompt2	  # Print 'prompt2'
		syscall 
		
		li $v0,5	# Read integer input by user, decides to be binary or octal
		syscall
		move $t0, $v0 
		
		# initialize setup
		addi $t7, $0, 0 # $t7 = size of stack (begin: 0)
		move $t1, $s2 # $t1 = $s2
		
		
		li $v0, 4 	# print "Decimal input: "
		la $a0, before
		syscall
		
		beq $t0, $s0, BinOct # if binary
		beq $t0, $s1, BinOct # if octal

		li $v0, 4 # otherwise, output error message and wait until a correct input
		la $a0, prompt3
		syscall

		b    choicelp
				
	BinOct:
		###########################################################################
		##    use stack to implement number system change                       ###
		###########################################################################
		
		# $t0 = base number we use to divide 
		
		beqz $t1, printStack  #if quotient is 0, we are done with dividing 
		div $t1, $t0 # divide decimal integer input by base
		mflo $t1 # move quotient to $t1
		mfhi $t2 # move remainder to $t2
		#beqz $t1, printStack  #if quotient is 0, we are done with dividing 
		

		#li $v0, 4
		#la $a0, prompt5
		#syscall
		#li $v0, 1 
		#move $a0, $t2
		#syscall
		
		
		
		subi $sp, $sp, 4 # decrement stack pointer by 4
		sw $t2, 0($sp) # save remainder to stack
		lw $t5, 0($sp) 
		
		li $v0, 1
		move $a0, $t5
		syscall
		
		addi $t7, $t7, 1 # increment size of stack by 1
		b	BinOct # load all digits in stack first then print out at once
	printStack: 	
		li $v0, 4	 
		la $a0, newline
		syscall 
		
		li $v0, 4	 # print: "Converted base: "
		la $a0, after
		syscall 
		move $t5, $t7 # backup size of stack
		jal Print
 				
 				  
		li $v0, 10	# Exit the program
		syscall

 
  Print:
  	    ###########################################################################
		##    use stack and function call to printout the result                ###   
		###########################################################################
		
		beqz $t7, function_return # if stack size is 0: return 
		lw $t3, 0($sp) # store first element (last added) of stack to $t3 
		addi $sp, $sp, 4 # increment stack pointer by 4 (popping element)
		subi $t7, $t7, 1 # decrement size of stack by 1
		
		li $v0, 1 # print_int
		move $a0, $t3 # move first element of stack to $a0
		syscall 

		
		b 	Print
		
		
		
		
function_return: jr $ra # $ra should be in binOct
		
		
