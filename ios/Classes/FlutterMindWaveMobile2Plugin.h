#import <Flutter/Flutter.h>
#import <AlgoSdk/NskAlgoSdk.h>
#import "MWMDevice.h"
#import "MWMDelegate.h"

#define NAMESPACE @"flutter_mindwave_mobile_2"

@interface FlutterMindWaveMobile2Plugin : NSObject<FlutterPlugin>
@end

@interface FlutterMindWaveMobile2StreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end

@interface NskAlgoSdkDelegateHandler : NSObject<NskAlgoSdkDelegate>
-(id)initWithVariables: (FlutterMethodChannel*) connectionChannel
                        algoStateAndReasonChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) algoStateAndReasonChannelStreamHandler
                        attentionChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) attentionChannelStreamHandler
                        bandPowerChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) bandPowerChannelStreamHandler
                        eyeBlinkChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eyeBlinkChannelStreamHandler
                        meditationChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) meditationChannelStreamHandler
                        signalQualityChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) signalQualityChannelStreamHandler;
@end

@interface MWMDelegateHandler : NSObject<MWMDelegate>
-(id)initWithVariables: (FlutterMethodChannel*) connectionChannel
                        bleFlag: (BOOL) bleFlag
                        hasLicenseKey: (BOOL) hasLicenseKey
                        nskAlgoSdk: (NskAlgoSdk*) nskAlgoSdk
                        attentionChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) attentionChannelStreamHandler
                        eyeBlinkChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eyeBlinkChannelStreamHandler
                        meditationChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) meditationChannelStreamHandler
                        signalQualityChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) signalQualityChannelStreamHandler;
@end
