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
  StreamSubscription _eeSampleSubscription;
  StreamSubscription _eSenseSubscription;
  StreamSubscription _eegPowerLowBetaSubscription;
  StreamSubscription _eegPowerDeltaSubscription;
  StreamSubscription _eegBlinkSubscription;
  StreamSubscription _mwmBaudRateSubscription;

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
        .connect(device.id.toString())
        .then((_) {
          setState(() {
            _connectingStatus = 'connected';
          });
          _eeSampleSubscription = FlutterMindWaveMobile2
            .onEEGSampleData()
            .listen(handleData);
          _eSenseSubscription = FlutterMindWaveMobile2
            .onESenseData()
            .listen(handleData);
          _eegPowerLowBetaSubscription = FlutterMindWaveMobile2
            .onEEGPowerLowBetaData()
            .listen(handleData);
          _eegPowerDeltaSubscription = FlutterMindWaveMobile2
            .onEEGPowerDeltaData()
            .listen(handleData);
          _eegBlinkSubscription = FlutterMindWaveMobile2
            .onEEGBlinkData()
            .listen(handleData);
          _mwmBaudRateSubscription = FlutterMindWaveMobile2
            .onMWMBaudRateData()
            .listen(handleData);
        });
  }

  void handleData(data) {
    print(data.toString());
  }

  void _disconnect() {
    if (_eeSampleSubscription != null) _eeSampleSubscription.cancel();
    if (_eSenseSubscription != null) _eSenseSubscription.cancel();
    if (_eegPowerLowBetaSubscription != null) _eegPowerLowBetaSubscription.cancel();
    if (_eegPowerDeltaSubscription != null) _eegPowerDeltaSubscription.cancel();
    if (_eegBlinkSubscription != null) _eegBlinkSubscription.cancel();
    if (_mwmBaudRateSubscription != null) _mwmBaudRateSubscription.cancel();
    setState(() {
      _connectingStatus = 'disconnected';
    });
  }
}
