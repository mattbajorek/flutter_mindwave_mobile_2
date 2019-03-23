[![pub package](https://img.shields.io/pub/v/flutter_mindwave_mobile_2.svg)](https://pub.dartlang.org/packages/flutter_mindwave_mobile_2)

<p align="center">
<img alt="FlutterMindWaveMobile2" src="https://github.com/mattbajorek/flutter_mindwave_mobile_2/blob/master/site/flutter_mindwave_mobile_2.png?raw=true" />
</p>

## Introduction

FlutterMindWaveMobile2 is a plugin to connect and receive data from the [Neurosky MindWave Mobile 2](https://store.neurosky.com/pages/mindwave) using [Flutter](http://www.flutter.io), a new mobile SDK to help developers build modern apps for iOS and Android.

## Cross-Platform

FlutterMindWaveMobile2 aims to offer the most from both the [Android Developer Tools 4.2](https://store.neurosky.com/products/android-developer-tools-4) and [iOS Developer Tools 4.8](https://store.neurosky.com/products/ios-developer-tools-4) from Neurosky.  Data is fed from the COMM SDK into the EEG Algorithm SDK (see note below).

## Note: iOS License Key Requirement for EEG Algorithm SDK

Android by default uses the EEG Algorithm, but iOS requires a license key to use the EEG Algorithm SDK.  However, the COMMS SDK (used to feed the EEG Algorithm SDK) is still available and providing values on all channels except Band Power (BP) (see supported algorithms below).

Please [contact Neurosky](http://neurosky.com/contact-us/) for a client specific license key.

## Note: Will only work on actual devices

This plugin will **NOT** connect in Android Emulator and will **NOT** build on iOS simulator.

## Supported Algorithms

All algorithm data have a fixed output interval of 1 second.

|                  |      Android       |  iOS (with License)  | iOS (without License) |             Description            |
| :--------------- | :----------------: | :------------------: | :------------------: |  :-------------------------------- |
| [Attention (Att)](#Attention)  | :heavy_check_mark: |  :heavy_check_mark:  |  :heavy_check_mark:  | Attention index ranges from 0 to 100. The higher the index, the higher the attention level. |
| [Meditation (Med)](#Meditation) | :heavy_check_mark: |  :heavy_check_mark:  |  :heavy_check_mark:  | Meditation index ranges from 0 to 100. The higher the index, the higher the meditation level. |
| [Band Power (BP)](#Band-Power)  | :heavy_check_mark: |  :heavy_check_mark:  |                      | EEG bandpowers (in dB) index for: delta, theta, alpha, beta, and gamma. |
| [Eye Blink Detection (Blink)](#Eye-Blink-Detection)   | :heavy_check_mark: |  :heavy_check_mark:  |  :heavy_check_mark:  | Eye blink strength (no baseline data collection will be needed). |
| [Signal Quality](#Signal-Quality)   | :heavy_check_mark: |  :heavy_check_mark:  |  :heavy_check_mark:  | Signal quality value of the device ranges from 0 to 200.  The lower the value, the better the signal. |

## Usage

Add `flutter_mindwave_mobile_2` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/):

```yaml
dependencies:
  flutter_mindwave_mobile_2: '^0.1.0'
```

Then import the plugin into your dart file.

``` dart
import 'package:flutter_mindwave_mobile_2/flutter_mindwave_mobile_2.dart';
```

### Get Bluetooth device ID
This plugin requires the MindWave Mobile 2 Bluetooth device ID.  An easy way to accomplish this is with using [FlutterBlue](https://pub.dartlang.org/packages/flutter_blue).  For example:

``` dart
import 'package:flutter_blue/flutter_blue.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;

var scanSubscription = flutterBlue
    .scan()
    .listen((ScanResult scanResult) {
        var device = scanResult.device;
        var name = device.name;
        if (name == 'MindWave Mobile') {
            var deviceId = device.id.toString();
        }
    });
```

### Create a new FlutterMindWaveMobile2 instance

``` dart
FlutterMindWaveMobile2 flutterMindWaveMobile2 = FlutterMindWaveMobile2();
```

### Connect

Returns [MWMConnectionState](#MWMConnectionState)

``` dart
var connectionSubscription = flutterMindWaveMobile2
    .connect(deviceId, licenseKey) // licenseKey is optional for iOS EEG Algorithm
    .listen((MWMConnectionState connectionState) {
        // Handle state
    });
```

### Disconnect

``` dart
connectionSubscription.cancel();
flutterMindWaveMobile2.disconnect();
```

## Data streams

### Algorithm State and Reason

Returns [AlgoStateAndReason](#AlgoStateAndReason)

``` dart
var algoStateAndReasonSubscription = flutterMindWaveMobile2
    .onAlgoStateAndReason()
    .listen((AlgoStateAndReason algoStateAndReason) {
        // Handle algo state and reason
    });
```

### Attention

Returns int

``` dart
var attentionSubscription = flutterMindWaveMobile2
    .onAttention()
    .listen((int attention) {
        // Handle attention
    });
```

### Meditation

Returns int

``` dart
var meditationSubscription = flutterMindWaveMobile2
    .onMeditation()
    .listen((int meditation) {
        // Handle meditation
    });
```

### Band Power

Returns [BandPower](#BandPower)

``` dart
var bandPowerSubscription = flutterMindWaveMobile2
    .onBandPower()
    .listen((BandPower bandPower) {
        // Handle band power
    });
```

### Eye Blink Detection

Returns int

``` dart
var eyeBlinkDetectionSubscription = flutterMindWaveMobile2
    .onEyeBlink()
    .listen((int eyeBlinkStrength) {
        // Handle eye blink strength
    });
```

### Signal Quality

Returns int

``` dart
var signalQualitySubscription = flutterMindWaveMobile2
    .onSignalQuality()
    .listen((int signalQuality) {
        // Handle signal quality
    });
```

## Classes

### AlgoStateAndReason
| Property | Type                      |
| -------- | ------------------------- |
| state    | [AlgoState](#AlgoState)   |
| reason   | [AlgoReason](#AlgoReason) |

### BandPower
| Property | Type   |
| -------- | ------ |
| delta    | double |
| theta    | double |
| alpha    | double |
| beta     | double |
| gamma    | double |

## Enums

### MWMConnectionState
| Values                                                               |
| -------------------------------------------------------------------- |
| disconnected                                                         |
| scanning (not used in package, but used in example with FlutterBlue) |
| connecting                                                           |
| connected                                                            |

### AlgoState
| Values             |
| ------------------ |
| inited             |
| analysingBulkData  |
| collectingBaseline |
| pause              |
| running            |
| stop               |
| uninited           |

### AlgoReason
| Values                                                |
| ----------------------------------------------------- |
| baselineExpired                                       |
| byUser                                                |
| cbChanged (*Android only collecting baseline changed*)|
| configChanged                                         |
| noBaseline                                            |
| signalQuality                                         |
| userProfileChanged                                    |
| unknown                                               |

## Inspiration
This plugin is inspired by [react-native-mindwave-mobile](https://www.npmjs.com/package/react-native-mindwave-mobile), but adds on the EGG Algorithm SDK.

## Affiliation
This plugin is not affiliated or sponsored by [Neurosky](http://neurosky.com/) in any way.