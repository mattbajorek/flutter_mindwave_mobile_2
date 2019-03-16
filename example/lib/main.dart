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
  FlutterMindWaveMobile2 flutterMindWaveMobile2 = FlutterMindWaveMobile2();
  
  MWMConnectionState _connectingState = MWMConnectionState.disconnected;
  StreamSubscription _scanSubscription;
  StreamSubscription<EEGSampleData> _eegSampleSubscription;
  StreamSubscription<ESenseData> _eSenseSubscription;
  StreamSubscription<EEGPowerLowBetaData> _eegPowerLowBetaSubscription;
  StreamSubscription<EEGPowerDeltaData> _eegPowerDeltaSubscription;
  StreamSubscription<EEGBlinkData> _eegBlinkSubscription;
  StreamSubscription<MWMBaudRateData> _mwmBaudRateSubscription;
  StreamSubscription<MWMExceptionMessage> _exceptionMessageSubscription;
  
  _MyAppState() {
    // _eegSampleSubscription = flutterMindWaveMobile2
    //   .onEEGSampleData()
    //   .listen(handleData);
    _eSenseSubscription = flutterMindWaveMobile2
      .onESenseData()
      .listen(handleData);
    // _eegPowerLowBetaSubscription = flutterMindWaveMobile2
    //   .onEEGPowerLowBetaData()
    //   .listen(handleData);
    // _eegPowerDeltaSubscription = flutterMindWaveMobile2
    //   .onEEGPowerDeltaData()
    //   .listen(handleData);
    // _eegBlinkSubscription = flutterMindWaveMobile2
    //   .onEEGBlinkData()
    //   .listen(handleData);
    // _mwmBaudRateSubscription = flutterMindWaveMobile2
    //   .onMWMBaudRateData()
    //   .listen(handleData);
    // _exceptionMessageSubscription = flutterMindWaveMobile2
    //   .onExceptionMessage()
    //   .listen(handleData);
  }

  @override
  Widget build(BuildContext context) {
    String connectionStatusText;
    String connectionImageUrl;
    Function handleButton = _scan;
    switch(_connectingState) {
      case MWMConnectionState.scanning: {
        connectionStatusText = 'Scanning...';
        connectionImageUrl = 'images/connecting1_v1.png';
        handleButton = null;
      }
      break;
      case MWMConnectionState.connecting: {
        connectionStatusText = 'Connecting...';
        connectionImageUrl = 'images/connecting2_v1.png';
        handleButton = null;
      }
      break;
      case MWMConnectionState.connected: {
        connectionStatusText = 'Disconnect';
        connectionImageUrl = 'images/connected_v1.png';
        handleButton = _disconnect;
      }
      break;
      case MWMConnectionState.disconnected: {
        connectionStatusText = 'Connect';
        connectionImageUrl = 'images/nosignal_v1.png';
        handleButton = _scan;
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
      _connectingState = MWMConnectionState.scanning;
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
      _connectingState = MWMConnectionState.connecting;
    });
    flutterMindWaveMobile2
      .connect(device.id.toString())
      .listen((MWMConnectionState connectionState) {
        if (connectionState == MWMConnectionState.connected) {
          setState(() {
            _connectingState = connectionState;
          });
        } else if (connectionState == MWMConnectionState.disconnected) {
          _disconnect();
        }
      });
  }

  void handleData(data) {
    print(data.toString());
  }

  void _disconnect() {
    if (_eegSampleSubscription != null) _eegSampleSubscription.cancel();
    if (_eSenseSubscription != null) _eSenseSubscription.cancel();
    if (_eegPowerLowBetaSubscription != null) _eegPowerLowBetaSubscription.cancel();
    if (_eegPowerDeltaSubscription != null) _eegPowerDeltaSubscription.cancel();
    if (_eegBlinkSubscription != null) _eegBlinkSubscription.cancel();
    if (_mwmBaudRateSubscription != null) _mwmBaudRateSubscription.cancel();
    if (_exceptionMessageSubscription != null) _exceptionMessageSubscription.cancel();
    setState(() {
      _connectingState = MWMConnectionState.disconnected;
    });
  }
}
