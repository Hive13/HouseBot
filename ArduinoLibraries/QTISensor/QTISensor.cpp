#include "WProgram.h"
#include "QTISensor.h"

#define TIMEOUT 2000

int l_avg = 0;
int r_avg =0 ;


QTISensor::QTISensor()
{
  /* Defaults are actually analog */
  LeftQTIPin = 16;
  RightQTIPin = 17;
  r_threshold = 0; // threshold, avg of 20 readings * 0.8 set in calibrate
  l_threshold = 0; // threshold, avg of 20 readings * 0.8 set in calibrate
  _history = 0; // number of time to detect edge before returning edge 
  l_history = 0; // counter for the number of time left edge was detected
  r_history = 0; // counter for the number of time left edge was detected
}

int QTISensor::pulseQTI(int pin)
{
  int timecount = 0;
  bool fail = false;
  pinMode(pin, OUTPUT);
  digitalWrite(pin, HIGH);  // Discharges capacitor
  delay(1);
  pinMode(pin, INPUT);
  digitalWrite(pin, LOW); // turn pullups off - or it won't work  
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

// increment history if read value are inferior to threshold (see calibrate)
  if (left <= l_threshold) l_history++;
  else l_history=0;
  if (right <= r_threshold) r_history++;
  else r_history=0;
//check if l_ & r_ history are over the history trigger and return edge
  if (l_history>= _history && r_history>= _history) {
    l_history = 0;
    r_history = 0;
    return QTI_BOTH;
  }
  else if (l_history>= _history){
    l_history = 0;
    r_history = 0;
    return QTI_LEFT;
  }  
  else if (r_history>= _history){
    l_history = 0;
    r_history = 0;
    return QTI_RIGHT;
  } 
 // if value read is 2 times bigger than historic value, we are off the board
 if(left >= l_avg && right >= r_avg) {
   	return QTI_EDGE_BOTH;
   } else if(left >= l_avg) {
   	return QTI_EDGE_LEFT;
   } else if (right >= r_avg) {
   	return QTI_EDGE_RIGHT;
   } 

  /* if(left <= l_threshold && right <= r_threshold) {
   l_history++;
   r_history++;
   if(l_history >= _history && r_history >= _history){
   l_history = 0;
   r_history = 0;
   	    return QTI_BOTH;}
   }
   if(left <= l_threshold && right > r_threshold ) {
   l_history++;
   r_history = 0;
   if(l_history >= _history){
   l_history = 0
   	    return QTI_LEFT;}
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
   //r_avg = r_threshold / 0.8;
   //l_avg = l_threshold / 0.8;
   if(left >= l_avg && right >= r_avg) {
   	return QTI_EDGE_BOTH;
   } else if(left >= l_avg) {
   	return QTI_EDGE_LEFT;
   } else if (right >= r_avg) {
   	return QTI_EDGE_RIGHT;
   }
   */
  return QTI_NONE;
}
// Set threshold valu
void QTISensor::setRightThreshold(int limit)
{
  r_threshold = limit;
}

void QTISensor::setLeftThreshold(int limit)
{
  l_threshold = limit;
}

// Return the threshold value
int QTISensor::getRightThreshold()
{
  return r_threshold;
}

int QTISensor::getLeftThreshold()
{
  return l_threshold;
}

// Take a ground sampling to figure out what is "black" and store this value in l_threshold and r_threshold
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
      lastnum_r = rval; //ooooops was (lastnum_r + rval) / 2 but was still working !? 
    } 
    else {
      lastnum_l = (lastnum_l + lval) / 2;
      rval = rightQTI();
      lastnum_r = (lastnum_r + rval) / 2;
    }
  }
  // define the limit over motors stop
  l_avg = lastnum_l * 2;
  r_avg = lastnum_r * 2;

  // 80% of the calculated average each sensor to avoid false edge
  setLeftThreshold(lastnum_l * 0.1);
  setRightThreshold(lastnum_r * 0.2);


}

// Sets the number of sequential hits necessary to detect an edge
void QTISensor::sethistory(int count)
{
  _history = count;
}

