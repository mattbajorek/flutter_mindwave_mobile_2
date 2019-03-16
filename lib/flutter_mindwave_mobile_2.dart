import 'dart:async';

import 'package:flutter/services.dart';

const NAMESPACE = 'flutter_mindwave_mobile_2';

class FlutterMindWaveMobile2 {
  static const MethodChannel _methodChannel = const MethodChannel('$NAMESPACE/methods');
  static const EventChannel _eegSampleChannel = const EventChannel('$NAMESPACE/eegSample');
  static const EventChannel _eSenseChannel = const EventChannel('$NAMESPACE/eSense');
  static const EventChannel _eegPowerLowBetaChannel = const EventChannel('$NAMESPACE/eegPowerLowBeta');
  static const EventChannel _eegPowerDeltaChannel = const EventChannel('$NAMESPACE/eegPowerDelta');
  static const EventChannel _eegBlinkChannel = const EventChannel('$NAMESPACE/eegBlink');
  static const EventChannel _mwmBaudRateChannel = const EventChannel('$NAMESPACE/mwmBaudRate');

  static Future<void> connect(String deviceID) async {
    await _methodChannel.invokeMethod('connect', deviceID);
  }

  // Receives eegSample data
  static Stream<EEGSampleData> onEEGSampleData() {
    return _eegSampleChannel.receiveBroadcastStream()
      .map((data) => new EEGSampleData(data['sample']));
  }

  // Receives eSense data
  static Stream<ESenseData> onESenseData() {
    return _eSenseChannel.receiveBroadcastStream()
      .map((data) => new ESenseData(data['poorSignal'], data['attention'], data['meditation']));
  }
  
  // Receives eegPowerLowBeta data
  static Stream<EEGPowerLowBetaData> onEEGPowerLowBetaData() {
    return _eegPowerLowBetaChannel
      .receiveBroadcastStream()
      .map((data) => new EEGPowerLowBetaData(data['lowBeta'], data['highBeta'], data['lowGamma'], data['midGamma']));
  }

  // Receives eegPowerDelta data
  static Stream<EEGPowerDeltaData> onEEGPowerDeltaData() {
    return _eegPowerDeltaChannel
      .receiveBroadcastStream()
      .map((data) => new EEGPowerDeltaData(data['delta'], data['theta'], data['lowAlpha'], data['highAlpha']));
  }

  // Receives eegBlink data
  static Stream<EEGBlinkData> onEEGBlinkData() {
    return _eegBlinkChannel
      .receiveBroadcastStream()
      .map((data) => new EEGBlinkData(data['blinkValue']));
  }

  // Receives mwmBaudRate data
  static Stream<MWMBaudRateData> onMWMBaudRateData() {
    return _mwmBaudRateChannel
      .receiveBroadcastStream()
      .map((data) => new MWMBaudRateData(data['baudRate'], data['notchFilter']));
  }
}

class EEGSampleData {
  final int sample;

  EEGSampleData(this.sample);

  @override
  String toString() => "sample: $sample";
}

class ESenseData {
  final int poorSignal;
  final int attention;
  final int meditation;

  ESenseData(this.poorSignal, this.attention, this.meditation);

  @override
  String toString() => "poorSignal: $poorSignal, attention: $attention, meditation: $meditation";
}

class EEGPowerLowBetaData {
  final int lowBeta;
  final int highBeta;
  final int lowGamma;
  final int midGamma;

  EEGPowerLowBetaData(this.lowBeta, this.highBeta, this.lowGamma, this.midGamma);

  @override
  String toString() => "lowBeta: $lowBeta, highBeta: $highBeta, lowGamma: $lowGamma, midGamma: $midGamma";
}

class EEGPowerDeltaData {
  final int delta;
  final int theta;
  final int lowAlpha;
  final int highAlpha;

  EEGPowerDeltaData(this.delta, this.theta, this.lowAlpha, this.highAlpha);

  @override
  String toString() => "delta: $delta, theta: $theta, lowAlpha: $lowAlpha, highAlpha: $highAlpha";
}

class EEGBlinkData {
  final int blinkValue;

  EEGBlinkData(this.blinkValue);

  @override
  String toString() => "blinkValue: $blinkValue";
}

class MWMBaudRateData {
  final int baudRate;
  final int notchFilter;

  MWMBaudRateData(this.baudRate, this.notchFilter);

  @override
  String toString() => "baudRate: $baudRate, notchFilter: $notchFilter";
}