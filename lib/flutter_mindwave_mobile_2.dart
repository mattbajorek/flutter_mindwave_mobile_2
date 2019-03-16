import 'dart:async';

import 'package:flutter/services.dart';

const NAMESPACE = 'flutter_mindwave_mobile_2';

class FlutterMindWaveMobile2 {
  final StreamController<MWMConnectionState> _mwmConnectionStreamController = StreamController<MWMConnectionState>();
  
  final MethodChannel _connectionChannel = MethodChannel('$NAMESPACE/connection');
  final EventChannel _eegSampleChannel = EventChannel('$NAMESPACE/eegSample');
  final EventChannel _eSenseChannel = EventChannel('$NAMESPACE/eSense');
  final EventChannel _eegPowerLowBetaChannel = EventChannel('$NAMESPACE/eegPowerLowBeta');
  final EventChannel _eegPowerDeltaChannel = EventChannel('$NAMESPACE/eegPowerDelta');
  final EventChannel _eegBlinkChannel = EventChannel('$NAMESPACE/eegBlink');
  final EventChannel _mwmBaudRateChannel = EventChannel('$NAMESPACE/mwmBaudRate');
  final EventChannel _exceptionMessageChannel = EventChannel('$NAMESPACE/exceptionMessage');

  FlutterMindWaveMobile2() {
    _connectionChannel.setMethodCallHandler(handleConnection);
  }

  Stream<MWMConnectionState> connect(String deviceID) {
    _mwmConnectionStreamController.add(MWMConnectionState.connecting);
    _connectionChannel.invokeMethod('connect', deviceID);
    return _mwmConnectionStreamController.stream;
  }

  Future<dynamic> handleConnection(MethodCall call) async {
    if (call.method == 'connected') {
      _mwmConnectionStreamController.add(MWMConnectionState.connected);
    } else if (call.method == 'disconnected') {
      _mwmConnectionStreamController.add(MWMConnectionState.disconnected);
    }
  }

  // Receives eegSample data
  Stream<EEGSampleData> onEEGSampleData() {
    return _eegSampleChannel.receiveBroadcastStream()
      .map((data) => new EEGSampleData(data['sample']));
  }

  // Receives eSense data
  Stream<ESenseData> onESenseData() {
    return _eSenseChannel.receiveBroadcastStream()
      .map((data) => new ESenseData(data['poorSignal'], data['attention'], data['meditation']));
  }
  
  // Receives eegPowerLowBeta data
  Stream<EEGPowerLowBetaData> onEEGPowerLowBetaData() {
    return _eegPowerLowBetaChannel
      .receiveBroadcastStream()
      .map((data) => new EEGPowerLowBetaData(data['lowBeta'], data['highBeta'], data['lowGamma'], data['midGamma']));
  }

  // Receives eegPowerDelta data
  Stream<EEGPowerDeltaData> onEEGPowerDeltaData() {
    return _eegPowerDeltaChannel
      .receiveBroadcastStream()
      .map((data) => new EEGPowerDeltaData(data['delta'], data['theta'], data['lowAlpha'], data['highAlpha']));
  }

  // Receives eegBlink data
  Stream<EEGBlinkData> onEEGBlinkData() {
    return _eegBlinkChannel
      .receiveBroadcastStream()
      .map((data) => new EEGBlinkData(data['blinkValue']));
  }

  // Receives mwmBaudRate data
  Stream<MWMBaudRateData> onMWMBaudRateData() {
    return _mwmBaudRateChannel
      .receiveBroadcastStream()
      .map((data) => new MWMBaudRateData(data['baudRate'], data['notchFilter']));
  }

  // Receives exceptionMessage
  Stream<MWMExceptionMessage> onExceptionMessage() {
    return _exceptionMessageChannel
      .receiveBroadcastStream()
      .map((data) => MWMExceptionMessage.values[data['eventType']]);
  }
}

enum MWMConnectionState {
  disconnected,
  scanning, // not used in package, but used in example
  connecting,
  connected
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

enum MWMExceptionMessage {
  TGBleUnexpectedEvent,
  TGBleConfigurationModeCanNotBeChanged,
  TGBleFailedOtherOperationInProgress,
  TGBleConnectFailedSuspectKeyMismatch,
  TGBlePossibleResetDetect,
  TGBleNewConnectionEstablished,
  TGBleStoredConnectionInvalid,
  TGBleConnectHeadSetDirectoryFailed,
  TGBleBluetoothModuleError,
  TGBleNoMfgDatainAdvertisement
}