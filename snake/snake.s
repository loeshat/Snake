########################################################################
# COMP1521 21T2 -- Assignment 1 -- Snake!
# <https://www.cse.unsw.edu.au/~cs1521/21T2/assignments/ass1/index.html>
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# For instructions, see: https://www.cse.unsw.edu.au/~cs1521/21T2/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Leo Shi (z5364321)
# during the month of July.
#
# Version 1.0 (2021-06-24): Team COMP1521 <cs1521@cse.unsw.edu.au>
#

	# Requires:
	# - [no external symbols]
	#
	# Provides:
	# - Global variables:
	.globl	symbols
	.globl	grid
	.globl	snake_body_row
	.globl	snake_body_col
	.globl	snake_body_len
	.globl	snake_growth
	.globl	snake_tail

	# - Utility global variables:
	.globl	last_direction
	.globl	rand_seed
	.globl  input_direction__buf

	# - Functions for you to implement
	.globl	main
	.globl	init_snake
	.globl	update_apple
	.globl	move_snake_in_grid
	.globl	move_snake_in_array

	# - Utility functions provided for you
	.globl	set_snake
	.globl  set_snake_grid
	.globl	set_snake_array
	.globl  print_grid
	.globl	input_direction
	.globl	get_d_row
	.globl	get_d_col
	.globl	seed_rng
	.globl	rand_value


########################################################################
# Constant definitions.

N_COLS          = 15
N_ROWS          = 15
MAX_SNAKE_LEN   = N_COLS * N_ROWS

EMPTY           = 0
SNAKE_HEAD      = 1
SNAKE_BODY      = 2
APPLE           = 3

NORTH       = 0
EAST        = 1
SOUTH       = 2
WEST        = 3


########################################################################
# .DATA
	.data

# const char symbols[4] = {'.', '#', 'o', '@'};
symbols:
	.byte	'.', '#', 'o', '@'

	.align 2
# int8_t grid[N_ROWS][N_COLS] = { EMPTY };
grid:
	.space	N_ROWS * N_COLS

	.align 2
# int8_t snake_body_row[MAX_SNAKE_LEN] = { EMPTY };
snake_body_row:
	.space	MAX_SNAKE_LEN

	.align 2
# int8_t snake_body_col[MAX_SNAKE_LEN] = { EMPTY };
snake_body_col:
	.space	MAX_SNAKE_LEN

# int snake_body_len = 0;
snake_body_len:
	.word	0

# int snake_growth = 0;
snake_growth:
	.word	0

# int snake_tail = 0;
snake_tail:
	.word	0

# Game over prompt, for your convenience...
main__game_over:
	.asciiz	"Game over! Your score was "


########################################################################
#
# Your journey begins here, intrepid adventurer!
#
# Implement the following 6 functions, and check these boxes as you
# finish implementing each function
#
#  - [x] main
#  - [x] init_snake
#  - [x] update_apple
#  - [x] update_snake
#  - [x] move_snake_in_grid
#  - [x] move_snake_in_array
#



########################################################################
# .TEXT <main>
	.text
main:

	# Args:     void
	# Returns:
	#   - $v0: 0
	#
	# Frame:    $ra
	# Uses:	    $a0, $v0, $t0, $t1
	# Clobbers: $a0, $v0, $t0, $t1
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   main
	#   -> prologue
	#   -> body
	#   -> epilogue

	# Code:
main__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

main__body:
	# TODO ... complete this function.
	jal 	init_snake
	jal 	update_apple

main_loop:
	jal 	print_grid
	jal 	input_direction

	move	$a0, $v0 	

	jal 	update_snake
	move 	$t0, $v0		# $v0 = $t0
	# 0 = false, 1 = true
	beq	$t0, 1, main_loop	# if  $t0 == 0 then stop loop

	la	$a0, main__game_over	# printing: Game over! your score was
	li	$v0, 4
	syscall

	lw	$t0, snake_body_len
	div	$t1, $t0, 3		# snake_body_len / 3
	move	$a0, $t1
	li	$v0, 1
	syscall

	li   	$a0, '\n'    		# printf("%c", '\n');
	li   	$v0, 11
	syscall
	j 	main__epilogue
	
