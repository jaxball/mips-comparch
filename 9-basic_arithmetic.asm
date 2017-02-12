# Title: 	Lab9 assignment
# Author:	Jason Lin
# Description:	Write an assembly program that decodes and executes MIPS ALU instructions (ADD, SUB, AND, OR)
# Date:		2016/11/4

.data
# PC/INS (4 32-bit)
instructions: .word 0x20430190, 0x8c440000, 0x20420004, 0x1443fffd	# | ADD $3,$1,$2 | AND $4,$1,$2 | OR $5,$1,$2 | SUB $6,$1,$2
# Register (0~31)
registers: .word 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32 # lab8 registers
intRegFile: .word 0,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31 # lab9 registers
dataMemory: .word 20,15,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
space: .asciiz " "

.text
# Fetch
# Load from PC load to some registers
	li $t0, 8
	la $t1, instructions

# Second, before simulating the instruction stream loaded in instructionMemory, explicitly write/save the address of dataMemory into intRegFile[10] 	
	la $t5, intRegFile
	la $t6, dataMemory
	addi $t5, $t5, 40	# intRegFile[10] -- intRegFile + 4*10 
	sw $t6, ($t5)
# Decode
# determine source & dest registers & source codes (right shift/AND/OR)
	# andi $t1, $a0, 0x3e00000	# source1
	# andi $t2, $a0, 0x1f0000	# source2
	# andi $t3, $a0, 0xf800		# dest
loadInstruc:
	lw $t2, ($t1)
	
	srl $t3, $t2, 26
	andi $t3, $t3, 0x3f	# Lab9 - mask for most significant 6 bits
	beqz $t3, caseArithmetic	# load rs, rt, rd in cases of Load/BnNE/Addi, or jump to arithmetic cases
	
	# load source0c
	srl $t3, $t2, 21
	andi $t3, $t3, 0x1f
	
	# t5 -- source0c address	
	move $t4, $t3
	la $t5, intRegFile
loadSource0c:
	addi $t5, $t5, 4	# t5 -- source0(c) address	
	subi $t4, $t4, 1
	bgtz $t4, loadSource0c	
	lw $t5, ($t5)		# t5 -- source0(c) value
	
	# load dest0c
	srl $t3, $t2, 16
	andi $t3, $t3, 0x1f
	
	# t6 -- dest0c address
	move $t4, $t3		# t4 -- temporary iterator store
	la $t7, intRegFile
	
loadDest0c:
	addi $t7, $t7, 4
	subi $t4, $t4, 1
	bgtz $t4, loadDest0c
	#lw $t7, ($t7)		# t7 -- source1	value	
	
	# load immediate
	andi $t6, $t2, 0xffff	# masking for lower 16 bits, $t3 = immediate value
	
	# determine operation
	srl $t3, $t2, 26
	andi $t3, $t3, 0x3f	# Lab9 - mask for most significant 6 bits
	beq $t3, 0x23, LOAD
	beq $t3, 0x5, BNE
	beq $t3, 0x8, ADDI	
	
caseArithmetic:
	# load source1
	srl $t3, $t2, 21
	andi $t3, $t3, 0x1f
	
	# t5 -- source1	address	
	move $t4, $t3
	la $t5, intRegFile
	
loadSource1:
	addi $t5, $t5, 4	# t5 -- source1	address	
	subi $t4, $t4, 1
	bgtz $t4, loadSource1	
	lw $t5, ($t5)		# t5 -- source1	value
	
	# load source2
	srl $t3, $t2, 16
	andi $t3, $t3, 0x1f
	
	# t6 -- source2 address
	move $t4, $t3		# t4 -- temporary iterator store
	la $t6, intRegFile
	
loadSource2:
	addi $t6, $t6, 4
	subi $t4, $t4, 1
	bgtz $t4, loadSource2
	lw $t6, ($t6)		# t6 -- source1	value	
	
	# load dest
	srl $t3, $t2, 11
	andi $t3, $t3, 0x1f
	
	# t7 -- dest address
	move $t4, $t3
	la $t7, intRegFile
	
loadDest:
	addi $t7, $t7, 4
	subi $t4, $t4, 1
	bgtz $t4, loadDest	# t7 -- destination address
	
	# determine operation
	andi $t3, $t2, 0x3f	# using AND 111111 to mask higher bits of instruction
	beq $t3, 0x25, OR
	beq $t3, 0x24, AND
	beq $t3, 0x20, ADD
	beq $t3, 0x22, SUB
	

# Execute
# load data from memory location register
# OR
OR: 	
	or $t8, $t5, $t6	# t8 -- result value
	j Write
# AND
AND: 
	and $t8, $t5, $t6
	j Write
# ADD
ADD: 
	add $t8, $t5, $t6
	j Write
# SUB
SUB:
	sub $t8, $t5, $t6
	j Write	 	# $t8 <-- $t7
	
# Lab 9 complex instructions
# LOAD
LOAD: 	
	la $t5, intRegFile
	addi $t5, $t5, 40	# get effective address of datamemory
	lw $t5, ($t5)	
	add $t5, $t5, $t6	# compute new effective address
	lw $t8, ($t5)	# t8 -- (rs + #Imm)
	j Write
# BNE
BNE: 
	lw $t3, ($t7)	# get value of rt
	#addi $t6, $t6, 1
	bne $t5, $t3, Skip	# t7 -- source1	value
	j Write
	#bne $t5, $t3, GetIP 
# ADDI 
ADDI:
	add $t8, $t5, $t6
	j Write
	
# Write
# store to dest register

Skip: 
	subi $t0, $t0, 1
	addi $t1, $t1, 4
	subi $t6, $t6, 1
	bgtz $t6, Skip
	b	loadInstruc

Write:	
	sw $t8, ($t7)
	
	subi $t0, $t0, 1
	addi $t1, $t1, 4
	# check if back to loop for next instruction
	bgtz $t0, loadInstruc
	
	# print all registers
	li $t0, 32
	la $t2, intRegFile
	
printReg:
	lw $t3, ($t2)
	li $v0, 1
	move $a0, $t3
	syscall
	li $v0, 4
	la $a0, space
	syscall
	
	addi $t2, $t2, 4
	subi $t0, $t0, 1
	
	bgtz  $t0, printReg
	
Exit:
	li $v0, 10
	syscall
