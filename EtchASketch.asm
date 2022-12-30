#Program Name: EtchASketch.asm
#Author name: James Boumalhab
#Date written: 12/14/2022
#Purpose: Write a program that emulates an Etch-A-Sketch

# w : move upwards
# s : move downwards
# a : move left
# d : move right
# o : move upright
# y : move upleft
# m : move downright
# n : move downleft
# e : erase a pixel
# c : change color by gradient

.eqv BASEADDRESS 0x10040000  #Base address on heap
.eqv CONTROL_REGISTER 0xffff0000   #Aaddress of the first word in MMIO
.eqv DATA_REGISTER  0xffff0004     #address of second word in MMIO
.eqv SOMEPINK    0xff01d9  #Hex code for pink
.eqv BLACK 0x000000   #Hex code for black
.text
   .globl main
main:
   li $s0, BASEADDRESS #the base address is in $s0
   li $t0, SOMEPINK    #load pink hex code into $t0
   li $t1, 0           # top left pixel
   li $t2, 252         # top right pixel 
   
##This part of the code is to draw border that would be the edge of the Etch-A-Sketch 
#and a dot in the middle
for:
  slt $t3, $t1, $t2    #go through code if $t1 less then $t2
  beqz $t3, endfor     #if $t3 = 0 branch to endfor
  
  sw $t0, 0($s0)        #store pink hex into BASEADDRESS
  addi $s0, $s0, 4      #increment base address by 4
  addi $t1,$t1, 4        #increment condition
  b for                  #branch to label "for"

endfor:
   
   li $t1, 256            #update $t1 and $t2 and store in registers
   li $t2, 16388          #pixel locations to draw vertical line on the right
   
for2: 
   
   slt $t3, $t1, $t2       #go through code if $t1 less then $t2
   beqz $t3, endfor2       #if $t3 = 0 branch to endfor
   
   sw $t0, 0($s0)          #store pink hex into address 
   addi $s0, $s0, 256      #increment $s0 by 256
   addi $t1, $t1, 256      #increment $t1 by 256
    
   b for2                  #branch to for2 to repeat

endfor2:
   li $s0, BASEADDRESS     #load baseaddress into $s0
   li $t1, 16380           #load loacation of bottom right pixel into $t1
   li $t2, 16128           #load location of bottom left pixel into $t2
   addi $s0, $s0, 16380    #address of bottom right pixel 
for3:
   
   sge $t3, $t1, $t2      #if $t1 greater than $t2, set $t3 = 1
   beqz $t3, endfor3      #if $t3 = 0, branch to endfor3
   
   sw $t0, 0($s0)          #store pink hex in address
   subi $s0, $s0, 4         #decrement $s0
   subi $t1, $t1, 4         #decrement $s0
   b for3                   #branch to for3 and repeat
   
endfor3:
   
   li $s0, BASEADDRESS       #store base address in $s0
   li $t1, 16128             #load loacation of bottom left pixel into $t1
   li $t2, 0                 #load 0 into $t2
   addi $s0, $s0, 16128      #add 16128 to base address to find address of bottom left pixel
   
for4:
   
   sge $t3, $t1, $t2         #if $t1 greater than $t2, set $t3 = 1
   beqz $t3, endfor4         #if $t3 = 0, branch to endfor3
   
   sw $t0, 0($s0)            #store pink hex in address
   subi $s0, $s0, 256       #decrement address by 256
   subi $t1, $t1, 256       #decrement location by 256
   b for4                   #branch to for4
    
endfor4:
   
   li $s0, BASEADDRESS     #get base address again and store in $s0
   addi $s0,$s0, 8060      #add 8060 to base address to draw pixel at the center
   sw $t0, 0($s0)           #draw pixel
   

#This part of the code is to play the game  
begin:
   jal CheckKeyboard       #jump to checkkeyboard label to check if anything was written using keyboard
   move $s1, $v0           #move ascii code of letter to $s1
   
left:                      #move left
            
   seq $s2, $s1, 97        #ascii of a is 97
   seq $s3, $s1, 65        #ascii of A is 65
   or $t1, $s2, $s3        #if either is true then $t1 = 1
   beqz $t1, right         #if not, branch to right
   
   subi $s0, $s0, 4        #subtract address of center pixel by 4
   sw $t0, 0($s0)          #store pink into address
   b begin                 #branch to begin
   
