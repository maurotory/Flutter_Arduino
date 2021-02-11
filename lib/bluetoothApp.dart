import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'robotCarApp.dart';

class BluetoothApp extends StatefulWidget {
  final Function(BluetoothConnection) callback;
  BluetoothApp(this.callback);
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
          widget.callback(connection);

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
    print(connection);
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
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bluetooth Connection',
                  style: TextStyle(fontSize: 20),
                ),
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
                Icon(
                  Icons.bluetooth,
                  size: 30,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Devices', style: TextStyle(fontSize: 20)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
