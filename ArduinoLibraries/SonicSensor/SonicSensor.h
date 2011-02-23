/*
 * Hive13 Sumobot Pulse))) Sonic Sensor library
 *
 * Assumed two front mounted sensors: left & right
 *
 */

#ifndef __SONIC_SENSOR_H__
#define __SONIC_SENSOR_H__

#include "WProgram.h"

class SonicSensor
{
public:
  //SonicSensor();
  int pulseSonar(int,int);
//  int pulseLeftSonar();
//  int pulseRightSonar();
//  void setLeftSonarPin(int);
//  void setRightSonarPin(int);
private:
//  int LeftSonarPin;
//  int RightSonarPin;
};

#endif // __SONIC_SENSOR_H__