right:

   seq $s2, $s1, 100       #ascii of d is 100
   seq $s3, $s1, 68        #ascii of D is 68
   or $t1, $s2, $s3        #if either is true then #t1 = 1
   beqz $t1, up            #if $t1 = 0 branch to up
   
   addi $s0, $s0, 4        #add 4 to $s0 to move riight
   sw $t0, 0($s0)          #store color into into address
   b begin                 #branch to begin
   
up: 

   seq $s2, $s1, 119       #ascii code of w
   seq $s3, $s1, 87        #ascii code of W
   or $t1, $s2, $s3         #if either is true then #t1 = 1
   beqz $t1, down          #if $t1 = 0 branch to down
   
   sub $s0, $s0, 256       #subtract 256 from $s0 to draw pixel above prior pixel
   sw $t0, 0($s0)          #draw pixel at address
   b begin                 #branch to begin
   
down:
   seq $s2, $s1, 115       #ascii code of s is 115
   seq $s3, $s1, 83        #ascii code of S is 83
   or $t1, $s2, $s3        #if either is true then #t1 = 1
   beqz $t1, upright       #if $t1 = 0 branch to upright
   
   add $s0, $s0, 256       #add 256 to current address to draw pixel below prior pixel
   sw $t0, 0($s0)          #draw pixel at address
   b begin                 #branch to begin

upright:

   seq $s2, $s1, 111       #ascii code of o is 111
   seq $s3, $s1, 79        #ascii code of O is 79
   or $t1, $s2, $s3        #if either is true then #t1 = 1
   beqz $t1, upleft        #if $t1 = 0 branch to upleft
   
   subi $s0, $s0, 252      #subtract 252 from current address
   sw $t0, 0($s0)          #draw pixel at address
   b begin                 #branch to begin
   
upleft: 
   
   seq $s2, $s1, 121       #ascii code of y is 121
   seq $s3, $s1, 89        #ascii code of Y is 89
   or $t1, $s2, $s3        #if either is true then #t1 = 1
   beqz $t1, downleft      #if $t1 = 0 branch to downleft
   
   subi $s0, $s0, 260      #subtradt 260 from $s0 to find new address
   sw $t0, 0($s0)          #draw pixel at address
   b begin                 #branch to begin

downleft:

   seq $s2, $s1, 110      #ascii code of n is 110
   seq $s3, $s1, 78       #ascii cod of N is 78
   or $t1, $s2, $s3       #if either is true then #t1 = 1
   beqz $t1, downright    #if $t1 = 0 branch to downright
   
   addi $s0, $s0, 252     #add 252 to $s0 to find new address
   sw $t0, 0($s0)         #draw pixel at address
   b begin                #branch to begin

downright:
   
   seq $s2, $s1, 109     #ascii code of m is 109
   seq $s3, $s1, 77      #ascii code of M is 77
   or $t1, $s2, $s3      #if either is true then #t1 = 1
   beqz $t1, delete      #if $t1 = 0 branch to delete
   
   addi $s0, $s0, 260    #add 260 to current address to find new address
   sw $t0, 0($s0)        #draw pixel at new address
   b begin               #branch to begin

delete:
   
   seq $s2, $s1, 101    #ascii code of e is 101
   seq $s3, $s1, 69     #ascii code of E is 69
   or $t1, $s2, $s3     #if either is true then #t1 = 1
   beqz $t1, changeColor   #if $t1 = 0 branch to change color
   
   li $t2, BLACK       #store hex of black color in $t2
   sw $t2, 0($s0)      #draw black pixel, which is equivalent to deleting a pixel
   b begin             #branch to begin
   
changeColor:

   seq $s2, $s1, 99     #ascii code of c is 99
   seq $s3, $s1, 67     #ascii code of C is 67
   or $t1, $s2, $s3     #if either is true then #t1 = 1
   beqz $t1, begin      #branch to begin
   
   add $t0, $t0, 100    #add 100 to $t0 to change color (by gradient)
   sw $t0, 0($s0)       #store color at address
   b begin              #branch to begin
  
   
exit:

    li $v0, 10
    syscall               #exit code


#subprogram: CheckKeyboard
#input: none
#output: $v0 Returns the ASCII code of the char read 
#Description:

.text 

CheckKeyboard:

   loop: 
      li $t4, CONTROL_REGISTER   #the base address in $t4
      lw $t1, 0($t4)   #Read the control register
      andi $t1, $t1, 0x1
      beqz $t1, loop  #go back and check the control register again 
      #true code blcok
      li $t2, DATA_REGISTER
      lw $v0, 0($t2) #read the ASCII code from the data register
      jr $ra
      

      

 
