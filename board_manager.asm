.data
board: .space 221
all_user_input: .space 221
dot: .asciiz "."
line_h: .asciiz "-"
line_v: .asciiz "|"
newline: .asciiz "\n"
board_width: .word 17
board_height: .word 13

.text
# Initialize the game board
.globl init_board
init_board:
    la $s0, board       	# Load the address of the game board
    la $s1, all_user_input	# Load the address of input history dont think we need to do this on this file
    li $t0, 0           	# Initialize row counter
    li $t1, 0           	# Initialize column counter
    
init_board_loop:
    rem $t2, $t0, 2
    rem $t3, $t1, 2
    beq $t2, 0, init_board_check_column    # If row is even, check column

init_board_write_space:
    li $t2, ' '         	# Load the ASCII value of a space
    sb $t2, 0($s0)       	# Store the space in the current position
    j init_board_next
	
init_board_check_column:
    beq $t3, 0, init_board_write_dot       # If column is even, write a dot
    j init_board_write_space               # Else, write a space

init_board_write_dot:
    li $t2, '+'         	# Load the ASCII value of a dot
    sb $t2, 0($s0)       	# Store the dot in the current position

init_board_next:
    addi $t1, $t1, 1    	# Increment column counter
    addi $s0, $s0, 1    	# Move to the next cell in the game board

    lw $t3, board_width
    bne $t1, $t3, init_board_loop  # If column counter is not equal to board width, continue looping

    li $t1, 0           	# Reset column counter
    addi $t0, $t0, 1    	# Increment row counter

    lw $t3, board_height
    bne $t0, $t3, init_board_loop  # If row counter is not equal to board height, continue looping

    j display_board

# Display the game board
.globl display_board
display_board:
    la $s0, board         # Load the address of the game board
    li $t0, 0             # Initialize row counter
    li $t1, 0             # Initialize column counter
    addi $s5, $s5, 1	  # Increment turn count
    
display_input_loop:
	#add $t7, $t6, $t5		#Prevent it from running initially
	beqz $t7 display_board_loop
	bne $t5, $t1, display_board_loop	#See if it is at the right column
	bne $t4, $t0, display_board_loop	#See if it is at the right row
	rem $t6, $t5, 2 					#If column is even, write '|', else write '_'
	beq  $t6, 1, write_hyphen
	li $t2, '|'         				#Write '|' character
    	sb $t2, 0($s0)
    	la $s7, 0($s0)
    j display_board_loop
    
write_hyphen:							#Write '-' character
	li $t2, '-'
    	sb $t2, 0($s0)
    	la $s7, 0($s0)
    	j display_board_loop
    
display_board_loop:
    lb $a0, 0($s0)        # Load the ASCII value of the current cell
    li $v0, 11            # Set the system call code for printing a character
    syscall               # Print the character

    addi $t1, $t1, 1      # Increment column counter
    addi $s0, $s0, 1      # Move to the next cell in the game board
    
display_board_loop_cont:

    lw $t2, board_width
    bne $t1, $t2, display_input_loop  # If column counter is not equal to board width, continue looping

    # Print a newline character
    la $a0, newline
    li $v0, 4             # Set the system call code for printing a string
    syscall

    li $t1, 0             # Reset column counter
    addi $t0, $t0, 1      # Increment row counter

    lw $t2, board_height
    bne $t0, $t2, display_input_loop  # If row counter is not equal to board height, continue looping
    
    #j computer_move
    #j take_user_input
    jr $ra