main__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return 0;



########################################################################
# .TEXT <init_snake>
	.text
init_snake:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra
	# Uses:     $a0, $a1, $a2
	# Clobbers: $a0, $a1, $a2
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   init_snake
	#   -> prologue
	#   -> body
	#   -> epilogue

	# Code:
init_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

init_snake__body:
	# TODO ... complete this function.
	li	$a0, 7			# set_snake(7, 7, SNAKE_HEAD);
	li	$a1, 7
	li	$a2, SNAKE_HEAD
	jal	set_snake

	li	$a0, 7			# set_snake(7, 6, SNAKE_BODY);
	li	$a1, 6
	li	$a2, SNAKE_BODY
	jal	set_snake

	li	$a0, 7			# set_snake(7, 5, SNAKE_BODY);
	li	$a1, 5
	li	$a2, SNAKE_BODY
	jal	set_snake

	li	$a0, 7			# set_snake(7, 4, SNAKE_BODY);
	li	$a1, 4
	li	$a2, SNAKE_BODY
	jal	set_snake

init_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;

########################################################################
# .TEXT <update_apple>
	.text
update_apple:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra, $s0
	# Uses:     $a0, $s0, $t1, $t2, $t3, $t4, $t5
	# Clobbers: $a0, $s0, $t1, $t2, $t3, $t4, $t5
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   update_apple
	#   -> prologue
	#   -> body
	#   -> loop
	#   -> epilogue

	# Code:
update_apple__prologue:
	# set up stack frame
	addiu	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw 	$s0, ($sp)

update_apple__body:
	# TODO ... complete this function.
update_apple_loop:
	li	$a0, N_ROWS
	jal	rand_value
	move 	$s0, $v0		#save $t0 = apple_row onto stack

	li	$a0, N_COLS
	jal	rand_value
	move	$t1, $v0		# $t1 = apple_col
	move 	$t0, $s0		# restore $t0 from stack

	li	$t2, N_COLS
	mul	$t2, $t2, $t0 		#  15 * row
	add 	$t2, $t2, $t1		# (15 * row) + col
	li 	$t3, EMPTY
	lb 	$t4, grid($t2)
	bne 	$t3, $t4, update_apple_loop	# check grid[apple_row][apple_col] != EMPTY

	li 	$t5, APPLE
	sb	$t5, grid($t2)		# grid[row][col] = APPLE

update_apple__epilogue:
	# tear down stack frame
	sw 	$s0, ($sp)
	lw	$ra, 4($sp)
	addiu 	$sp, $sp, 8

	jr	$ra			# return;



########################################################################
# .TEXT <update_snake>
	.text
update_snake:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra, $s0
	# Uses:     $a0, $s0, $v0, $t1, $t2, $t3, $t4, $t5, $t6, $t7
	# Clobbers: $a0, $s0, $v0, $t1, $t2, $t3, $t4, $t5, $t6, $t7
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   update_snake
	#   -> prologue
	#   -> body
	#   -> true_apple
	#   -> next_section
	#   -> return_false
	#   -> return_true

	# Code:
update_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw 	$s0, ($sp)

