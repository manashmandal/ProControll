/* Gamepad
   In my experience ReadMe files tend to become lost after passing the code around a lot
   so I put everything here. Sorry if the amount of comments offends you.
   
   This is a little sketch written by me, Matthew Spinks, for Mercury Robotics
   at Oklahoma State University. It takes values from the Xbox controller and 
   outputs to an Arduino or other device using the serial port. I've commented out
   the sections for serial communication for testing purposes. Don't forget to 
   uncomment them later. I would like to thank Christian Riekoff for making his
   wrapper class available and saving me the headache of mapping all the buttons on 
   the controller. If you want to use a different controller, I would suggest having 
   a look at the wrapper class available here: http://code.compartmental.net/dualanalog/
   
   This sketch is designed to be used with my Arduino motor sketch. It ouputs three
   bytes: a header or start byte, a byte for the left motor, and a byte for the right
   motor. The magnitude of the motor speed is determined by the lower seven bits of
   each motor byte going from 0 - 127. The Arduino will determine the motor direction 
   from the MSB of each motor byte. 0 is forward and 1 is backwards in this case.
   
   Updates: The code now has Single Stick Mode. This mode computes the speeds for the
   motors using the magnitude and angle of the left joystick. You can switch modes by
   pressing the select button on the controller. It has a zero turn radius, meaning that
   pushing the joystick fully left will run the left motor backwards at full speed and 
   the right motor forwards at full speed. Moving only one motor while leaving the other
   stationary will require the joystick angle to be at 45 degrees. Experiment with it a
   little. I guarantee that, with a little practice, this will become your preferred 
   method of control.
   
   If you haven't figured this out already, don't forget to add the ProControll library 
   to your Processing folder. Try making a folder called "libraries" and putting in
   Processing folder. (It should be in your Documents) Then add the ProControll folder
   within that one. For more info on ProControll and useful examples go here:
   http://creativecomputing.cc/p5libs/procontroll/ 
   
   Controls: 
   
     Select       - switch between modes
     L/R Bumpers  - brake in skid steer mode only
     A            - brake in single stick mode only
     Y            - Display debugging info
     
   As with all good Arduino/Processing sketches this code should be freely shared. But
   please, if you do decide to use all or some of it, at least give me a little credit.
   Or if you want, feel free to bake a cake and send it to me. I like red velvet.
   Here is my youtube account name if you feel like stalking me:
   mspinksosu
   mspinksosu@gmail.com
   
   created 2011-2012 by Matthew Spinks
   based on examples by Christian Riekoff

*/
import processing.serial.*;
import procontroll.*;
import net.java.games.input.*;

Serial myPort;
PFont f, b;
char HEADER ='#';

ControllIO controll;
ControllDevice gamepad;
ControllStick leftStick;
ControllStick rightStick;
ControllCoolieHat DPad;
ControllSlider XBOXTrig;

float leftTriggerMultiplier, leftTriggerTolerance, leftTriggerTotalValue;
float rightTriggerMultiplier, rightTriggerTolerance, rightTriggerTotalValue;

float leftX = 0;
float leftY = 0;
float rightY = 0;
byte lOutput = 0;
byte rOutput = 0;

byte lDir = 0;
byte rDir = 0;

float angle;
float magnitude;
float output;
float tolerance = 0.17;  // set tolerance value for joysticks

int mode = 0;
boolean selectSet = false; // for reading the state of the select button
boolean startSet = false; // for reading the state of the start button
boolean ySet = false;
boolean DEBUG = false;
boolean trexMode = false;

ControllButton A;
ControllButton B;
ControllButton Y; 
ControllButton X;
ControllButton L1;
ControllButton L2;
ControllButton L3;
ControllButton R1;
ControllButton R2;
ControllButton R3;
ControllButton Select;
ControllButton Start;
ControllButton Up;
ControllButton Down;
ControllButton Left;
ControllButton Right;

