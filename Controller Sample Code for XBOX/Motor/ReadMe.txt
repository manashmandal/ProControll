This Arduino sketch called Motor works in conjuction with the Processing sketch called Gamepad. It reads three bytes to determine the motor speed and directions. This first byte is checkbyte chosen arbitrarily to indicate to the Arduino that the next two bytes are motor bytes. The motor byte is split into two parts. The most significant bit tells the Arduino which direction the H-Bridge should be. The next seven bits tell the Arduino what the magnitude of speed or the pulse width should be. It takes four outputs to run two motors. Two pins for the directions in which to control the H-Bridge and two pins to send the PWM data to the left and right motors.

Examples: 

Data ==>   00100011	11000000	01000000

	       ^	    ^		    ^	
									
	   checkbyte	left motor	right motor

	      '#'	backwards	forwards
			
			speed (64)	speed (64)