update_snake__body:
	# TODO ... complete this function.
	jal 	get_d_row
	move 	$s0, $v0 		# $s0 = d_row
	jal 	get_d_col
	move 	$t1, $v0 		# $t1 = d_col

	lb 	$t2, snake_body_row	# head_row = $t2
	lb	$t3, snake_body_col	# head_col = $t3

	li 	$t4, N_COLS
	mul 	$t4, $t4, $t2 		#  15 * row
	add 	$t4, $t4, $t3 		# (15 * row) + col
	li 	$t5, SNAKE_BODY
	sb	$t5, grid($t4)		# grid[head_row][head_col] = SNAKE_BODY

	add	$t6, $s0, $t2		# $t6 = new_head_row = head_row + d_row
	add 	$t7, $t1, $t3		# $t7 = new_head_col = head_col + d_col
	
	blt	$t6, 0, return_false  		# if new_head_row < 0 then false
	bge	$t6, N_ROWS, return_false 	# if new_head_row >= N_ROWS then false
	blt	$t7, 0, return_false   		# if new_head_col < 0 then false
	bge	$t7, N_COLS, return_false 	# if new_head_col >= N_ROWS then false

	li 	$t0, N_COLS
	mul 	$t0, $t0, $t6 		#  15 * row
	add 	$t0, $t0, $t7 		# (15 * row) + col
	li 	$t1, APPLE
	lb 	$t2, grid($t0)
	beq	$t1, $t2, true_apple	# if grid[new_head_row][new_head_col] == APPLE then true

	#false apple
	li 	$t3, 0			# apple = FALSE
	j 	next_section

true_apple:
	li 	$t3, 1			# apple = TRUE

next_section:
	lw 	$t0, snake_body_len	# snake_tail = snake_body_len - 1;
	sub 	$t0, $t0, 1
	sw	$t0, snake_tail

	move 	$a0, $t6
	move 	$a1, $t7

	move 	$s0, $t3 		# save $t3 = apple onto stack

	jal 	move_snake_in_grid
	move 	$t2, $v0
	beq	$t2, 0, return_false	# if $t2 == 0 then false

	jal 	move_snake_in_array	

	move 	$t3, $s0 		# restore $t3 = apple from stack	

	beq	$t3, 0, return_true	# if apple == 0 then end
	
	lw 	$t0, snake_growth	# snake_tail+= 3;
	add 	$t0, $t0, 3
	sw	$t0, snake_growth

	jal 	update_apple
	
	j 	return_true

return_false:
	# tear down stack frame
	lw 	$s0, ($sp)
	lw	$ra, 4($sp)
	addiu 	$sp, $sp, 8

	li	$v0, 0
	jr	$ra			# return false;

return_true:
	# tear down stack frame
	lw 	$s0, ($sp)
	lw	$ra, 4($sp)
	addiu 	$sp, $sp, 8

	li	$v0, 1
	jr	$ra			# return true;



########################################################################
# .TEXT <move_snake_in_grid>
	.text
move_snake_in_grid:

	# Args:
	#   - $a0: new_head_row
	#   - $a1: new_head_col
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra
	# Uses:     $a0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8
	# Clobbers: $a0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   move_snake_in_grid
	#   -> prologue
	#   -> body
	#   -> else
	#   -> end
	#   -> move_return_false
	#   -> move_return_true

	# Code:
move_snake_in_grid__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_grid__body:
	# TODO ... complete this function.

	lw 	$t2, snake_growth

	ble	$t2, 0, else 		# if $t2 <= 0 then else statement

	lw 	$t0, snake_tail		# snake_tail++;
	add 	$t0, $t0, 1
	sw	$t0, snake_tail

	lw 	$t1, snake_body_len	#snake_body_len++;
	add 	$t1, $t1, 1
	sw	$t1, snake_body_len

	sub 	$t2, $t2, 1		#snake_growth--;
	sw	$t2, snake_growth
	j 	move_snake_in_grid_end 

else:

	lw 	$t0, snake_tail

	la 	$t1, snake_body_row
	add 	$t2, $t1, $t0
	lb 	$t3, ($t2)		# load $t3 = tail_row = snake_body_row[tail]

	la 	$t4, snake_body_col
	add 	$t5, $t4, $t0
	lb 	$t6, ($t5)		# load $t6 = tail_col = snake_body_row[tail]

	li 	$t7, N_COLS
	mul 	$t7, $t7, $t3 		#  15 * row
	add 	$t7, $t7, $t6 		# (15 * row) + col
	li 	$t8, EMPTY
	sb 	$t8, grid($t7)		# grid[tail_row][tail_col] = EMPTY
	j 	move_snake_in_grid_end

