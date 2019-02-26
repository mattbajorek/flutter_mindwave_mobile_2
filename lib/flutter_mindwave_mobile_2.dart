import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMindwaveMobile_2 {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mindwave_mobile_2');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
