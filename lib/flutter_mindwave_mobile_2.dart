import 'dart:async';

import 'package:flutter/services.dart';

const NAMESPACE = 'flutter_mindwave_mobile_2';

class FlutterMindWaveMobile2 {
  static const MethodChannel _methodChannel = const MethodChannel('$NAMESPACE/methods');
  static const EventChannel _eSenseChannel = const EventChannel('$NAMESPACE/eSense');

  static Future<void> connect(String deviceID) async {
    await _methodChannel.invokeMethod('connect', deviceID);
  }

  /// Receives eSense data
  static Stream onESenseData() {
    return _eSenseChannel
        .receiveBroadcastStream();
        // .map((buffer) => new protos.BluetoothState.fromBuffer(buffer))
        // .map((s) => BluetoothState.values[s.state.value]);
  }
}

