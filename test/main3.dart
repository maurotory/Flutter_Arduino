import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hello World"),
        ), /*
        body: Switch(
          value: _bluetoothState.isEnabled,
          onChanged: (bool value) {
            future() async {
              if (value) {
                //enable Bluetooth
                await FlutterBluetoothSerial.instance.requestEnable();
              } else {
                //disable Bluetooth
                await FlutterBluetoothSerial.instance.requestDisable();
              }
              //in orde to update the devices list
              await getPairedDevices();
              //_isButtonUnavailable = false;
              //Disconnect from any device before turning off Bluetooth
              if (_connected) {
                //_disconnect();
              }
            }

            future().then((_) {
              setState(() {});
            });
          },
        ),*/
      ),
    );
  }
}