void setup(){
  size(400,400);
  f = loadFont("ArialMT-48.vlw");
  b = loadFont("Arial-BoldMT-48.vlw");
  
  // The microcontroller will connect on the first port listed
  // with a baud rate of 9600
  // Don't forget to unccomment myPort once you're ready to start
  // using the microcontroller
  println(Serial.list());
  //myPort = new Serial(this, Serial.list()[0], 9600);
  
  controll = ControllIO.getInstance(this);
  
  gamepad = controll.getDevice("Controller (XBOX 360 For Windows)");
  
  gamepad.printSliders();
  gamepad.printButtons();
    
  // This is the section of the wrapper class I used
  leftStick = new ControllStick(gamepad.getSlider(1), gamepad.getSlider(0));
  rightStick = new ControllStick(gamepad.getSlider(3), gamepad.getSlider(2));
  
  XBOXTrig = gamepad.getSlider(4);
  leftTriggerTolerance = rightTriggerTolerance = XBOXTrig.getTolerance();
  leftTriggerMultiplier = rightTriggerMultiplier = XBOXTrig.getMultiplier();
    
  Y = gamepad.getButton(3);
  B = gamepad.getButton(1);
  A = gamepad.getButton(0);
  X = gamepad.getButton(2);
  R1 = gamepad.getButton(5);
  R3 = gamepad.getButton(9);
  L1 = gamepad.getButton(4);
  L3 = gamepad.getButton(8);
  DPad = gamepad.getCoolieHat(10);
  Select = gamepad.getButton(6);
  Start = gamepad.getButton(7);
}

