.data
end: .asciiz "Game Over.\n"
user_display_score: .asciiz "User score: "
comp_display_score: .asciiz "\nComputer score: "
winner: .asciiz "\nWinner: "
user_wins: .asciiz "User\n"
comp_wins: .asciiz "Computer\n"
tie: .asciiz "Tie\n"
comp_input: .asciiz "\nComputer Input:\n"
user_prompt_row: .asciiz "Enter the row: "
user_prompt_column: .asciiz "Enter the column: "
invalid_input: .asciiz "Invalid input. Please enter a valid value. \n"
repeated_input: .asciiz "Repeated input. Please enter a valid value!\n"
all_user_input: .space 221
pitch: .byte 1
duration: .byte 50
instrument: .byte 50
volume: .byte 50
turn_count: .word 0
user_score: .word 0
ai_score: .word 0
input_row: .space 10
input_column: .space 10
min: .word 0
maxrow: .word 12
maxcol: .word 16

.text
# Take user input
.globl take_user_input
take_user_input:
    # ... (Code to take user input, validate it, and update the game board)
	la $s1, all_user_input	# Load the address of input history

	li $v0, 4
	la $a0, user_prompt_row 				#Have the user input the row
	syscall
	
	li $v0, 8							#Store it
	la $a0, input_row
	li $a1, 20
	syscall
	
	li $t0, 0       # initialize counter
	li $t1, 0       # initialize sum
	valid_loop_row:
		lb $t2, ($a0)   		# load byte
		beq $t2, 10, check_row   	# check for newline
		blt $t2, 48, user_invalid_input   	# check for non-digit characters
		bgt $t2, 57, user_invalid_input
		mul $t1, $t1, 10    # Multiply the current sum by 10
		sub $t2, $t2, 48     		# convert to integer
		add $t1, $t1, $t2
		addi $t0, $t0, 1     		# increment counter
		addi $a0, $a0, 1     		# increment pointer
		j valid_loop_row
    		
    	check_row:
    		beq $t0, 0, user_invalid_input   # check for empty input string
    		lw $t2, min         # check lower bound
    		blt $t1, $t2, user_invalid_input
    		lw $t2, maxrow         # check upper bound
    		bgt $t1, $t2, user_invalid_input
    		
    		move $t4, $t1   # Move the row value from $t1 to $t2
	
	li $v0, 4
	la $a0, user_prompt_column 					#Have the user input the column
	syscall
	
	li $v0, 8							#Store it
	la $a0, input_column
	li $a1, 20
	syscall
	
	li $t0, 0       # initialize counter
	li $t1, 0       # initialize sum
	valid_loop_column:
		lb $t3, ($a0)   # load byte
		beq $t3, 10, check_col   # check for newline
		blt $t3, 48, user_invalid_input   # check for non-digit characters
		bgt $t3, 57, user_invalid_input
		mul $t1, $t1, 10    # Multiply the current sum by 10
		sub $t3, $t3, 48     # convert to integer
		add $t1, $t1, $t3
		addi $t0, $t0, 1     # increment counter
		addi $a0, $a0, 1     # increment pointer
		j valid_loop_column
    	
    	check_col:
    		beq $t0, 0, user_invalid_input   # check for empty input string
    		lw $t3, min         # check lower bound
    		blt $t1, $t3, user_invalid_input
    		lw $t3, maxcol        # check upper bound
    		bgt $t1, $t3, user_invalid_input
    		
    		move $t5, $t1   # Move the row value from $t1 to $t2

	add $t7, $t4, $t5					#Add row and column, check if sum is odd
	rem $t7, $t7, 2						#If true, ignore, else, invalid input
	beqz $t7, user_invalid_input 
	
	add $t8, $t4, 48					#add 48 to user input to the get ASCII value of them
	add $t9, $t5, 48					#this converts the row and colume int to ASCII 
	j check_for_repeat_loop	

check_for_repeat_loop:
	lb $s2, 0($s1)
	beqz $s2, if_equal_zero				#check if the first value in all user input is 0, if so check the second one
not_equal_zero:	
	#loop through all_user_input checking for matches or for 0, if 0 is found that means thats the last inputted value and jump to here and enter the 2 new values
	lb $s2, 0($s1)
	bne $s2, $t8, increment_history
	lb $s2, 1($s1)
	bne $s2, $t9, increment_history
	
	li $v0, 4
	la $a0, repeated_input
	syscall
	j take_user_input
increment_history:
	addi $s1, $s1, 2
	j check_for_repeat_loop
