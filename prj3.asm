#Group 4
#Marcus Ensley 1547206 456Frodo

.data
zeroFloat: .float 0.0
endString: .asciiz "\n"
x1String: .asciiz "x1 = "
x2String: .asciiz "x2 = "
x3String: .asciiz "x3 = "
spaceString: .asciiz " "

.text
.globl main

main:
#protect stack
addi $sp, $sp, -4
sw $ra, 0($sp)

#put all 12 inputs in main

#first row input
addi $a0, $zero, 4 #a0 for first row 
jal columnIn

#second row input
addi $a0, $zero, 20 #a0 for second row
jal columnIn

#third row input
addi $a0, $zero, 36 #a0 for third row
jal columnIn

addi $v0, $zero, 6 #set syscall
syscall
addi $a0, $zero, 16 #b1 at 16
add $a0, $a0, $gp #set a0 to 36 + gp
swc1 $f0, 0($a0) #put b1 in memory
syscall
addi $a0, $zero, 32 #b2 at 52
add $a0, $a0, $gp 
swc1 $f0, 0($a0) #put b2 in memory
syscall
addi $a0, $zero, 48 #b3 at 68
add $a0, $a0, $gp 
swc1 $f0, 0($a0) #put b3 in memory

la $t0, zeroFloat
lwc1 $f31, 0($t0) #load zero float in f31 

#first pivot operations
addi $t0, $gp, 4 #put t0 to where a11 is in memory 
lwc1 $f0, 0($t0) #load a11 into f0
c.eq.s $f0, $f31 #is a11 equal to zero?
bc1f ratioFirst #if a11 is not zero go to ratio
addi $t0, $t0, 16 #incrument to next in column
lwc1 $f0, 0($t0) #load a21 into f0
c.eq.s $f0, $f31 #is next equal to zero?
addi $t3, $zero, 2
bc1f changeRows #if not equal to equal changeRows
addi $t0, $t0, 16 #incrument to next in column
lwc1 $f0, 0($t0) #load a21 into f0
c.eq.s $f0, $f31 #is next equal to zero?
bc1f changeRows #if not equal to equal changeRows
j returnError #if this doesn't work return error?

changeRows:
bne $t3, 2, thirdRow
add $a0, $gp, 4 #first argument is first row
addi $a1, $gp, 20 #second arugment is second row
jal rowSwap
j ratioFirst

thirdRow: 
add $a0, $gp, 4 #first argument is first row
addi $a1, $gp, 36 #second arugment is second row
jal rowSwap

ratioFirst:
#get ratio of a21/a11 into f10 
addi $t0, $gp, 4 #put t0 to where a11 is in memory 
lwc1 $f0, 0($t0) #load a11 into f0
addi $t1, $gp, 20 #load t1 to address of a21
lwc1 $f4, 0($t1) #put a21 in f4
div.s $f10, $f4, $f0 #f10 is the ratio of a21/a11
add $a0, $t0, $zero #set a0 to first row in memory
add $a1, $t1, $zero #set a1 to second row in memory 
jal rowSub
jal printMatrix

#get ratio of a31/a11
addi $t2, $gp, 36 #load t2 to address of a31
lwc1 $f5, 0($t2) #load a31 into f5
div.s $f10, $f5, $f0 #f10 is the ratio of a31/a11
addi $a0, $gp, 4 #set a0 to first row in memory 
addi $a1, $gp, 36 #set a1 to third row in memory 
jal rowSub
jal printMatrix

#second pivot operations 
addi $t0, $gp, 24 #put t0 to where a11 is in memory 
lwc1 $f0, 0($t0) #load a11 into f0
c.eq.s $f0, $f31 #is a11 equal to zero?
bc1f ratioSecond
addi $a0, $zero, 20 #second row in a0
addi $a1, $zero, 36 #first row in a1
jal rowSwap

ratioSecond:
addi $t0, $gp, 24 #put t0 to where a22 is in memory 
lwc1 $f0, 0($t0) #load a22 into f0 
addi $t1, $gp, 40 #put t1 to where a32 is in memory 
lwc1 $f4, 0($t1) #put a32 into f4
div.s $f10, $f4, $f0 #f10 is the ratio of a22/a32
addi $a0, $gp, 20 #set a0 to second row in memory
addi $a1, $gp, 36 #set a1 to third row in memory 
jal rowSub
jal printMatrix

#should have uppertrianglar matrix after these operations 
#get x3
addi $t0, $gp, 44 #put a33 address in t0
addi $t1, $gp, 48 #put b3 address in t1
lwc1 $f0, 0($t0)
lwc1 $f1, 0($t1)
div.s $f20, $f1, $f0 #f2 = b3/a33 = x3

#get x2
addi $t0, $gp, 28 #addy of a23
lwc1 $f0, 0($t0) #f0 is equal to a23
mul.s $f1, $f0, $f20 #f1 = x3 * a23 
addi $t0, $gp, 32 #addy of b2
lwc1 $f2, 0($t0) #f2 is b2
sub.s $f2, $f2, $f1 #f2 = b2 - a23 * x3
addi $t0, $gp, 24 #addy of a22
lwc1 $f3, 0($t0) #f3 is a22
div.s $f21, $f2, $f3 #f21 = x2

