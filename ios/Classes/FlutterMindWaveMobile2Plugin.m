#import "FlutterMindWaveMobile2Plugin.h"
#import "MWMDevice.h"

@interface FlutterMindWaveMobile2Plugin ()
@property(nonatomic, retain) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, retain) FlutterMethodChannel *methodsChannel;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler *eSenseStreamHandler;
@property(nonatomic, retain) MWMDelegateHandler *mwmDelegateHandler;
@property(nonatomic, retain) MWMDevice *mwmDevice;
@end

@implementation FlutterMindWaveMobile2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
  FlutterMethodChannel* methodsChannel = [FlutterMethodChannel
                                   methodChannelWithName:NAMESPACE @"/methods"
                                   binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2Plugin* instance = [[FlutterMindWaveMobile2Plugin alloc] init];
    
  instance.methodsChannel = methodsChannel;
    
  // Set up eSense
  FlutterEventChannel* eSenseChannel = [FlutterEventChannel
                                        eventChannelWithName:NAMESPACE @"/eSense"
                                        binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eSenseStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  [eSenseChannel setStreamHandler:eSenseStreamHandler];
  instance.eSenseStreamHandler = eSenseStreamHandler;
    
  // Set up MWMdevice
  MWMDevice* mwmDevice = [MWMDevice sharedInstance];
  MWMDelegateHandler* mwmDelegateHandler = [[MWMDelegateHandler alloc] init];
  // mwmDelegateHandler.eSenseStreamHandler = eSenseStreamHandler;
  [mwmDevice setDelegate:mwmDelegateHandler];
  instance.mwmDelegateHandler = mwmDelegateHandler;
  instance.mwmDevice = mwmDevice;
    
  [registrar addMethodCallDelegate:instance channel:methodsChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"connect" isEqualToString:call.method]) {
    NSLog(@"MWM connecting to device");
    NSString *deviceID = [call arguments];
    [_mwmDevice connectDevice:deviceID];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end

@interface MWMDelegateHandler ()
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler *eSenseStreamHandler;
@end

@implementation MWMDelegateHandler

- (void)deviceFound:(NSString *)devName MfgID:(NSString *)mfgID DeviceID:(NSString *)deviceID {
    // Bluetooth scanning done with another package
    NSLog(@"MWM device found");
    return;
}

- (void)didConnect {
    NSLog(@"MWM did connect");
}

- (void)didDisconnect {
    NSLog(@"MWM did disconnect");
}

-(void)eSense:(int)poorSignal Attention:(int)attention Meditation:(int)meditation {
    NSLog(@"MWM sending eSense");
}

@end

@implementation FlutterMindWaveMobile2StreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.sink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.sink = nil;
    return nil;
}

@end
