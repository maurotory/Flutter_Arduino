import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'bluetoothApp.dart';
import 'robotCarApp.dart';

class HomePageApp extends StatefulWidget {
  //BluetoothConnection connection;
  //HomePageApp(this.connection);

  @override
  _HomePageAppState createState() => _HomePageAppState();
}

class _HomePageAppState extends State<HomePageApp> {
  BluetoothConnection connection;

  void newConnection(BluetoothConnection connection) {
    this.setState(() {
      this.connection = connection;
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
      body: Column(
        children: [
          BluetoothApp(newConnection),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
            child: Text(
              'Projects',
              style: TextStyle(fontSize: 30),
            ),
          ),
          Container(
            padding: EdgeInsets.all(40.0),
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 30.0,
                        backgroundImage: AssetImage(
                          'images/robotCar.jpeg',
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text(
                        "RobotCar",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RobotCarApp(this.connection)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
