

/*
 * Hive13 Sumobot AI Code
 *
 * Designed to work with the Diavolino
 *
 * Components:
 *   2 Ping Ultra Sonic sensors (http://www.arduino.cc/en/Tutorial/UltrasoundSensor)
 *   2 Sensors for line detecting (http://www.arduino.cc/playground/Main/QTI)
 *   2 Motors for the back wheels (http://www.ladyada.net/make/mshield)
 *    ^- Motorshield
 */
 /****************/ 
 /*** AI Logic ***/
 /****************/
 /*
      1) SCAN for targets
         a) If target seen goto LOCKON
         b) If 360 Scan complete, start driving outward in a spiral pattern.
      2) LOCKON to target.  Try to get equal distance between view sensors
         a) Rotate in given direction until lockon complete
         b) Once locked on, CHARGE
      3) CHARGE the target
         a) if white bar detected with ground sensor then stop and SCAN
         b) if target escapes view sensor, stop and SCAN

    Possible mode: If 360 scan comes up empty attempt to goto center of
       arena.  Complete one more scan.  Then do some victory thing. Or more
       dangerous... find edge then drive around it to 'sweep' the edge clear
       before moving to the center.
 
 */

/* Defines */ 
// action Modes not used
#define IDLE 0
#define SCANNING 1
#define LOCKINGON 2
#define CHARGING 3

// Directions used only used by drive? 
#define UNK   0
#define LEFT  1
#define RIGHT 2
#define FWD   3
#define BWD  4
#define STOP  5

// In-Range distance
#define INRANGE 3000
// In-Sight (targeting aquired)
#define TARGETING_RANGE 100
// Left and Right Motors
#define LEFT_MOTOR 3
#define RIGHT_MOTOR 4


#include <QTISensor.h>
#include <SonicSensor.h>
#include <AFMotor.h>

QTISensor gs;   // GS = Ground Sensor
SonicSensor view;  // Front view

AF_DCMotor mtrLeft(LEFT_MOTOR);
AF_DCMotor mtrRight(RIGHT_MOTOR);

// The standard motor speed used for driving.
int MTR_SPEED=225;
int L_OFF=0;
int R_OFF=0;

// The speed to decrease motor to when turning.
int TURN_MTR_SPEED=175;


// If debuging is on output to serial
int debug = 1;
// Where was target last seen not used
int targetDirection = UNK;
// Current Direction State
int currentDirection = STOP;

// States counter of iteration the motor will run in one direction
// can be accessed by qti sensor and sonic sensor
int stateRight = 0;
int stateLeft  = 0;
int stateBack  = 0;

//Sonar setup
int LeftSonarPin = 14;
int RightSonarPin = 15;
int sonarrange = 2000; // max range to look for enemy

void setup() {
  // put your setup code here, to run once:
  // sleep 3 seconds
  delay(3000);
  if(debug) {
     Serial.begin(9600);
     // The slow motor speed used for testing.
    MTR_SPEED=100;
    L_OFF=0;
    R_OFF=0;
    // The speed to decrease motor to when turning.
    TURN_MTR_SPEED=75;  
}
  // NOTE: The motorshield doesn't use the analog pins (or digital pins 14-19) or pins 2 and 13.
  // We will use the digital version of the analog pins
  gs.setLeftQTIPin(16);
  gs.setRightQTIPin(17); 
  gs.calibrate();  // Autodetect darkness since we start on black.
  gs.sethistory(2); // Must trigger twice in a row
  
  // Make sure both motors start off stopped.
  mtrLeft.run(RELEASE);
  mtrRight.run(RELEASE);
  
  // When the motors are started, make sure they run
  // at the set max speed.
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(MTR_SPEED + R_OFF);

  if(debug) {
    Serial.println("Setup complete");
  }
  // For sumobots the bot must wait 5 seconds after powering on before they
  // can move.  Time this to ensure there isn't a false start.
  delay(2000);
  driveForward();
}

