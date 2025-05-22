# 	** TV-Tenis 1970 game by Artemiy, Timur, Fedor  from 23216 **
#	* @All rights reserverd *
#
#	++ Theres we define some agreements ++
#
#	0x01 -> r1 - isVyActive
# 	0x04 -> r2 - ballYPosition
# 	## IF isVyActive == 0, THEN RETURN ballYPosition
# 	## ELSE:
# 	r2 -> /push ballYPosition to the/ -> stack
#	0x02 -> r1 - Vy
#	0x03 -> r2 - Vx
#
#  	r3 - will contain current Vx position
#
#	0xF0 - output
#
#	Vx and X-Position usage was made for 
# 	  future modification with physically correct speeds

asect 0x00

ProgrammStart:

### --- LOAD DATA FROM CONTROLLER --- ###

	# load isVyActive from 0x01 to r1
	ldi r0, 0x01
	ld r0, r1
	#load ballYPosition from 0x04 to r2
	ldi r0, 0x04
	ld r0, r2
	
### --- CALCULATES NEXT Y-POS --- ###
	
	# IF
	## Vy DOESN'T ACTIVE
	ldi r0, 0x00
	if 
		cmp r0, r1
	is eq
		br answer
	## OTHERWISE -> ITERATIVE CALCULATIONS
	else
		# push ballYPosition to the stack
		push r2
		# load Vy from 0x02 to r1
		ldi r0, 0x02
		ld r0, r1
		
# >> ONLY FOR BASE REALISATION
		## We need to compare r1 (Vy) with zero
		## If Vy = 0, then Vy = -1
		## Else: Vy = 1
		ldi r3, 0
		if 
			cmp r3, r1
		is eq
			ldi r1, -1
		else
			ldi r1, 1	
		fi
# ONLY FOR BASE REALISATION <<

		# load Vx from 0x03 t0 r2
		ldi r0, 0x03
		ld r0, r2
		# define X-POS
		ldi r3, 3
		
		## Iterates while X-POS < 26
		## Before all iterations makes r0=26
		ldi r0, 26						
		while 
			cmp r3, r0
		stays lt
			# r0 - current ballYPosition
			pop r0
			# Vx + current X-POS
			add r2, r3
			# push Vx to the stack
			push r2
			
			## COUNT NEXT Y-POS
			#compare Vy with 0, Y-POS with 0 and 31
			##- IF Vy < 0
			##-- IF Y-POS < 0 | Y-POS >= 31
			ldi r2, 0
			
			if 
				cmp r1, r2
			##: Vy is negative (< 0) 
			is lt
				ldi r2, 0
				
				if 
					cmp r0, r2
				##:: Y-POS <= 0
				is le
					# (-Vy) + Y-POS
					neg r1
					add r1, r0
				##: Y-POS > 0
				else
					# push Vy to the stack
					push r1
					# Y-POS + Vy
					add r1, r0
					# pop Vy from the stack
					pop r1
				fi

			##: Vy is not-negative (>= 0)
			else
				ldi r2, 31

				##: Y-POS > 31
				if 
					cmp r0, r2
				##:: Y-POS < 31
				is lt
					# Vy + Y-POS
					add r1, r0
				##:: Y-POS >= 31
				else
					# (-Vy) + Y-POS
					neg r1
					add r1, r0
				fi
			fi
			# pop Vx from the stack
			pop r2
			# push ballYPosition to the stack
			push r0
			## Before all iterations makes r0=26			
			ldi r0, 26		
		wend
		
		## NOW WE NEED ONLY ballYPosition ##
		
		# get Y-POS from stack
		pop r2
	fi
### --- WRITE ANSWER --- ###

answer:
	ldi r0, 0xf0
	st r0, r2
	
### --- THE END: ALL CALCULATIONS HAVE DONE --- ###
	
	br	 ProgrammStart
	
	halt

end