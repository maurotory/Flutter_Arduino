import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:control_button/control_button.dart';
import 'homePageApp.dart';

class RobotCarApp extends StatefulWidget {
  BluetoothConnection connection;
  RobotCarApp(this.connection);

  @override
  _RobotCarAppState createState() => _RobotCarAppState();
}

class _RobotCarAppState extends State<RobotCarApp> {
  /*
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    print('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }
  */
  bool _automatic = false;
  String text = '';
  double _currentSliderValue = 20;

  void updateMode(bool automatic) async {
    String text = '';
    if (automatic) {
      widget.connection.output.add(utf8.encode('a' + "\r\n"));
      await widget.connection.output.allSent;
      setState(() {
        _automatic = automatic;
      });
    } else {
      widget.connection.output.add(utf8.encode('c' + "\r\n"));
      await widget.connection.output.allSent;
      setState(() {
        _automatic = automatic;
      });
    }
  }

  void updateState(String showText) async {
    widget.connection.output.add(utf8.encode(showText + "\r\n"));
    await widget.connection.output.allSent;
    setState(() {
      if (showText == 'r') {
        text = 'Rigth';
      } else if (showText == 'l') {
        text = 'Left';
      } else if (showText == 's') {
        text = 'Stop';
      } else if (showText == 'b') {
        text = 'Backwards';
      } else if (showText == 'f') {
        text = 'Forwards';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("RobotApp"),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePageApp()),
                  );
                },
                child: Icon(
                  Icons.home,
                  size: 26.0,
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Automatic Control', style: TextStyle(fontSize: 20)),
                  Switch(
                    value: _automatic,
                    onChanged: updateMode,
                  )
                ],
              ),
              ControlButton(
                sectionOffset: FixedAngles.Inclined45,
                externalDiameter: 300,
                internalDiameter: 120,
                dividerColor: Colors.blue,
                elevation: 2,
                externalColor: Colors.lightBlue[100],
                internalColor: Colors.grey[300],
                mainAction: () => updateState('s'),
                sections: [
                  () => updateState('r'),
                  () => updateState('f'),
                  () => updateState('l'),
                  () => updateState('b'),
                ],
              ),
              Slider(
                value: _currentSliderValue,
                min: 0,
                max: 250,
                divisions: 25,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) async {
                  widget.connection.output
                      .add(utf8.encode("p" + value.toString() + "o" + "\r\n"));
                  await widget.connection.output.allSent;
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
        ));
  }
}
