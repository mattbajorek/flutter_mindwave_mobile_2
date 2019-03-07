import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_mindwave_mobile_2/flutter_mindwave_mobile_2.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  
  String _connectingStatus = 'disconnected';
  StreamSubscription _scanSubscription;
  StreamSubscription _deviceConnection;

  @override
  Widget build(BuildContext context) {
    var connectionStatusText = 'Connect';
    var connectionImageUrl = 'images/nosignal_v1.png';
    var handleButton = _scan;
    switch(_connectingStatus) {
      case 'scanning': {
        connectionStatusText = 'Scanning...';
        connectionImageUrl = 'images/connecting1_v1.png';
        handleButton = null;
      }
      break;
      case 'connecting': {
        connectionStatusText = 'Connecting...';
        connectionImageUrl = 'images/connecting2_v1.png';
        handleButton = null;
      }
      break;
      case 'connected': {
        connectionStatusText = 'Disconnect';
        connectionImageUrl = 'images/connected_v1.png';
        handleButton = _disconnect;
      }
      break;
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter MindWave Mobile 2 Plugin Example App'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    onPressed: handleButton,
                    child: Text(connectionStatusText),
                  ),
                  Image.asset(connectionImageUrl, width: 100.0, height: 100.0),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }

  void _scan() {
    // Start scanning
    setState(() {
      _connectingStatus = 'scanning';
    });
    _scanSubscription = flutterBlue
        .scan()
        .listen((ScanResult scanResult) {
          var name = scanResult.device.name;
          if (name == 'MindWave Mobile') {
            _scanSubscription.cancel();
            _connect(scanResult.device);
          }
        });
  }

  void _connect(BluetoothDevice device) {
    setState(() {
      _connectingStatus = 'connecting';
    });
    FlutterMindWaveMobile2
        .connect(device.id.toString());
//    _deviceConnection = flutterBlue
//        .connect(device)
//        .listen((BluetoothDeviceState state) {
//          if(state == BluetoothDeviceState.connected) {
//            setState(() {
//              _connectingStatus = 'connected';
//            });
//          }
//          // Keep retrying
//          else if (state == BluetoothDeviceState.disconnected) {
//            _deviceConnection.cancel();
//            _connect(device);
//          }
//        });
  }

  void _disconnect() {
//    _deviceConnection.cancel();
    setState(() {
      _connectingStatus = 'disconnected';
    });
  }
}
