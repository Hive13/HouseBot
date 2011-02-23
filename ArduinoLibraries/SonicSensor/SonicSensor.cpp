
#include "WProgram.h"
#include "SonicSensor.h"

//#define TIMEOUT 500

//SonicSensor::SonicSensor()
//{
//  LeftSonarPin = 14;
//  RightSonarPin = 15;
//}

//void SonicSensor::setLeftSonarPin(int pin)
//{
//  LeftSonarPin = pin;
//}

//void SonicSensor::setRightSonarPin(int pin)
//{
//  RightSonarPin = pin;
//}

// Sends a pulse out of an ultra sonic sensor
// The sensors work by sending a Low-High-Low pulse and measuring the time
//   that it takes to see that bounce back.  The greater the width of the HIGH
//   wave the farther something is.
// Return the timecount of the return pulse
int SonicSensor::pulseSonar(int pin, int timeout)
{
  int val;
//  int timecount = 0;
  bool fail = false;
  
  /* Send a Low-High-Low pulse to activiate trigger sensor */
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  delayMicroseconds(2);
  digitalWrite(pin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pin, LOW);  // Holdoff
  
  /* Listen for echo pulse */
  pinMode(pin, INPUT);
  val = pulseIn(pin, HIGH, timeout);
  /*while(val == LOW && !fail) { // Loop until val == HIGH
  //  val = digitalRead(pin);
  //  timecount += 1;
  //  if(timecount > timeout)
  	fail = true;
  }
  if(fail)
	return 0;

  timecount = 0;
  while(val == HIGH && !fail) { // Counts high pulse time
    val = digitalRead(pin);
    timecount += 1;
    if(timecount > timeout)
	fail = true;
  }
  if(fail)
	return 0;*/
  return val;
}

//int SonicSensor::pulseLeftSonar()
//{
//  return pulseSonar(LeftSonarPin);
//}

//int SonicSensor::pulseRightSonar()
//{
//  return pulseSonar(RightSonarPin);
//}