move_snake_in_grid_end:
	move 	$t0, $a0		# $t0 = new_head_row
	move 	$t1, $a1		# $t1 = new_head_col

	li 	$t2, N_COLS
	mul 	$t2, $t2, $t0 		#  15 * row
	add 	$t2, $t2, $t1 		# (15 * row) + col
	li 	$t3, SNAKE_BODY
	lb 	$t5, grid($t2)
	beq 	$t3, $t5, move_return_false	# grid[new_head_row][new_head_col] = SNAKE_BODY
	
	li 	$t4, SNAKE_HEAD
	sb	$t4, grid($t2)		# grid[new_head_row][new_head_col] = SNAKE_HEAD 
	j 	move_return_true

move_return_false:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li 	$v0, 0
	jr 	$ra			# return false


move_return_true:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 1
	jr	$ra			# return true;



########################################################################
# .TEXT <move_snake_in_array>
	.text
move_snake_in_array:

	# Arguments:
	#   - $a0: int new_head_row
	#   - $a1: int new_head_col
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1, $s2
	# Uses:     $a0, $a1, $a2, $s0, $s1, $s2, $t1, $t2, $t3, $t4, $t5, $t6
	# Clobbers: $a0, $a1, $a2, $s0, $s1, $s2, $t1, $t2, $t3, $t4, $t5, $t6
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   move_snake_in_array
	#   -> prologue
	#   -> body
	#   -> loop
	#   -> end
	#   -> epilogue

	# Code:
move_snake_in_array__prologue:
	# set up stack frame
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw	$s0, ($sp)

move_snake_in_array__body:
	# TODO ... complete this function.
	move 	$s0, $a0		# save new_head_row and new_head_col
	move 	$s1, $a1

	lw 	$s2, snake_tail
move_snake_in_array_loop:
	blt	$s2, 1, move_snake_in_array_end
	sub 	$t1, $s2, 1 		#  i - 1

	la 	$t3, snake_body_row
	add 	$t4, $t1, $t3
	lb 	$a0, ($t4)		# load snake_body_row[i - 1]

	la 	$t5, snake_body_col
	add 	$t6, $t1, $t5
	lb 	$a1, ($t6)		# load snake_body_col[i - 1]	

	move 	$a2, $s2
	jal 	set_snake_array		
	sub	$s2, $s2, 1		# i --;
	j 	move_snake_in_array_loop

move_snake_in_array_end:

	move 	$a0, $s0
	move 	$a1, $s1
	li	$a2, 0
	jal 	set_snake_array
	j 	move_snake_in_array__epilogue

move_snake_in_array__epilogue:
	# tear down stack frame
	lw 	$s0, ($sp)
	lw 	$s1, 4($sp)
	lw 	$s2, 8($sp)
	lw	$ra, 12($sp)
	addiu 	$sp, $sp, 16

	jr	$ra			# return;


########################################################################
####                                                                ####
####        STOP HERE ... YOU HAVE COMPLETED THE ASSIGNMENT!        ####
####                                                                ####
########################################################################

##
## The following is various utility functions provided for you.
##
## You don't need to modify any of the following.  But you may find it
## useful to read through --- you'll be calling some of these functions
## from your code.
##

	.data

last_direction:
	.word	EAST

rand_seed:
	.word	0

input_direction__invalid_direction:
	.asciiz	"invalid direction: "

input_direction__bonk:
	.asciiz	"bonk! cannot turn around 180 degrees\n"

	.align	2
input_direction__buf:
	.space	2



########################################################################
# .TEXT <set_snake>
	.text
set_snake:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $a0, $a1, $a2, $t0, $s0, $s1
	# Clobbers: $t0
	#
	# Locals:
	#   - `int row` in $s0
	#   - `int col` in $s1
	#
	# Structure:
	#   set_snake
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
set_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1,  ($sp)

