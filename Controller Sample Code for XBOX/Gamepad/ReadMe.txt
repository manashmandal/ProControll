This Processing sketch called Gamepad works in conjunction with the Arduino sketch called Motor. It takes input from an Xbox 360 USB controller's joysticks and computes the magnitude and direction for each motor as a single byte. Then it packages the two motor bytes together with a header byte and sends it to the Arduino through a serial connection.
The sketch relies on a library called ProControll to extract information from the Xbox controller. The procontroll library should be placed in a folder called "libraries" within the Processing folder.
 
For example "c:\Users\Matthew\Documents\Processing\libraries\procontroll"

More information on the Procontroll library can be found here:
http://creativecomputing.cc/p5libs/procontroll/

Updates:

	I added a mode called T-Rex Jr. Mode which is designed to work with the t-rex jr. motor controller here: http://www.pololu.com/catalog/product/767
I haven't actually tested it yet though. Press the start button to turn it on or off. 

	I also added a single stick mode which computes the two motor speeds based on the magnitude and angle of the left stick only. It has a zero turn radiance. Depending on what quadrant of the circle your in, one of the motors will be mapped according to the angle times the magnitude, and the other the magnitude only. It multiples either motor by a -1 to make them move in the correct direction. It's really confusing so try not the worry about it too much.

	I added a variable for taking out the slack in the joystick which makes the motion much smoother. The variable is called "tolerance" and can be changed according to how worn in your joystick is.

Controls: 

Select - switch between modes

Start - switch output modes (non t-rex mode is the one that works with the arduino sketch)

Y - debuggin info: displays magnitude and angle of left stick etc.

In skid steer mode, press either the left or right bumper to stop the motors.
In single stick mode, press the A button to brake.

FOR RXTX ISSUE

http://rxtx.qbang.org/wiki/index.php/Download