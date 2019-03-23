import 'dart:async';
import 'dart:convert' as JSON;

import 'package:flutter/services.dart';

const NAMESPACE = 'flutter_mindwave_mobile_2';

class FlutterMindWaveMobile2 {
  final StreamController<MWMConnectionState> _mwmConnectionStreamController =
      StreamController<MWMConnectionState>();

  final MethodChannel _connectionChannel =
      MethodChannel('$NAMESPACE/connection');
  final EventChannel _algoStateAndReasonChannel =
      EventChannel('$NAMESPACE/algoStateAndReason');
  final EventChannel _attentionChannel = EventChannel('$NAMESPACE/attention');
  final EventChannel _bandPowerChannel = EventChannel('$NAMESPACE/bandPower');
  final EventChannel _eyeBlinkChannel = EventChannel('$NAMESPACE/eyeBlink');
  final EventChannel _meditationChannel = EventChannel('$NAMESPACE/meditation');
  final EventChannel _signalQualityChannel =
      EventChannel('$NAMESPACE/signalQuality');

  FlutterMindWaveMobile2() {
    _connectionChannel.setMethodCallHandler(handleConnection);
  }

  Stream<MWMConnectionState> connect(String deviceId, [String licenseKey]) {
    _mwmConnectionStreamController.add(MWMConnectionState.connecting);
    _connectionChannel.invokeMethod(
        'connect', {'deviceId': deviceId, 'licenseKey': licenseKey});
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

  // Receives algo state and reason data
  Stream<AlgoStateAndReason> onAlgoStateAndReason() {
    return _algoStateAndReasonChannel.receiveBroadcastStream().map((data) {
      final json = JSON.jsonDecode(data);
      final state = json['state'] as String;
      final reason = json['reason'] as String;
      return new AlgoStateAndReason(state, reason);
    });
  }

  // Receives attention data
  Stream<int> onAttention() {
    return _attentionChannel
        .receiveBroadcastStream()
        .map((data) => data as int);
  }

  // Receives band power data
  Stream<BandPower> onBandPower() {
    return _bandPowerChannel.receiveBroadcastStream().map((data) {
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
    return _eyeBlinkChannel.receiveBroadcastStream().map((data) => data as int);
  }

  // Receives meditation data
  Stream<int> onMeditation() {
    return _meditationChannel
        .receiveBroadcastStream()
        .map((data) => data as int);
  }

  // Receives signal quality data
  Stream<int> onSignalQuality() {
    return _signalQualityChannel
        .receiveBroadcastStream()
        .map((data) => data as int);
  }
}

enum MWMConnectionState {
  disconnected,
  scanning, // not used in package, but used in example
  connecting,
  connected
}

enum AlgoState {
  inited,
  analysingBulkData,
  collectingBaseline,
  pause,
  running,
  stop,
  uninited
}

enum AlgoReason {
  baselineExpired,
  byUser,
  cbChanged,
  configChanged,
  noBaseline,
  signalQuality,
  userProfileChanged,
  unknown
}

class AlgoStateAndReason {
  final AlgoState state;
  final AlgoReason reason;

  AlgoStateAndReason._(this.state, this.reason);

  factory AlgoStateAndReason(String stateStr, String reasonStr) {
    AlgoState state;
    switch (stateStr) {
      case "Inited":
        state = AlgoState.inited;
        break;
      case "Analysing Bulk Data":
        state = AlgoState.analysingBulkData;
        break;
      case "Collecting Baseline":
        state = AlgoState.collectingBaseline;
        break;
      case "Pause":
        state = AlgoState.pause;
        break;
      case "Running":
        state = AlgoState.running;
        break;
      case "Stop":
        state = AlgoState.stop;
        break;
      case "Uninited":
        state = AlgoState.uninited;
        break;
    }
    AlgoReason reason;
    switch (reasonStr) {
      case "Baseline Expired":
        reason = AlgoReason.baselineExpired;
        break;
      case "By User":
        reason = AlgoReason.byUser;
        break;
      case "CB Changed":
        reason = AlgoReason.cbChanged;
        break;
      case "Config Changed":
        reason = AlgoReason.configChanged;
        break;
      case "No Baseline":
        reason = AlgoReason.noBaseline;
        break;
      case "Signal Quality":
        reason = AlgoReason.signalQuality;
        break;
      case "User Profile Changed":
        reason = AlgoReason.userProfileChanged;
        break;
      default:
        reason = AlgoReason.unknown;
        break;
    }
    return new AlgoStateAndReason._(state, reason);
  }

  @override
  String toString() => "state: $state, reason: $reason";
}

class BandPower {
  final double delta;
  final double theta;
  final double alpha;
  final double beta;
  final double gamma;

  BandPower(this.delta, this.theta, this.alpha, this.beta, this.gamma);

  @override
  String toString() =>
      "delta: $delta, theta: $theta, alpha: $alpha, beta: $beta, gamma: $gamma";
}
