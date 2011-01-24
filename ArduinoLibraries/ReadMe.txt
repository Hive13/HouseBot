
====== How to Install Arduino Libraries ======
The following was shamelessly stolen from: http://www.ladyada.net/library/arduino/libraries.html

In Arduino v16 and earlier, libraries were stored in the ArduinoInstallDirectory/hardware/libraries folder, which also contained all the built-in libraries (like Wire and Serial).

In v17 and up, the user libraries are now stored in the ArduinoSketchDirectory/libraries folder. You may need to make the libraries sub-folder the first time. However, the good thing about this is you wont have to move & reinstall your libraries every time you upgrade the software.

For example... C:\Documents and Settings\ladyada\My Documents\Arduino\libraries\NewSoftSerial

======= What Libraries Are We Including? =====
- Adafruit Motor Shield Library:
    This is so that we can easily control the motors.
- QTISensor
    This is for the line detection sensors.
- SonicSensor
    This is for the sonar distance sensors.
            