# Arduino Flutter Car

This app is created with flutter and used to control a robot car via bluetooth.

## Mobile App

The bluetooth connection is handled with the plugin [flutter_bluetooth_serial](https://pub.dev/packages/flutter_bluetooth_serial).

![App UI](/images/UI_flutter_Page1.png)

The control UI of the app is created with the [button_control](https://pub.dev/packages/control_button) module.
![App UI](/images/UI_flutter_Page2.png)

## Arduino Control

The code for the arduino can be found in the folder _/ino_files/motor_control/motor_control.ino_.
The robot has two modes, automatic and manual.
THe hardware needed in order to build the robot is:

- Arduino UNO(or similar)
- L298N1 Motor controller
- HC-06 Bluetooth module
- 2 DC motors
- Sharp IR Sensor
- 2 9V Bateries
- Switch

### Sketch

![Sketch](/images/Sketch_Arduino.png)
