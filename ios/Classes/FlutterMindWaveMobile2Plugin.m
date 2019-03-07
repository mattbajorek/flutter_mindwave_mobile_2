#import "FlutterMindWaveMobile2Plugin.h"
#import "MWMDevice.h"

@interface FlutterMindWaveMobile2Plugin ()
@property(nonatomic, retain) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic) MWMDevice *mwmDevice;
@end

@implementation FlutterMindWaveMobile2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_mindwave_mobile_2"
            binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2Plugin* instance = [[FlutterMindWaveMobile2Plugin alloc] init];
    
  instance.channel = channel;
    
  // Set up MWMdevice
  instance.mwmDevice = [MWMDevice sharedInstance];
  [instance.mwmDevice setDelegate:self];
  [instance.mwmDevice enableConsoleLog:YES];
    
  [registrar addMethodCallDelegate:instance channel:channel];
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

- (void)deviceFound:(NSString *)devName MfgID:(NSString *)mfgID DeviceID:(NSString *)deviceID {
    // Bluetooth scanning done with another package
    NSLog(@"MWM device found");
    return;
}

- (void)didConnect {
    NSLog(@"MWM did connect");
    return;
}

- (void)didDisconnect {
    NSLog(@"MWM did disconnect");
    return;
}

@end