if_equal_zero:
	lb $s2, 1($s1)
	bnez $s2, not_equal_zero					#if the second one is not 0 then compare the user input to past input
	sb $t8, 0($s1)						#if it is zero that means its a new input and is vaild
	sb $t9, 1($s1)						#store it in the history

	jr $ra

user_invalid_input:
	li $v0, 4
	la $a0, invalid_input
	syscall
	
	j take_user_input
	
# Make a move for the computer
.globl computer_move
computer_move:
	# ... (Code to make a random move for the computer and update the game board)
	li $s7, 16
	li $s6, 12
	
	li $v0, 42             # Pseudo-random number generator system call to generate the row
	li $a1, 13
	syscall
	
	#Store it
	move $t4, $a0
			
	bgt $t4, $s6, comp_invalid_input	#Error check - value not > 12
	
	li $v0, 42             # Pseudo-random number generator system call to generate the column
	li $a1, 17
	syscall
	
	#Store it
	move $t5, $a0

	bgt $t5, $s7, comp_invalid_input	#Error check - value not > 16
	
	add $t7, $t4, $t5			#Add row and column, check if sum is odd
	rem $t7, $t7, 2				#If true, ignore, else, invalid input
	beqz $t7, comp_invalid_input 
	
	add $t8, $t4, 48					#add 48 to user input to the get ASCII value of them
	add $t9, $t5, 48					#this converts the row and colume int to ASCII 
	li $s6, 1
	
	li $v0, 4
	la $a0, comp_input
	syscall
	
	j check_for_repeat_loop_ai
	
	#j display_board
	jr $ra
    
	comp_invalid_input:
	j computer_move
	
check_for_repeat_loop_ai:
	lb $s2, 0($s1)
	beqz $s2, if_equal_zero_ai				#check if the first value in all user input is 0, if so check the second one
not_equal_zero_ai:	
	#loop through all_user_input checking for matches or for 0, if 0 is found that means thats the last inputted value and jump to here and enter the 2 new values
	lb $s2, 0($s1)
	bne $s2, $t8, increment_history_ai
	lb $s2, 1($s1)
	bne $s2, $t9, increment_history_ai
	j computer_move
increment_history_ai:
	addi $s1, $s1, 2
	j check_for_repeat_loop_ai
if_equal_zero_ai:
	lb $s2, 1($s1)
	bnez $s2, not_equal_zero_ai					#if the second one is not 0 then compare the user input to past input
	sb $t8, 0($s1)							#if it is zero that means its a new input and is vaild
	sb $t9, 1($s1)							#store it in the history

	jr $ra



	
# Check game state
.globl increment_turn
increment_turn:
	lw $s3, turn_count
	addi $s3, $s3, 1
	sw $s3, turn_count
	jr $ra

.globl check_game_state
check_game_state:
    # ... (Code to check if the game is over)
    	lw $s3, turn_count
	bne $s3, 110, not_over
	j game_over
	
not_over:
	jr $ra
		
# Display the winner
game_over:
    # ... (Code to display the winner based on the scores)
	li $v0, 4
	la $a0, end
	syscall
	
	li $v0, 4
	la $a0, user_display_score
	syscall
	
	li $v0, 1
	lw $a0, user_score
	syscall
	
	li $v0, 4
	la $a0, comp_display_score
	syscall
	
	li $v0, 1
	lw $a0, ai_score
	syscall
	
	li $v0, 4
	la $a0, winner
	syscall
	
	lw $t4, user_score
	lw $t5, ai_score
	
	beq $t4, $t5, winner_tie
	bgt $t4, $t5, winner_user
	li $v0, 4
	la $a0, comp_wins
	syscall
	
   	li $v0, 10
    	syscall
    	
winner_tie:
	li $v0, 4
	la $a0, tie
	syscall
	
	jr $ra
winner_user:
	li $v0, 4
	la $a0, user_wins
	syscall
	
	jr $ra

.globl increment_user_score
increment_user_score:
	lw $s2, user_score
	addi $s2, $s2, 1
	sw $s2, user_score
	
	jr $ra
	
.globl increment_ai_score
increment_ai_score:
	lw $s2, ai_score
	addi $s2, $s2, 1
	sw $s2, ai_score
	
	jr $ra
	
.globl play_sound
play_sound:
	li $v0, 31 
	la $t0, pitch
	la $t1, duration 
	la $t2, instrument
	la $t3, volume 
	move $a0, $t0 
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3 
	syscall 
	
	jr $ra
