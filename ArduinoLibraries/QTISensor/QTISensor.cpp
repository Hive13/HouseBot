#include "WProgram.h"
#include "QTISensor.h"

#define TIMEOUT 2000

QTISensor::QTISensor()
{
  /* Defaults are actually analog */
  LeftQTIPin = 16;
  RightQTIPin = 17;
  r_threshold = 0;
  l_threshold = 0;
  _history = 0;
  l_history = 0;
  r_history = 0;
}

int QTISensor::pulseQTI(int pin)
{
  int timecount = 0;
  bool fail = false;
  pinMode(pin, OUTPUT);
  digitalWrite(pin, HIGH);  // Discharges capacitor
  delay(1);
  pinMode(pin, INPUT);
  //digitalWrite(pin, LOW);
  while(digitalRead(pin) && !fail) { // Wait for pin to go low
    timecount++;
    if(timecount > TIMEOUT)
    fail = true;
  }
  if(fail)
    return 0;
  return timecount;
}

int QTISensor::leftQTI()
{
  return pulseQTI(LeftQTIPin);
}

int QTISensor::rightQTI()
{
  return pulseQTI(RightQTIPin);
}

void QTISensor::setLeftQTIPin(int pin)
{
  LeftQTIPin = pin;
}

void QTISensor::setRightQTIPin(int pin)
{
  RightQTIPin = pin;
}

int QTISensor::edgeDetected()
{
  int left = leftQTI();
  int right = rightQTI();
  int r_avg;
  int l_avg;
  
  if(left <= l_threshold && right <= r_threshold) {
    l_history++;
    r_history++;
    if(l_history >= _history && r_history >= _history)
	    return QTI_BOTH;
  }
  if(left <= l_threshold) {
    l_history++;
    r_history = 0;
    if(l_history >= _history)
	    return QTI_LEFT;
  } else
    l_history = 0;
  if(right <= r_threshold) {
    r_history++;
    l_history = 0;
    if(r_history >= _history)
	    return QTI_RIGHT;
  } else
    r_history = 0;
  // We have determined that there isn't an edge above the hysteresis at this point.  Send an additional flag if we are falling off the edge.  Negative value
  r_avg = r_threshold / 0.8;
  l_avg = l_threshold / 0.8;
  if(left >= l_avg *2 && right >= r_avg *2) {
	return QTI_EDGE_BOTH;
  } else if(left >= l_avg *2) {
	return QTI_EDGE_LEFT;
  } else if (right >= r_avg  *2) {
	return QTI_EDGE_RIGHT;
  }
	
  return QTI_NONE;
}

void QTISensor::setRightThreshold(int limit)
{
  r_threshold = limit;
}

void QTISensor::setLeftThreshold(int limit)
{
  l_threshold = limit;
}

int QTISensor::getRightThreshold()
{
  return r_threshold;
}

int QTISensor::getLeftThreshold()
{
  return l_threshold;
}

// Take a ground sampling to figure out what is "black"
void QTISensor::calibrate()
{
  int lval, rval, firstcal, lastnum_l, lastnum_r;
  int count;

  firstcal = 1;
  for(count = 0; count < 20; count++) {
    lval = leftQTI();
    if(firstcal) {
      firstcal = 0;
      lastnum_l = lval;
      rval = rightQTI();
      lastnum_r = (lastnum_r + rval) / 2;
    } else {
      lastnum_l = (lastnum_l + lval) / 2;
      rval = rightQTI();
      lastnum_r = (lastnum_r + rval) / 2;
    }
  }
  // 80% of the calculated average each sensor
  setLeftThreshold(lastnum_l * 0.8);
  setRightThreshold(lastnum_r * 0.8);
}

// Sets the number of sequential hits necessary
void QTISensor::sethistory(int count)
{
   _history = count;
}
