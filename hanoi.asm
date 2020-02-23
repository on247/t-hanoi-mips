##############################################
###    P1 : Hanoi Towers           	#####
###    Author:	Aonso Lizaola           ####
##########################################
.data
	tower_a: .word 0,0,0,0,0,0,0,0 #  *src addr 0x10010000
	tower_b: .word 0,0,0,0,0,0,0,0 #  *dest addr 0x10010020 
	tower_c: .word 0,0,0,0,0,0,0,0 # *aux addr 0x10010040
	tower_a_ptr : .word  0 # **src address stored by create tower 
	tower_b_ptr :.word 0x10010020 # **aux addr 0x10010064
	tower_c_ptr :.word 0x10010040 # **dest addr 0x10010068
.text
     
main:
	or $s0,$zero,$zero
	# intial value of n
	addi $s0,$s0,8
	#Create the tower A
	j create_tower_a
	end_create_tower:
	###### Call hanoi(s0,**A,**C,**B)
	or $a0,$zero,$s0
	addi $a1,$zero,0x10010060 ## address of pointer to top of A
	ori $a2,$zero,0x10010068 ## address of pointer to top of C
	ori $a3,$zero,0x10010064 ## address of pointer to top of B
	jal hanoi
	########
	j exit
#adds N discs to the tower A , where N = $s0
create_tower_a:
        #initialize  loop counter i=0
	or $t0,$zero,$zero
	# store the intial memory postion (location of tower_a)
	addi $t1,$zero,0x10010000
create_tower_loop:
        # disc value (size) =  index+1
        sub $t2,$s0,$t0
        #store disc size in memory
        sw $t2,($t1)
        #move to next cell in memory
	addi $t1,$t1,4
	# increment loop counter 
	addi $t0,$t0,1	
	bne  $t0,$s0,create_tower_loop
	# set pointer to the top of tower A
	ori $t3,$zero,0x10010060
	sw $t1,($t3)
	j end_create_tower
	
 
move_disk:
# moves disks from source to target tower , returns the address for the top cell of source and target tower   
       lw $t0,($a1) # *temp1= *source  (load pointer to top of source toower )
       lw $t1,($a3) # *temp2= *target  (load pointer to top of destination tower )
       lw $t3,-4($t0)  # temp3 =*temp1 (load value at top of source top)
       sw $zero,-4($t0)  # pop the value
       sw $t3,($t1)  # *temp2 =
       subi $t0,$t0,4 # increment decrement of pointer to top of source tower by one woed
       addi $t1,$t1,4 # increment address of pointer to top of source tower by one woed
       sw $t0,($a1) # save address of to top of source tower 
       sw $t1,($a3) # save address of to top of dest tower  
       #return
       jr $ra
       
hanoi_base:
      # base case just moves one disk and does nothing else
      # no recursive calls)
      jal move_disk
      # jump to return 
      j return
hanoi:
      
       	# save arguments and return address in stack
       sw $ra,-4($sp)
       sw $a0,-8($sp) # N
       sw $a1,-12($sp) # SRC
       sw $a2,-16($sp) # dest
       sw $a3,-20($sp) # aux (extra tower)
       addi $sp,$sp,-20
       subi, $a0,$a0,1
       
       
       #swap arguments destintion and aux
       or $t0,$zero,$a2
       or $a2,$zero,$a3
       or $a3,$zero,$t0
       
       #if n=0 (n=1 orginal argument), run base case
       beq $a0,0,hanoi_base
       
       # hanoi(n-1, source , aux , dest)
       jal hanoi
       
       # move top disk from source to dest
       jal move_disk
       
       #change argument order for next function call
       or $t0,$zero,$a1
       or $a1,$zero,$a2
       or $a2,$zero,$a3
       or $a3,$zero,$t0
       ######
       # hanoi(n-1,aux,dest,src)
       jal hanoi
       
       # restores the arguments was called with  from the stack
       return: 
       lw $ra,16($sp) #restore previous return address (previous call)
       lw $a0,12($sp) #N
       lw $a1,8($sp)  #source
       lw $a2,4($sp)  #aux
       lw $a3,0($sp) #dest
       addi $sp,$sp,20 # move stack pointer to uperr fram
       jr $ra
exit:
	nop

	
