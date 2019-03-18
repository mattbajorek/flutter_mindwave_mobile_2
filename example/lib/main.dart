import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mindwave_mobile_2/flutter_mindwave_mobile_2.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterMindWaveMobile2 flutterMindWaveMobile2 = FlutterMindWaveMobile2();
  
  MWMConnectionState _connectingState = MWMConnectionState.disconnected;
  StreamSubscription _scanSubscription;
  StreamSubscription<int> _attentionSubscription;
  StreamSubscription<BandPower> _bandPowerSubscription;
  StreamSubscription<int> _eyeBlinkSubscription;
  StreamSubscription<int> _meditationSubscription;
  StreamSubscription<int> _signalQualitySubscription;
  
  _MyAppState() {
    // _attentionSubscription = flutterMindWaveMobile2
    //   .onAttention()
    //   .listen(handleData);
    _bandPowerSubscription = flutterMindWaveMobile2
      .onBandPower()
      .listen(handleData);
    // _eyeBlinkSubscription = flutterMindWaveMobile2
    //   .onEyeBlink()
    //   .listen(handleData);
    // _meditationSubscription = flutterMindWaveMobile2
    //   .onMeditation()
    //   .listen(handleData);
    // _signalQualitySubscription = flutterMindWaveMobile2
    //   .onSignalQuality()
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
        handleButton = _disconnectWithMessage;
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
      navigatorKey: navigatorKey,
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
    var found = false;
    _scanSubscription = flutterBlue
      .scan()
      .listen((ScanResult scanResult) {
        var name = scanResult.device.name;
        if (name == 'MindWave Mobile') {
          found = true;
          _scanSubscription.cancel();
          print("FOUND MINDWAVE MOBILE!!!");
          _connect(scanResult.device);
        }
      }, onError: (error) {
        _disconnect();
        _showDialog("Is bluetooth on?");
      }, cancelOnError: true);
    // Cancel scan after 5 sec
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (!found) {
        _scanSubscription.cancel();
        _disconnect();
        _showDialog("Unable to find MindWave Mobile");
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
    print("RECEIVED DATA!!!!!!!!: " + data.toString());
  }

  void _disconnect() {
    if (_attentionSubscription != null) _attentionSubscription.cancel();
    if (_bandPowerSubscription != null) _bandPowerSubscription.cancel();
    if (_eyeBlinkSubscription != null) _eyeBlinkSubscription.cancel();
    if (_meditationSubscription != null) _meditationSubscription.cancel();
    if (_signalQualitySubscription != null) _signalQualitySubscription.cancel();
    setState(() {
      _connectingState = MWMConnectionState.disconnected;
    });
  }
  void _disconnectWithMessage() {
    _disconnect();
    flutterMindWaveMobile2.disconnect();
  }

  void _showDialog(String message) {
    final context = navigatorKey.currentState.overlay.context;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
