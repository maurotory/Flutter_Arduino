import 'dart:convert';
import 'package:control_button/control_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Old',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: BluetoothApp(),
    );
  }
}

class HomePageApp extends StatefulWidget {
  BluetoothConnection connection;
  HomePageApp(this.connection);

  @override
  _HomePageAppState createState() => _HomePageAppState();
}

class _HomePageAppState extends State<HomePageApp> {
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
                  MaterialPageRoute(builder: (context) => BluetoothApp()),
                );
              },
              child: Icon(
                Icons.bluetooth,
                size: 26.0,
              ),
            ),
          )
        ],
      ),
      body: Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: GestureDetector(
            child: Row(
              children: [
                CircleAvatar(
                  child: Image.asset('images/robotCar.jpeg'),
                ),
                Text(
                  "RobotCar",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                )
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RobotCarApp(widget.connection)),
              );
            },
          ),
        ),
      ),
    );
  }
}

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

  String text = '';

  void updateState(String showText) async {
    print("connection is :\n");
    print(widget.connection);
    widget.connection.output.add(utf8.encode(showText + "\r\n"));
    await widget.connection.output.allSent;
    setState(() {
      text = showText;
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
                  MaterialPageRoute(
                      builder: (context) => HomePageApp(widget.connection)),
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
            ControlButton(
              sectionOffset: FixedAngles.Inclined45,
              externalDiameter: 300,
              internalDiameter: 120,
              dividerColor: Colors.blue,
              elevation: 2,
              externalColor: Colors.lightBlue[100],
              internalColor: Colors.grey[300],
              mainAction: () => updateState('Selected Center'),
              sections: [
                () => updateState('1'),
                () => updateState('1'),
                () => updateState('0'),
                () => updateState('0'),
              ],
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
      ),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  //initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // get the instance of the bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  //track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  //to track wether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  //this variable will be used to track the Bluettoh device connection state
  int _deviceState;

  @override
  void initState() {
    super.initState();
    //get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _deviceState = 0; // neutral

    //if the bluetooth device is not enabled, then request permission
    enableBluetooth();

    //listen fo further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        //retriving the paired devices list
        getPairedDevices();
      });
    });
  }

  Future<void> enableBluetooth() async {
    //retrieving the current Buetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    //if off the turn it on and retrieve again
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  //list to store the devices
  List<BluetoothDevice> _devicesList = [];

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    //It is an error to call setStatte unless mounted is true
    if (!mounted) {
      return;
    }
    //Store the devices for accesing them outside the class
    setState(() {
      _devicesList = devices;
    });

    //aboid memory leaks to make sure that the connection is closed
    bool isDisconnecting = false;
    @override
    void dispose() {
      if (isConnected) {
        isDisconnecting = true;
        connection.dispose();
        connection = null;
      }
      super.dispose();
    }
  }

  //define the member variable for storing the current device connectivity status
  bool _connected = false;

  BluetoothDevice _device;

  bool _isButtonUnavailable = false;
  bool isDisconnecting = false;
  //method for storing devices in a list

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  //check if a device is selected from the list
  void _connect() async {
    if (_device == null) {
      //show('No device selected');
      print('No device selected');
    } else {
      //make sure the device is connected
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;

          setState(() {
            _connected = true;
          });

          //tracking disconnection process
          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnectinf locally!');
            } else {
              print('Disconnecting remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot Connect, exception ocurred');
          print(error);
        });
        //show('Device connected')
        print('Device Disconnected');
      }
    }
  }

  //metod to disconnect
  void _disconnect() async {
    await connection.close();
    //show('Device disconnected');
    print('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
      });
    }
  }

  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;
    print('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

// Method to send message
// for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    print('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("RobotApp"),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RobotCarApp(connection)),
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
          children: <Widget>[
            Switch(
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
                    _disconnect();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            DropdownButton(
                items: _getDeviceItems(),
                onChanged: (value) => setState(() => _device = value),
                value: _devicesList.isNotEmpty ? _device : null),
            RaisedButton(
              onPressed: _isButtonUnavailable
                  ? null
                  : _connected
                      ? _disconnect
                      : _connect,
              child: Text(_connected ? 'Disconnect' : 'Connect'),
            ),
            FlatButton(
              onPressed: _connected ? _sendOnMessageToBluetooth : null,
              child: Text("ON"),
            ),
            FlatButton(
              onPressed: _connected ? _sendOffMessageToBluetooth : null,
              child: Text("OFF"),
            )
          ],
        ),
      ),
    );
  }
}
