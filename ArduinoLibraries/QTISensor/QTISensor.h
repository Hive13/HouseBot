/*
 * QTI Sensor for Hive13 Sumobot
 *
 * The layout is currently 2 QTI sensors: left & right
 */
#ifndef __QTISENSOR_H__
#define __QTISENSOR_H__

#include "WProgram.h"

#define QTI_NONE       0
#define QTI_LEFT       1
#define QTI_RIGHT      2
#define QTI_BOTH       3
#define QTI_EDGE_LEFT  -1
#define QTI_EDGE_RIGHT -2
#define QTI_EDGE_BOTH  -3

class QTISensor
{
public:
  QTISensor();
  int pulseQTI(int);
  int leftQTI();
  int rightQTI();  
  void setLeftQTIPin(int);
  void setRightQTIPin(int);
  int edgeDetected();
  void setRightThreshold(int);
  void setLeftThreshold(int);
  int getRightThreshold();
  int getLeftThreshold();
  void calibrate();
  void sethistory(int);
private:
  int LeftQTIPin;
  int RightQTIPin;
  int l_threshold;
  int r_threshold;
  int _history;
  int l_history;
  int r_history;
};

#endif // __QTISENSOR_H__