// Looks for a target
// Modify state left and state right to modify direction
// Sets targetDirection as well not used currently
int look() {
  int leftEye = view.pulseSonar(LeftSonarPin,sonarrange);
  delay(3);// to avoid any echo between left and right sonar need delay between trigger, sound travels 340 m/s, mex range for sensor 3.3m
  // approx 1ms to go + 1 ms to bounce back, add 1 ms for safety
  int rightEye = view.pulseSonar(RightSonarPin,sonarrange);
  
  if(debug) {
    Serial.print("#### SONIC SENSOR ####");
    Serial.println();    
    Serial.print("Left Eye = ");
    Serial.print(leftEye);
    Serial.print("; Right Eye = ");
    Serial.print(rightEye);
    Serial.println();
  }
  
  // NOTE: Potential issue with this function, or at least poor coding.  
  //       We hit this every time 'loop' is run.  This means that lets say
  //       we are 'Charging' forward, we will call the 'driveForward()' function
  //       repeatedly, and unnessesarily, because we are already driving forward.
  //       Maybe create a state variable and keep track of what we are currently
  //       doing?
  
  // Does either eye see something < 77 cm away and target any of the eye seing anything
  if ((leftEye < INRANGE || rightEye < INRANGE) && (leftEye >0 || rightEye>0)) {
    // Are the Left && Right eye values within a fuzzy range of each other?
    if(abs(leftEye- rightEye) < TARGETING_RANGE)  {
      // Yes! Attack!
      if(debug) 
      {
        Serial.println("Targeting Acquired in front, CHARGE!!");
      } 
      //stateBack = 0; do not override stateback if baking from ring border
      stateLeft = 0; // no need to move reset stateleft and stateback
      stateRight = 0;
    } 
    else if((leftEye > rightEye) && (leftEye >0 && rightEye>0)){
      // Ok.. left eye see something farther than right eye, but both see
      // If the leftEye is farther out of range, we need to go right
        if(debug) {
          Serial.println("I saw something on the right but not quiet yet in the center"); // go right?
        } 
        targetDirection = RIGHT;
        stateLeft = 0;
        stateRight += 1;
        //stateBack = 0; 
   } 
    else if((rightEye > leftEye)  && (leftEye >0 && rightEye>0)){
      // Ok.. right eye see something farther than left eye, but both see
      // If the right eye is farther out of range, we need to go right. // again you need to go left
        if(debug) {
          Serial.println("I saw something on the left but not quiet yet in the center");
        }
        targetDirection = LEFT;
        stateLeft += 1;
        stateRight = 0;
        //stateBack = 0;
    }
    else if((leftEye > rightEye) && (leftEye >0 && rightEye==0)){
      // Ok.. left eye see but not right eye, we need to go left
        if(debug) {
          Serial.println("I saw something on the left but nothing with my right eye let's turn left"); // go right?
        } 
        targetDirection = LEFT;
        stateLeft += 2;
        stateRight = 0;
        //stateBack = 0; 
   } 
    else if((rightEye > leftEye)  && (leftEye ==0 && rightEye>0)){
      // Ok.. right eye see but not left eye, we need to go left
        if(debug) {
          Serial.println("I saw something on the right but nothing with my left eye let's turn right");
        }
        targetDirection = RIGHT;
        stateLeft = 0;
        stateRight += 2;
        //stateBack = 0;
    }
    
    
  } 
// don't see anything on both eyes, so turn a bit on yourself
if (rightEye == 0 && leftEye == 0) {
        if(debug) {
          Serial.println("No enemy within range let's turn a bit in one direction");
        }
        // only modify direction if we didn't have any previous order before
        if (stateLeft==0 && stateRight==0) {
        targetDirection = UNK;
        stateLeft += 0;
        stateRight += 0;}
}

}


