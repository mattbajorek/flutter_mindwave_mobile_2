import 'dart:async';
import 'dart:convert' as JSON;

import 'package:flutter/services.dart';

const NAMESPACE = 'flutter_mindwave_mobile_2';

class FlutterMindWaveMobile2 {
  final StreamController<MWMConnectionState> _mwmConnectionStreamController = StreamController<MWMConnectionState>();
  
  final MethodChannel _connectionChannel = MethodChannel('$NAMESPACE/connection');
  final EventChannel _attentionChannel = EventChannel('$NAMESPACE/attention');
  final EventChannel _bandPowerChannel = EventChannel('$NAMESPACE/bandPower');
  final EventChannel _eyeBlinkChannel = EventChannel('$NAMESPACE/eyeBlink');
  final EventChannel _meditationChannel = EventChannel('$NAMESPACE/meditation');
  final EventChannel _signalQualityChannel = EventChannel('$NAMESPACE/signalQuality');

  FlutterMindWaveMobile2() {
    _connectionChannel.setMethodCallHandler(handleConnection);
  }

  Stream<MWMConnectionState> connect(String deviceID) {
    _mwmConnectionStreamController.add(MWMConnectionState.connecting);
    _connectionChannel.invokeMethod('connect', deviceID);
    return _mwmConnectionStreamController.stream;
  }

  // Wait for disconnecting reply from native in handleConnection
  void disconnect() {
    _connectionChannel.invokeMethod('disconnect');
  }

  Future<dynamic> handleConnection(MethodCall call) async {
    if (call.method == 'connected') {
      _mwmConnectionStreamController.add(MWMConnectionState.connected);
    } else if (call.method == 'disconnected') {
      _mwmConnectionStreamController.add(MWMConnectionState.disconnected);
    }
  }

  // Receives attention data
  Stream<int> onAttention() {
    return _attentionChannel.receiveBroadcastStream()
      .map((data) => data as int);
  }

  // Receives band power data
  Stream<BandPower> onBandPower() {
    return _bandPowerChannel.receiveBroadcastStream()
      .map((data) {
        final json = JSON.jsonDecode(data);
        final alpha = double.parse(json['alpha']);
        final delta = double.parse(json['delta']);
        final theta = double.parse(json['theta']);
        final beta = double.parse(json['beta']);
        final gamma = double.parse(json['gamma']);
        return new BandPower(alpha, delta, theta, beta, gamma);
      });
  }

  // Receives eye blink data
  Stream<int> onEyeBlink() {
    return _eyeBlinkChannel.receiveBroadcastStream()
      .map((data) => data as int);
  }

  // Receives meditation data
  Stream<int> onMeditation() {
    return _meditationChannel.receiveBroadcastStream()
      .map((data) => data as int);
  }

  // Receives signal quality data
  Stream<int> onSignalQuality() {
    return _signalQualityChannel.receiveBroadcastStream()
      .map((data) => data as int);
  }
}

enum MWMConnectionState {
  disconnected,
  scanning, // not used in package, but used in example
  connecting,
  connected
}

class BandPower {
  final double delta;
  final double theta;
  final double alpha;
  final double beta;
  final double gamma;

  BandPower(this.delta, this.theta, this.alpha, this.beta, this.gamma);

  @override
  String toString() => "delta: $delta, theta: $theta, alpha: $alpha, beta: $beta, gamma: $gamma";
}