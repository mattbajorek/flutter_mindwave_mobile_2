import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMindWaveMobile2 {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mindwave_mobile_2');

  static Future<void> connect(String deviceID) async {
    await _channel.invokeMethod('connect', deviceID);
  }
}
