#import <Flutter/Flutter.h>
#import "MWMDevice.h"
#import "MWMDelegate.h"

#define NAMESPACE @"flutter_mindwave_mobile_2"

@interface FlutterMindWaveMobile2Plugin : NSObject<FlutterPlugin>
@end

@interface FlutterMindWaveMobile2StreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end

@interface MWMDelegateHandler : NSObject<MWMDelegate>
-(id)initWithChannels:(FlutterMindWaveMobile2StreamHandler*) eegSampleChannelStreamHandler
                      eSenseChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eSenseChannelStreamHandler
                      eegPowerLowBetaChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eegPowerLowBetaChannelStreamHandler
                      eegPowerDeltaChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eegPowerDeltaChannelStreamHandler
                      eegBlinkChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eegBlinkChannelStreamHandler
                      mwmBaudRateChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) mwmBaudRateChannelStreamHandler
                      exceptionMessageChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) exceptionMessageChannelStreamHandler;
@end
