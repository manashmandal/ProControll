/* Motor
  This Arduino sketch called works in conjuction with my Processing sketch called Gamepad. 
  It reads three bytes to determine the motor speed and directions. This first byte is 
  the checkbyte chosen arbitrarily to indicate to the Arduino that the next two bytes are 
  motor bytes. The motor byte is split into two parts. The most significant bit tells the 
  Arduino which direction the H-Bridge should be. The next seven bits tell the Arduino what 
  the magnitude of speed (or the pulse width) should be. It takes four outputs to run two 
  motors. Two pins for the directions in which to control the H-Bridge and two pins to send 
  the PWM data to the left and right motors.
*/

byte checkByte = 0;         // incoming serial byte
byte lMotorSpeed = 0;
byte rMotorSpeed = 0;
byte lMotorDir = 0;
byte rMotorDir = 0;

const int lAnalogOutPin = 5;
const int rAnalogOutPin = 9;
const int lDirOutPin = 4;
const int rDirOutPin = 8;

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
  
  pinMode(lDirOutPin, OUTPUT);
  pinMode(rDirOutPin, OUTPUT);
}

void loop()
{
  if (Serial.available() > 2) {
    // get incoming byte:
    checkByte = Serial.read();
    
    // the checkbyte is '#'
    if(checkByte == 0b00100011) 
    {
      
      lMotorSpeed = Serial.read();
      rMotorSpeed = Serial.read();
      
      // This section is for debugging purposes only
      // It allows you to enter bytes using the Serial Monitor
      // and converts the decimal chars to a binary value. It expects 
      // a checkbyte '#' followed by two, three digit decimal 
      // values to be entered. The motor values are from 0-127.
      // So for example to make a PWM with 50% duty cycle on both
      // motors type this: "#064064
      
      /*
      Serial.println("checkByte OK!");
      
      lMotorSpeed = (Serial.read()-'0')*100;
      lMotorSpeed += (Serial.read()-'0')*10;
      lMotorSpeed += (Serial.read()-'0');
      
      Serial.print("L Value Read: ");
      Serial.println(lMotorSpeed, BIN);
      
      rMotorSpeed = (Serial.read()-'0')*100;
      rMotorSpeed += (Serial.read()-'0')*10;
      rMotorSpeed += (Serial.read()-'0');
      
      Serial.print("R Value Read: ");
      Serial.println(rMotorSpeed, BIN);
      */
    
      lMotorDir = bitRead(lMotorSpeed, 7);
      rMotorDir = bitRead(rMotorSpeed, 7);
      
      //More debugging stuff
      /*   
      Serial.print("L Motor Dir: ");
      Serial.println(lMotorDir, BIN);
      Serial.print("R Motor Dir: ");
      Serial.println(rMotorDir, BIN);
    
      if(lMotorDir) {
        Serial.println("L Motor Dir: Backwards");
      }  
      else {
        Serial.println("L Motor Dir: Forwards");
      }
      
      if(rMotorDir) {
        Serial.println("R Motor Dir: Backwards");
      }  
      else {
        Serial.println("R Motor Dir: Forwards"); 
      }
      */
      digitalWrite(lDirOutPin, lMotorDir);
      digitalWrite(rDirOutPin, rMotorDir);
      
      lMotorSpeed &= 127;
      rMotorSpeed &= 127;
      
      // Still more debugging stuff
      /*   
      Serial.print("L Motor Speed: ");
      Serial.println(lMotorSpeed, BIN);
      Serial.print("R Motor Speed: ");
      Serial.println(rMotorSpeed, BIN);
      */
 
      // PWM on the Arduino wants an 8 bit value so 
      // we will remap it.     
      lMotorSpeed = map(lMotorSpeed, 0, 127, 0, 255);
      rMotorSpeed = map(rMotorSpeed, 0, 127, 0, 255);
      
      analogWrite(lAnalogOutPin, lMotorSpeed);
      analogWrite(rAnalogOutPin, rMotorSpeed);
    }    
  }
}