// print debugging messages
void debugEdge(int edge) {

   Serial.print("#### DEBUG EDGE ####");
   Serial.println();
   Serial.print("Left QTI : ");
   Serial.print(gs.leftQTI());
   Serial.print(" Right QTI : ");
   Serial.print(gs.rightQTI());
   Serial.println();
   Serial.print("_Left threshold : ");
   Serial.print(gs.getLeftThreshold(), DEC);
   Serial.print(" _Right threshold : ");
   Serial.print(gs.getRightThreshold(), DEC);
   Serial.println();
   if(edge > 0) {
    if(edge == QTI_LEFT)
      Serial.print("!Left Edge!");
    else if(edge == QTI_RIGHT)
      Serial.print("!Right Edge!");
    else if(edge == QTI_BOTH)
      Serial.print("!Both Edge!");
    Serial.println();
    Serial.println("EDGE DETECTED"); 
   }
   //val = view.pulseLeftSonar();
   //Serial.print("))) L=");
   //Serial.print(val, DEC);
   //Serial.println();
  
      if(stateLeft) {
        Serial.print("stateLeft=");
        Serial.print(stateLeft);
        Serial.println();
      }
      if(stateRight) {
        Serial.print("stateRight=");
        Serial.print(stateRight);
        Serial.println();
      }
      if(stateBack) {
        Serial.print("stateBack=");
        Serial.print(stateBack);
        Serial.println();
      }
}

// Generic edge detection and driving loop
void drive() {
  int edge = QTI_NONE;
  edge = gs.edgeDetected();

  if(debug)
     debugEdge(edge);
     
  if (stateBack) {
      stateBack--;// decrease state back until = 0
      if(currentDirection != BWD) { // if not already driving backward then drive backward
        driveBackward();
      }
    } else {// stateback is not equal to 0
      if(!stateLeft && !stateRight) { // if state left or state right are different from 0 then drive forward
        if(currentDirection != FWD) // if not already driving FWD then drive fwd
          driveForward();
      } // else we are already going forward
    }
    if(!stateBack) {
       if(stateLeft) {
        stateLeft--; // decrease state left until = 0
        if(currentDirection != LEFT) {// if not already driving left then drive left
          turnLeft();
        }
      } else if (stateRight) {
        stateRight--;// decrease state fight until = 0
        if(currentDirection != RIGHT) { // if not already driving right then drive right
          turnRight();
        }
      } 
    }

  /**/
  // Do we detect any edges?
  if(!edge) {
    // No edges detected.
    // Lets correct the course based on the distance sensors.
    //look();
    if(debug) {
      Serial.println("No edge continue doing what I'm doing");
      switch(currentDirection) {
        case BWD:
        Serial.println("Going Backward");
        break;
        case FWD:
        Serial.println("Going Forward");
        break;
        case RIGHT:
        Serial.println("Right");
        break;
        case LEFT:
        Serial.println("Left");
        break;
        default:
        Serial.println("Unkown state");
        break;
      }
    }
  } else if (QTI_RIGHT == edge) {// if edge dectected on the right side then 
    // Turn 90 deg right
    targetDirection = RIGHT; // look() will handle turning from here.
    stateBack = 2;
    if (stateRight ==0)
    stateRight+=1;
    
  } else if (QTI_LEFT == edge) {// if edge detected on the left side then
    // turn 90 deg left
    targetDirection = LEFT; // look() will handle turning from here.
    stateBack = 2;
    if (stateLeft ==0)
    stateLeft+=1;
    
  } else if (QTI_BOTH == edge) {// if edge is detected on both side
    // backup for a bit
    if(currentDirection != BWD)
      driveBackward();
    // turn 180 degrees
    stateBack = 10;
    // delay here?
    if (stateRight ==0)
    stateRight+=3;
    //stateLeft = 0;
  } else if (QTI_EDGE_BOTH == edge) { // We done fell off (or are close)
    stopMotors();
  }
  //*/ 
}