set_snake__body:
	move	$s0, $a0		# $s0 = row
	move	$s1, $a1		# $s1 = col

	jal	set_snake_grid		# set_snake_grid(row, col, body_piece);

	move	$a0, $s0
	move	$a1, $s1
	lw	$a2, snake_body_len
	jal	set_snake_array		# set_snake_array(row, col, snake_body_len);

	lw	$t0, snake_body_len
	addiu	$t0, $t0, 1
	sw	$t0, snake_body_len	# snake_body_len++;

set_snake__epilogue:
	# tear down stack frame
	lw	$s1,  ($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_grid>
	.text
set_snake_grid:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2, $t0
	# Clobbers: $t0
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake
	#   -> body

	# Code:
	li	$t0, N_COLS
	mul	$t0, $t0, $a0		#  15 * row
	add	$t0, $t0, $a1		# (15 * row) + col
	sb	$a2, grid($t0)		# grid[row][col] = body_piece;

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_array>
	.text
set_snake_array:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int nth_body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake_array
	#   -> body

	# Code:
	sb	$a0, snake_body_row($a2)	# snake_body_row[nth_body_piece] = row;
	sb	$a1, snake_body_col($a2)	# snake_body_col[nth_body_piece] = col;

	jr	$ra				# return;



########################################################################
# .TEXT <print_grid>
	.text
print_grid:

	# Args:     void
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1, $t2
	# Clobbers: $v0, $a0, $t0, $t1, $t2
	#
	# Locals:
	#   - `int i` in $t0
	#   - `int j` in $t1
	#   - `char symbol` in $t2
	#
	# Structure:
	#   print_grid
	#   -> for_i_cond
	#     -> for_j_cond
	#     -> for_j_end
	#   -> for_i_end

	# Code:
	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	li	$t0, 0			# int i = 0;

print_grid__for_i_cond:
	bge	$t0, N_ROWS, print_grid__for_i_end	# while (i < N_ROWS)

	li	$t1, 0			# int j = 0;

print_grid__for_j_cond:
	bge	$t1, N_COLS, print_grid__for_j_end	# while (j < N_COLS)

	li	$t2, N_COLS
	mul	$t2, $t2, $t0		#                             15 * i
	add	$t2, $t2, $t1		#                            (15 * i) + j
	lb	$t2, grid($t2)		#                       grid[(15 * i) + j]
	lb	$t2, symbols($t2)	# char symbol = symbols[grid[(15 * i) + j]]

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t2
	syscall				# putchar(symbol);

	addiu	$t1, $t1, 1		# j++;

	j	print_grid__for_j_cond

print_grid__for_j_end:

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	addiu	$t0, $t0, 1		# i++;

	j	print_grid__for_i_cond

print_grid__for_i_end:
	jr	$ra			# return;



########################################################################
# .TEXT <input_direction>
	.text
input_direction:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $a1, $t0, $t1
	# Clobbers: $v0, $a0, $a1, $t0, $t1
	#
	# Locals:
	#   - `int direction` in $t0
	#
	# Structure:
	#   input_direction
	#   -> input_direction__do
	#     -> input_direction__switch
	#       -> input_direction__switch_w
	#       -> input_direction__switch_a
	#       -> input_direction__switch_s
	#       -> input_direction__switch_d
	#       -> input_direction__switch_newline
	#       -> input_direction__switch_null
	#       -> input_direction__switch_eot
	#       -> input_direction__switch_default
	#     -> input_direction__switch_post
	#     -> input_direction__bonk_branch
	#   -> input_direction__while

	# Code:
input_direction__do:
	li	$v0, 8			# syscall 8: read_string
	la	$a0, input_direction__buf
	li	$a1, 2
	syscall				# direction = getchar()

	lb	$t0, input_direction__buf

input_direction__switch:
	beq	$t0, 'w',  input_direction__switch_w	# case 'w':
	beq	$t0, 'a',  input_direction__switch_a	# case 'a':
	beq	$t0, 's',  input_direction__switch_s	# case 's':
	beq	$t0, 'd',  input_direction__switch_d	# case 'd':
	beq	$t0, '\n', input_direction__switch_newline	# case '\n':
	beq	$t0, 0,    input_direction__switch_null	# case '\0':
	beq	$t0, 4,    input_direction__switch_eot	# case '\004':
	j	input_direction__switch_default		# default:

input_direction__switch_w:
	li	$t0, NORTH			# direction = NORTH;
	j	input_direction__switch_post	# break;

input_direction__switch_a:
	li	$t0, WEST			# direction = WEST;
	j	input_direction__switch_post	# break;

input_direction__switch_s:
	li	$t0, SOUTH			# direction = SOUTH;
	j	input_direction__switch_post	# break;

input_direction__switch_d:
	li	$t0, EAST			# direction = EAST;
	j	input_direction__switch_post	# break;

input_direction__switch_newline:
	j	input_direction__do		# continue;

input_direction__switch_null:
input_direction__switch_eot:
	li	$v0, 17			# syscall 17: exit2
	li	$a0, 0
	syscall				# exit(0);

input_direction__switch_default:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__invalid_direction
	syscall				# printf("invalid direction: ");

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t0
	syscall				# printf("%c", direction);

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# printf("\n");

	j	input_direction__do	# continue;

input_direction__switch_post:
	blt	$t0, 0, input_direction__bonk_branch	# if (0 <= direction ...
	bgt	$t0, 3, input_direction__bonk_branch	# ... && direction <= 3 ...

	lw	$t1, last_direction	#     last_direction
	sub	$t1, $t1, $t0		#     last_direction - direction
	abs	$t1, $t1		# abs(last_direction - direction)
	beq	$t1, 2, input_direction__bonk_branch	# ... && abs(last_direction - direction) != 2)

	sw	$t0, last_direction	# last_direction = direction;

	move	$v0, $t0
	jr	$ra			# return direction;

input_direction__bonk_branch:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__bonk
	syscall				# printf("bonk! cannot turn around 180 degrees\n");

input_direction__while:
	j	input_direction__do	# while (true);



########################################################################
# .TEXT <get_d_row>
	.text
get_d_row:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_row
	#   -> get_d_row__south:
	#   -> get_d_row__north:
	#   -> get_d_row__else:

	# Code:
	beq	$a0, SOUTH, get_d_row__south	# if (direction == SOUTH)
	beq	$a0, NORTH, get_d_row__north	# else if (direction == NORTH)
	j	get_d_row__else			# else

get_d_row__south:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_row__north:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_row__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <get_d_col>
	.text
get_d_col:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_col
	#   -> get_d_col__east:
	#   -> get_d_col__west:
	#   -> get_d_col__else:

	# Code:
	beq	$a0, EAST, get_d_col__east	# if (direction == EAST)
	beq	$a0, WEST, get_d_col__west	# else if (direction == WEST)
	j	get_d_col__else			# else

get_d_col__east:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_col__west:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_col__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <seed_rng>
	.text
seed_rng:

	# Args:
	#   - $a0: unsigned int seed
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   seed_rng
	#   -> body

	# Code:
	sw	$a0, rand_seed		# rand_seed = seed;

	jr	$ra			# return;



########################################################################
# .TEXT <rand_value>
	.text
rand_value:

	# Args:
	#   - $a0: unsigned int n
	# Returns:
	#   - $v0: unsigned int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1
	# Clobbers: $v0, $t0, $t1
	#
	# Locals:
	#   - `unsigned int rand_seed` cached in $t0
	#
	# Structure:
	#   rand_value
	#   -> body

	# Code:
	lw	$t0, rand_seed		#  rand_seed

	li	$t1, 1103515245
	mul	$t0, $t0, $t1		#  rand_seed * 1103515245

	addiu	$t0, $t0, 12345		#  rand_seed * 1103515245 + 12345

	li	$t1, 0x7FFFFFFF
	and	$t0, $t0, $t1		# (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF

	sw	$t0, rand_seed		# rand_seed = (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF;

	rem	$v0, $t0, $a0
	jr	$ra			# return rand_seed % n;

