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
  StreamSubscription<ScanResult> _scanSubscription;
  StreamSubscription<MWMConnectionState> _connectionSubscription;

  @override
  Widget build(BuildContext context) {
    String connectionStatusText;
    String connectionImageUrl;
    Function handleButton = _scan;
    switch (_connectingState) {
      case MWMConnectionState.scanning:
        {
          connectionStatusText = 'Scanning...';
          connectionImageUrl = 'images/connecting1_v1.png';
          handleButton = null;
        }
        break;
      case MWMConnectionState.connecting:
        {
          connectionStatusText = 'Connecting...';
          connectionImageUrl = 'images/connecting2_v1.png';
          handleButton = null;
        }
        break;
      case MWMConnectionState.connected:
        {
          connectionStatusText = 'Disconnect';
          connectionImageUrl = 'images/connected_v1.png';
          handleButton = _disconnectWithMessage;
        }
        break;
      case MWMConnectionState.disconnected:
        {
          connectionStatusText = 'Connect';
          connectionImageUrl = 'images/nosignal_v1.png';
          handleButton = _scan;
        }
        break;
    }
    var columnChildren = <Widget>[
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
    ];
    if (_connectingState == MWMConnectionState.connected) {
      columnChildren.add(_dataView());
    }
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter MindWave Mobile 2 Plugin Example App'),
        ),
        body: Center(
            child: Column(
          children: columnChildren,
        )),
      ),
    );
  }

  void _scan() {
    // Start scanning
    setState(() {
      _connectingState = MWMConnectionState.scanning;
    });
    var found = false;
    _scanSubscription = flutterBlue.scan().listen((ScanResult scanResult) {
      var name = scanResult.device.name;
      if (name == 'MindWave Mobile') {
        found = true;
        _scanSubscription.cancel();
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
    _connectionSubscription = flutterMindWaveMobile2
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

  void _disconnect() {
    _connectionSubscription.cancel();
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

  Widget _dataView() {
    return Expanded(
      child: Column(
        children: <Widget>[
          _header("Algo State and Reason"),
          _algoStateAndReasonStreamBuilder(),
          Spacer(),
          _header("Attention (Att)"),
          _dataStreamBuilder("Attention", flutterMindWaveMobile2.onAttention()),
          Spacer(),
          _header("Band Power (BP)"),
          _bandPowerStreamBuilder(),
          Spacer(),
          _header("Eye Blink (Blink)"),
          _dataStreamBuilder("Eye Blink", flutterMindWaveMobile2.onEyeBlink()),
          Spacer(),
          _header("Meditation (Med)"),
          _dataStreamBuilder(
              "Meditation", flutterMindWaveMobile2.onMeditation()),
          Spacer(),
        ],
      ),
    );
  }

  Widget _algoStateAndReasonStreamBuilder() {
    return StreamBuilder(
      stream: flutterMindWaveMobile2.onAlgoStateAndReason(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var algoStateAndReason = snapshot.data as AlgoStateAndReason;
          return Column(
            children: <Widget>[
              _value(
                  "state: ${algoStateAndReason.state.toString().split('.').last}"),
              _value(
                  "reason: ${algoStateAndReason.reason.toString().split('.').last}"),
            ],
          );
        }
        return Column(
          children: <Widget>[
            _value("state: N/A"),
            _value("reason: N/A"),
          ],
        );
      },
    );
  }

  Widget _dataStreamBuilder(String title, Stream stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _value("$title: ${snapshot.data.toString()}");
        }
        return _value("$title: N/A");
      },
    );
  }

  Widget _bandPowerStreamBuilder() {
    return StreamBuilder(
      stream: flutterMindWaveMobile2.onBandPower(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var bandPower = snapshot.data as BandPower;
          return Column(
            children: <Widget>[
              _value("delta: ${bandPower.delta.toString()} dB"),
              _value("theta: ${bandPower.theta.toString()} dB"),
              _value("alpha: ${bandPower.alpha.toString()} dB"),
              _value("beta: ${bandPower.beta.toString()} dB"),
              _value("gamma: ${bandPower.gamma.toString()} dB"),
            ],
          );
        }
        return Column(
          children: <Widget>[
            _value("delta: N/A"),
            _value("theta: N/A"),
            _value("alpha: N/A"),
            _value("beta: N/A"),
            _value("gamma: N/A"),
          ],
        );
      },
    );
  }

  Widget _header(String text) {
    return Text(text,
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold));
  }

  Widget _value(String text) {
    return Text(text, style: TextStyle(fontSize: 16.0));
  }
}
