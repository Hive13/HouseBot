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
// action Modes
#define IDLE 0
#define SCANNING 1
#define LOCKINGON 2
#define CHARGING 3

// Directions
#define UNK   0
#define LEFT  1
#define RIGHT 2
#define FWD   3
#define BWD  4
#define STOP  5

// In-Range distance
#define INRANGE 500
// In-Sight (targeting aquired)
#define TARGETING_RANGE 50
// Left and Right Motors
#define LEFT_MOTOR 3
#define RIGHT_MOTOR 4

// The standard motor speed used for driving.
#define MTR_SPEED 255
#define L_OFF     0
#define R_OFF     0

// The speed to decrease motor to when turning.
#define TURN_MTR_SPEED 175

#include <QTISensor.h>
#include <SonicSensor.h>
#include <AFMotor.h>

QTISensor gs;   // GS = Ground Sensor
SonicSensor view;  // Front view

AF_DCMotor mtrLeft(LEFT_MOTOR);
AF_DCMotor mtrRight(RIGHT_MOTOR);

// If debuging is on output to serial
int debug = 0;
// Where was target last seen
int targetDirection = UNK;
// Current Direction State
int currentDirection = STOP;

// States
int stateRight = 0;
int stateLeft  = 0;
int stateBack  = 0;

void setup() {
  // put your setup code here, to run once:
  // sleep 3 seconds
  delay(3000);
  if(debug) {
     Serial.begin(9600);
  }
  // NOTE: The motorshield doesn't use the analog pins (or digital pins 14-19) or pins 2 and 13.
  // We will use the digital version of the analog pins
  view.setLeftSonarPin(14);
  view.setRightSonarPin(15);
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
// Returns true if one was seen.
// Sets targetDirection as well
int look() {
  int leftEye = view.pulseLeftSonar();
  int rightEye = view.pulseRightSonar();
  
  if(debug) {
    Serial.print("Left Eye = ");
    Serial.print(leftEye);
    Serial.println();
    Serial.print("Right Eye = ");
    Serial.print(rightEye);
    Serial.println();
  }
  
  // NOTE: Potential issue with this function, or at least poor coding.  
  //       We hit this every time 'loop' is run.  This means that lets say
  //       we are 'Charging' forward, we will call the 'driveForward()' function
  //       repeatedly, and unnessesarily, because we are already driving forward.
  //       Maybe create a state variable and keep track of what we are currently
  //       doing?
  
  // Does either eye see something < 77 cm away?
  if(leftEye < INRANGE || rightEye < INRANGE) {
    // Are the Left && Right eye values within a fuzzy range of each other?
    if(leftEye > rightEye - TARGETING_RANGE && 
       leftEye < rightEye + TARGETING_RANGE) {
      // Yes! Attack!
      if(debug) {
        Serial.println("Targeting Acquired, CHARGE!!");
      } 
      //stateBack = 0;
      stateLeft = 0;
      stateRight = 0;
    } else if(leftEye > rightEye) {
      // Ok.. So one eye is in range, the other is not at all.
      // If the leftEye is farther out of range, we need to go left.
      if(rightEye) {
        if(debug) {
          Serial.println("Go Left");
        } 
        targetDirection = LEFT;
        stateLeft = 0;
        stateRight += 4;
        //stateBack = 0;
      } else { // For some reason we don't have visual on rightEye
        Serial.println("Left eye only targeting acquire");
        // TODO: Still need to do fancyness here!
        stateLeft = 0;
        stateRight = 0;
        //stateBack = 0;
      }
    } else if(rightEye > leftEye) {
      // Ok.. So one eye is in range, the other is not at all.
      // If the right eye is farther out of range, we need to go right.
      if(leftEye) {
        if(debug) {
          Serial.println("Go Right");
        }
        targetDirection = RIGHT;
        stateRight = 0;
        stateLeft += 4;
        //stateBack = 0;
      } else { // We are blind in our left eye
        Serial.println("Right eye blind targeting acquire"); 
        // TODO: Still need to do fancyness here!
        stateRight = 0;
        stateLeft = 0;
        //stateBack = 0;
      }
    }
  } /*else {
    // Neither eye has anything in range, so lets start rotating in place.
    
    if(RIGHT == targetDirection) {
      rotateRight();
    } else {
      rotateLeft();
    }
    
  }
  */
}

// print debugging messages
void debugEdge(int edge) {

   int val = gs.rightQTI();
   Serial.print("R");
   Serial.print(val, DEC);
   Serial.println();
   Serial.print("L");
   Serial.print(gs.leftQTI());
   Serial.println();
   if(edge > 0) {
    Serial.print("_L_");
    Serial.print(gs.getLeftThreshold(), DEC);
    Serial.print(" _R_");
    Serial.print(gs.getRightThreshold(), DEC);
    if(edge == QTI_LEFT)
      Serial.print("!L!");
    else if(edge == QTI_RIGHT)
      Serial.print("!R!");
    else if(edge == QTI_BOTH)
      Serial.print("!B!");
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
      stateBack--;
      if(currentDirection != BWD) {
        driveBackward();
      }
    } else {
      if(!stateLeft && !stateRight) {
        if(currentDirection != FWD)
          driveForward();
      } // else we are already going forward
    }
    if(!stateBack) {
       if(stateLeft) {
        stateLeft--;
        if(currentDirection != LEFT) {
          rotateLeft();
        }
      } else if (stateRight) {
        stateRight--;
        if(currentDirection != RIGHT) {
          rotateRight();
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
  } else if (QTI_RIGHT == edge) {
    // Turn 90 deg right
    targetDirection = RIGHT; // look() will handle turning from here.
    stateRight = 140;
    stateBack = 2;
    
  } else if (QTI_LEFT == edge) {
    // turn 90 deg left
    targetDirection = LEFT; // look() will handle turning from here.
    stateLeft = 140;
    stateBack = 2;
    
  } else if (QTI_BOTH == edge) {
    // backup for a bit
    if(currentDirection != BWD)
      driveBackward();
    // turn 180 degrees
    stateBack = 10;
    // delay here?
    stateRight = 40;
    stateLeft = 0;
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

void loop() {
  // put your main code here, to run repeatedly: 
// REMOVE ME
//currentDirection = FWD;
    // Souround all motor controls with a check to see if we want to stop
    if(currentDirection != STOP) {
       drive(); 
 //      look();
//       delay(100);
    }
  /**/
}
