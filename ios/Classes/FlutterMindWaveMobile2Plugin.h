#import <Flutter/Flutter.h>
#import "MWMDevice.h"
#import "MWMDelegate.h"

#define NAMESPACE @"flutter_mindwave_mobile_2"

@interface FlutterMindWaveMobile2Plugin : NSObject<FlutterPlugin>
@end

@interface MWMDelegateHandler : NSObject<MWMDelegate>
@end

@interface FlutterMindWaveMobile2StreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end
