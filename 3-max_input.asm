# Title: Lab3 assignment - Find the maximum with user input values
# Author: Jason Lin	
# Date:	 9/16/2016
# Description:	Save user input values in 'list.' Then sort the elements in 'list'  
# Date:

.data 
list:   .space  25 	# Use as array of integers
listsz: .word 5         # Size of array. Number of integers to be input by user.
prompt2: .asciiz "Please enter value  "
space: .asciiz "\n"

.text 
main:   
	lw $s0, listsz    # $s0 = array dimension 
	la $s1, list      # $s1 = array address 
	li $t0, 0         # $t0 = # elems input

	initlp:
		beq $t0, $s0, initdn	# Exit loop after all integers have been input.
	
		#------------------------------------------------
		li $v0, 4
		la $a0, prompt2	  # Print 'prompt2'
		syscall 


		#reads one integer from user and saves in memory
		li $v0,5	# Read integer input by user
		syscall
		move $a0, $v0
		sw   $a0, ($s1)     # Store the input value in the location at the address specified by the 'list' array. 

		#----------------------------------------------

		addi $s1, $s1, 4    # step to next array cell 
		addi $t0, $t0, 1    # count number of elements that have been input

		b    initlp


	initdn:

		jal bubble_sort
 	
		li $v0, 10	# Exit the program
		syscall
 
  
bubble_sort:
	#############################################################
	### Finish this subroutine and print out the sorted array ###
	#############################################################
	li $t1, 1	  # initialize $t1 (i) = 1
	lw $s0, listsz    # $s0 = array dimension (5)
	move $t0, $s0     # $t0 = n starts at 5
	la $s1, list      # $s1 = array address 
	move $t3, $s1     # $t3 = copy of beginning of array address (pointer to array cell) 
	
	outerloop:
		beqz $t0, printf # printf when reach end of outerloop
		li $t7, 0 # reset swapped to false
		li $t1, 1 # reset innerloop i = 1
		move $t3, $s1 # reset t3 = start of array (address)
		b innerloop # normal routine
	
	innerloop:
		beq $t1, $t0, endinner # endfor when i = n 
		lw $t4, 0($t3) # load A[i-1] from array
		lw $t5, 4($t3) # load A[i] from array
		bgt $t4, $t5, swap # if A[i-1] > A[i], then swap
	endif:  addi $t3, $t3, 4    # step to next array cell 
		addi $t1, $t1, 1 # increment i=i+1
		b	innerloop # innerloop: goto next iteration
		
 	endinner:
 		beqz $t7, printf # if swapped = true, print sorted array
 		subi $t0, $t0, 1 # decrement n = n-1
 		b	outerloop
 	
 	swap: 
 		sw $t5, 0($t3) # A[i-1] = A[i]
 		sw $t4, 4($t3) # A[i] = A[i-1]
 		li $t7, 1 # set swapped = true
 		b	endif 
 		
 	printf: 
 		la $t3, list     # (reset) $t3 = copy of beginning of array address (pointer to array cell) 
 		li $t7, 0	  # clear $t7 to be 0, $t7 = counter for numbers printed
 		b	printlp
 	
 	printlp:beq $t7,5,function_return # exit bubble_sort if we've printed 5 numbers
 		li $v0, 1 # print integer in $a0
 		lw $a0, ($t3) # load integer from array to $a0
 		syscall
 		li $v0, 4 #print string with memory address
 		la $a0, space
 		syscall
 		addi $t3, $t3, 4 # steps to address of next element in array
 		addi $t7, $t7, 1 # adding 1 to counter
 		b	printlp
 		
 
	function_return:  jr $ra
 
 # the following is the sudo code for bubble sort

  #repeat
  #     swapped = false
  #     for i = 1 to n-1 inclusive do
  #        if A[i-1] > A[i] then
  #           swap(A[i-1], A[i])
  #           swapped = true
  #        end if
  #     end for
  #     n = n - 1
  #  until not swapped

 