void draw(){
  background(255);
  
  // set the coordinates for the left and right stick objects
  int leftLine = width*5/16, rightLine = width*11/16;

  // change mode if Select button is pressed
  // changes on button release (sort of like debouncing)
  if(Select.pressed())
    selectSet = true;
  
  if(selectSet && !Select.pressed()){
    mode++;
  
    if(mode > 1)
      mode = 0;
      
    selectSet = false;
  }
  
  if(Y.pressed())
    ySet = true;
  
  if(ySet && !Y.pressed()){
    DEBUG = (!DEBUG);
    
    ySet = false;
  }
  
//-------------------------------------------------------------------------------

// begin computing and map values for joysticks
// .get() and map() both need float values
  
  // if you want to use X-axis declare them here.
  leftX = leftStick.getX();
  leftY = leftStick.getY();
  rightY = rightStick.getY();
  
  // trig functions use RADIANS by default
  angle = atan2(leftY, leftX);
  magnitude = sqrt(pow(leftX,2) + pow(leftY,2));
  output = cos(2 * angle);
  
  // remap the magnitude eliminating any slack in the joystick
  magnitude = map(magnitude, sqrt(2 * pow(tolerance,2)), 1, 0, 1 );
  
  // joystick is not a perfect circle, therefore ignore anything
  // greater than 1.0 or less than zero
  if(magnitude > 1.0)
    magnitude = 1.0; 

  if(magnitude < 0)
    magnitude = 0;

  if(DEBUG == true) {
    textFont(f,16);
    text("leftX: " + leftX, 200, 15);
    text("leftY: " + leftY, 200, 35);
  }
  
//-------------------- Single Joystick Mode ---------------------------------------
  
  // for mode 1 we will use the magnitude to take up the slack in the joystick
  // magnitude depends on both x and y of the left joystick
  // mode 0 will be dependent on the y-axis of the joysticks only
  if(mode == 1) 
  {
    if(angle < 0 && angle > -PI/2) // Quadrant I 
    {
      leftY = -1 * magnitude;
      rightY = output * magnitude; 
    }
    else if(angle < -PI/2 && angle > -PI) // Quadrant II
    {
      rightY = -1 * magnitude;
      leftY = output * magnitude;
    }  
    else if(angle < PI && angle > PI/2) // Quadrant III
    {
      leftY = magnitude;
      rightY = -1 * output * magnitude;
    }
    else if(angle < PI/2 && angle > 0) // Quadrant IV
    {
      rightY = magnitude;
      leftY = -1* output * magnitude;
    }
    
    // for mode 1 only!
    // set output to zero if A is pressed of magnitude is zero
    if(mode == 1 && A.pressed() || magnitude == 0) {
      leftY = 0;
      rightY = 0;
    }
  }
  
//--------------------- Skid Steer Mode -------------------------------------------  
  
  // for mode 0 only! set to zero if x and y are below tolerances 
  // this makes up for the joysticks not always re-centering to exactly zero
  if(mode == 0)
  {   
    // for mode 0 only!
    // set to zero if triggers are pressed 
    if(L1.pressed())
      leftY = 0;
      
    if(R1.pressed())
      rightY = 0;
  }

  // remap left and right Y axis
  // invert if negative so that the magnitude always goes from 0-127
  // leftY is remapped from -128 to 127. this is for display only
  // doing the way I had previously done it left a little flicker
  // or shutter when switching between positive and negative values
  if(leftY < -tolerance) {
    lOutput = byte(map(leftY, -1, -tolerance, 127, 0));
    leftY = map(leftY, -1, -tolerance, 127, 0);
  }  
  else if(leftY > tolerance) {
    lOutput = byte(map(leftY, tolerance, 1, 128, 255));
    leftY = map(leftY, tolerance, 1, 0, -128);
  }  
  else {
    lOutput = 0;
    leftY = 0;
  }
  
  if(rightY < -tolerance) {
    rOutput = byte(map(rightY, -1, -tolerance, 127, 0));
    rightY = map(rightY, -1, -tolerance, 127, 0);
  }  
  else if(rightY > tolerance) {
    rOutput = byte(map(rightY, tolerance, 1, 128, 255));
    rightY = map(rightY, tolerance, 1, 0, -128);
  }  
  else {
    rOutput = 0;  
    rightY = 0; 
  }
  
//---------------------------------------------------------------------------------
  
  // Don't forget to umcomment this once you're ready to start using 
  // the microcontroller!
  //sendPackage(lOutput, rOutput);

//-------------------- Draw Stuff Here --------------------------------------------
  
  rectMode(CENTER);

  fill(154, 154, 154); // light grey
  
  // draw sliders
  rect(leftLine, height/2, 20, 256);
  rect(rightLine, height/2, 20, 256); 
  
  // draw center lines
  line(leftLine - 40, height/2, leftLine + 40, height/2);
  line(rightLine - 40, height/2, rightLine + 40, height/2);
  
  // draw rectangles for sticks
  if((mode == 0 && L1.pressed()) || (mode == 1 && A.pressed())) {
    fill(255,0,0); // red
    rect(leftLine, height/2 - leftY, 40, 20);
  }
  else {
    fill(0);
    rect(leftLine, height/2 - leftY, 40, 20);
  }

  if((mode == 0 && R1.pressed()) || (mode == 1 && A.pressed())) {
    fill(255,0,0); // red
    rect(rightLine, height/2 - rightY, 40, 20);
  }
  else {
    fill(0);
    rect(rightLine, height/2 - rightY, 40, 20);
  }
  
  textFont(f,16);               
  fill(0);
  
  textAlign(RIGHT, CENTER);
  text(int(leftY), leftLine - 50, height/2);
  textAlign(LEFT, CENTER);
  text(int(rightY), rightLine + 50, height/2);
  
  textAlign(CENTER, BASELINE);
  textFont(f,14);
  text("Output: " + binary(lOutput,8),leftLine, height/2 - 150);
  text("Output: " + binary(rOutput,8),rightLine, height/2 - 150);
 
  textAlign(CENTER, TOP);
  textFont(f,18);
  text("L", leftLine, height/2 + 140);
  text("R", rightLine, height/2 + 140); 
  
  textAlign(CENTER, BASELINE);
  textFont(b,14);
  if(mode == 0 && DEBUG == false)
    text("Skid Steer", width/2, 20);
  else if (mode % 2 != 0 && DEBUG == false)
    text("Single Stick Mode (Left Stick)", width/2, 20);
  
  textAlign(LEFT);
  textFont(b,14);
  text("mode: " + mode, 20, 20);
  
  // display extra info
  if(DEBUG == true) {
    textAlign(LEFT, BASELINE);
    textFont(f,14);
    text("Angle: " + degrees(angle), 20, height/2 + 170);
    text("Magnitude: " + magnitude, 200, height/2 + 170);
    text("Output: " + output, 20, height/2 + 190);
  }
}

void sendPackage(byte leftMotor, byte rightMotor) 
{    
    myPort.write(HEADER);
    myPort.write(leftMotor);
    myPort.write(rightMotor);  
}  