#get x1
addi $t0, $gp, 12 #addy of a13
lwc1 $f0, 0($t0) #f0 = a13
mul.s $f1, $f0, $f20 #f1 = a13 * x3
addi $t0, $gp, 8 #addy of a12
lwc1 $f0, 0($t0) #f0 = a12
mul.s $f2, $f0, $f21 #f2 = a12 * x2
add.s $f1, $f1, $f2 #f1 = f1 + f2
addi $t0, $gp, 16 #addy of b1
lwc1 $f3, ($t0) #f3 = b1
sub.s $f3, $f3, $f1 #f3 = b1 - f1
addi $t0, $gp, 4 #addy of a11
lwc1 $f4, 0($t0) #f4 = a11
div.s $f22, $f3, $f4 #f22 = x1

#print Output
la $a0, x1String
addi $v0, $zero, 4 #syscall for print string
syscall

cvt.d.s $f12, $f22 #convert to double
addi $v0, $zero, 3
syscall

la $a0, endString
addi $v0, $zero, 4 #syscall for print string
syscall

la $a0, x2String
addi $v0, $zero, 4 #syscall for print string
syscall

cvt.d.s $f12, $f21 #convert to double
addi $v0, $zero, 3
syscall

la $a0, endString
addi $v0, $zero, 4 #syscall for print string
syscall

la $a0, x3String
addi $v0, $zero, 4 #syscall for print string
syscall

cvt.d.s $f12, $f20 #convert to double
addi $v0, $zero, 3
syscall

#end Main
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#arugment that takes a0 and a1 as row addresses and swaps them 
rowSwap:
#protect the stack
addi $sp, $sp, -4
sw $ra, 0($sp)

add $s0, $a0, $zero
add $s1, $a1, $zero

lwc1 $f20, 0($s0) #store first row first element
addi $s0, $s0, 4 #point to next element 
lwc1 $f21, 0($s0) #store first row second element
addi $s0, $s0, 4 #point to next element 
lwc1 $f22, 0($s0) #store first row third element
addi $s0, $s0, 4 #point to next element 
lwc1 $f23, 0($s0) #store first row fourth element
add $t0, $a0, $zero #set t0 to first row first element
add $t1, $zero, $zero

swapLoop:
lwc1 $f24, 0($s1) #store second row first element in f24
swc1 $f24, 0($t0) #second row first element stored in first row first element
addi $t0, $t0, 4 #point to second first row element
addi $s1, $s1, 4 #point to next second row element
addi $t1, $t1, 1 #incrument loop vari.
bne $t1, 4, swapLoop

add $t0, $a1, $zero #t0 is now the second row
swc1 $f20, 0($t0) #second row first element is now first row first element
addi $t0, $t0, 4 #point t0 to second row second element 
swc1 $f21, 0($t0) #second row first element is now first row second element
addi $t0, $t0, 4 #point t0 to second row second element 
swc1 $f22, 0($t0) #second row first element is now first row third element
addi $t0, $t0, 4 #point t0 to second row second element 
swc1 $f23, 0($t0) #second row first element is now first row fourth element
jal printMatrix

#restore stack
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#take a0 and a1 as row arugments and use f10 as a ratio
rowSub:
#protect the stack
addi $sp, $sp, -4
sw $ra, 0($sp)

add $s0, $a0, $zero #set input first row to s0
add $s1, $a1, $zero #set input second row to s1
add $t0, $zero, $zero

rowLoop:
lwc1 $f11, 0($s0) #first row element in f11 
lwc1 $f12, 0($s1) #second row element in f12
mul.s $f13, $f11, $f10 #f13 equals ratio times first row element
sub.s $f12, $f12, $f13 #f12 is equal to second row element minus f13
swc1 $f12, 0($s1) #put new value in second row element 
addi $t0, $t0, 1 #incrument t0
addi $s0, $s0, 4 #point to next first row element
addi $s1, $s1, 4 #point to next second row element
bne $t0, 4, rowLoop

#restore stack
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra


#take three inputs and put in in the xth row (a0 = 4 for row 1, a0 = 20 for row 2, a0 = 36 for row 3)
columnIn:
#protect the stack
addi $sp, $sp, -4
sw $ra, 0($sp)

#setup syscall
addi $v0, $zero, 6
add $t0, $zero, $zero #set t0 to 0
add $s0, $a0, $gp #set s0 to input + gp

inputLoop:
syscall
swc1 $f0, 0($s0) 
addi $s0, $s0, 4 #add 4 to s0
addi $t0, $t0, 1 #incrument t0 by one
bne $t0, 3, inputLoop

#restore stack
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

#debugging function
printMatrix:
#protect the stack
addi $sp, $sp, -12
sw $ra, 0($sp)
sw $t0, 4($sp)
sw $t1, 4($sp)

addi $s3, $gp, 4 #point to first one 
addi $v0, $zero, 3
add $t0, $zero, $zero
add $t1, $zero, $zero

printLoop:
lwc1 $f18, 0($s3) #load address
cvt.d.s $f12, $f18 #convert to double
syscall
la $a0, spaceString
addi $v0, $zero, 4
syscall
addi $v0, $zero, 3
addi $t0, $t0, 1
addi $t1, $t1, 1
beq $t0, 4, printNewLine
beq $t1, 12, printReturn
addi $s3, $s3, 4
j printLoop

printNewLine:
la $a0, endString
addi $v0, $zero, 4
syscall
addi $v0, $zero, 3
beq $t1, 12, printReturn
add $t0, $zero, $zero
addi $s3, $s3, 4
j printLoop

printReturn:
la $a0, endString
addi $v0, $zero, 4
syscall

#restore stack
lw $ra, 0($sp)
lw $t0, 4($sp)
lw $t1, 8($sp)
addi $sp, $sp, 12
jr $ra