/*----------------------------------------------------------------------------
 *(PTV: 10/12/2010)
 *  Some thoughts on turning:
 *  - We have two ways to turn in my mind:
 *    1. Turn one wheel forward, one wheel backward
 *    2. Turn one wheel at a slower rate than the other.
 *  - With this in mind, perhaps we want to pass a radius into the 
 *     "turn(left|right)" function?
 *  - Also, I see the "turn(left|right)" functions as mainly setting the
 *    the turn directions then we can continue to do processing until we need
 *    to change direction again.  I would link to my RoboCar code, but the SVN
 *    repository is down for it right now.
 *----------------------------------------------------------------------------
 *(PTV: 10/28/2010)
 * Current turning logic:
 * - Two sets of functions:
 *    1. rotate(Left|Right)
 *       - The bot stops moving forward, and spins in the specified direction.
 *    2. turn(Left|Right)
 *       - The bot increases the speed of one wheel causing the bot to turn
 *         in the specified direction while moving.
 *----------------------------------------------------------------------------
 */

void stopMotors() {
  if(debug) {
    Serial.println("stopMotors()");
  }
  currentDirection = STOP;
  mtrLeft.run(RELEASE);
  mtrRight.run(RELEASE);
  stateRight = 0;
  stateLeft = 0;
  stateBack = 0;
}

// Stop and Rotate the bot left
void rotateLeft() {
  if(debug) {
    Serial.println("rotateLeft()");
  }
  currentDirection = LEFT;
  mtrLeft.run(BACKWARD);
  mtrRight.run(FORWARD);
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(MTR_SPEED + R_OFF);
  stateRight = 0;
}

// Turn left while moving forward.
void turnLeft() {
  if(debug) {
    Serial.println("turnLeft()");
  }
  currentDirection = LEFT;
  mtrLeft.run(FORWARD);
  mtrRight.run(FORWARD);
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(TURN_MTR_SPEED + R_OFF);
  stateRight = 0;
}

// Stop and Rotate the bot right
void rotateRight() {
  if(debug) {
    Serial.println("rotateRight()");
  }
  currentDirection = RIGHT;
  mtrLeft.run(FORWARD);
  mtrRight.run(BACKWARD);
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(MTR_SPEED + R_OFF);
  stateLeft = 0;
}

// Turn right while moving forward.
void turnRight() {
  if(debug) {
    Serial.println("turnRight()");
  }
  currentDirection = RIGHT;
  mtrLeft.run(FORWARD);
  mtrRight.run(FORWARD);
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(TURN_MTR_SPEED + R_OFF);
  stateLeft = 0;
}

void driveForward() {
  if(debug) {
    Serial.println("driveForward()");
  }
  currentDirection = FWD;
  mtrLeft.run(FORWARD);
  mtrRight.run(FORWARD);
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(MTR_SPEED + R_OFF);
  stateBack = 0;
}

void driveBackward() {
  if(debug) {
    Serial.println("driveBackward()");
  }
  currentDirection = BWD;
  mtrLeft.run(BACKWARD);
  mtrRight.run(BACKWARD);
  mtrLeft.setSpeed(MTR_SPEED + L_OFF);
  mtrRight.setSpeed(MTR_SPEED + L_OFF);
}

void debugdrive() { // print alse states + currentdirection and targetdirection
Serial.print("#### STATES & DIRECTION ####");
Serial.println();
Serial.print("stateLeft=");
Serial.print(stateLeft);
Serial.print("; stateRight=");
Serial.print(stateRight);
Serial.print("; stateBack=");
Serial.print(stateBack);
Serial.print("; current direction=");
Serial.print(currentDirection);
Serial.println();
}

void loop() {
  // put your main code here, to run repeatedly: 
// REMOVE ME
//currentDirection = FWD;
    // Souround all motor controls with a check to see if we want to stop
    if(currentDirection != STOP) {
          if(debug) {
         Serial.println("start to drive, displaying drive variable");
         debugdrive();
       }
       drive(); 
         if(debug) {
         Serial.println("end of drive then look");
         debugdrive();
       }
       look();
         if(debug) {
         Serial.println("end of look");
         debugdrive();
       delay(1);}
    }
  /**/
}
