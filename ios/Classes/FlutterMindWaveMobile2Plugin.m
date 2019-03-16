#import "FlutterMindWaveMobile2Plugin.h"
#import "MWMDevice.h"

@interface FlutterMindWaveMobile2Plugin ()
@property(nonatomic, retain) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, retain) FlutterMethodChannel *connectionChannel;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* eegSampleChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* eSenseChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* eegPowerLowBetaChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* eegPowerDeltaChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* eegBlinkChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* mwmBaudRateChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* exceptionMessageChannelStreamHandler;
@property(nonatomic, retain) MWMDelegateHandler* mwmDelegateHandler;
@property(nonatomic, retain) MWMDevice *mwmDevice;
@end

@implementation FlutterMindWaveMobile2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
  FlutterMethodChannel* connectionChannel = [FlutterMethodChannel
                                             methodChannelWithName:NAMESPACE @"/connection"
                                             binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2Plugin* instance = [[FlutterMindWaveMobile2Plugin alloc] init];
  instance.connectionChannel = connectionChannel;
    
  // Set up eegSample channel
  FlutterEventChannel* eegSampleChannel = [FlutterEventChannel
                                           eventChannelWithName:NAMESPACE @"/eegSample"
                                           binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eegSampleChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.eegSampleChannelStreamHandler = eegSampleChannelStreamHandler;
  [eegSampleChannel setStreamHandler:eegSampleChannelStreamHandler];
    
  // Set up eSense channel
  FlutterEventChannel* eSenseChannel = [FlutterEventChannel
                                        eventChannelWithName:NAMESPACE @"/eSense"
                                        binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eSenseChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.eSenseChannelStreamHandler = eSenseChannelStreamHandler;
  [eSenseChannel setStreamHandler:eSenseChannelStreamHandler];
    
  // Set up eegPowerLowBeta channel
  FlutterEventChannel* eegPowerLowBetaChannel = [FlutterEventChannel
                                                 eventChannelWithName:NAMESPACE @"/eegPowerLowBeta"
                                                 binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eegPowerLowBetaChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.eegPowerLowBetaChannelStreamHandler = eegPowerLowBetaChannelStreamHandler;
  [eegPowerLowBetaChannel setStreamHandler:eegPowerLowBetaChannelStreamHandler];
  
  // Set up eegPowerDelta channel
  FlutterEventChannel* eegPowerDeltaChannel = [FlutterEventChannel
                                               eventChannelWithName:NAMESPACE @"/eegPowerDelta"
                                               binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eegPowerDeltaChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.eegPowerDeltaChannelStreamHandler = eegPowerDeltaChannelStreamHandler;
  [eegPowerDeltaChannel setStreamHandler:eegPowerDeltaChannelStreamHandler];
  
  // Set up eegBlink channel
  FlutterEventChannel* eegBlinkChannel = [FlutterEventChannel
                                          eventChannelWithName:NAMESPACE @"/eegBlink"
                                          binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* eegBlinkChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.eegBlinkChannelStreamHandler = eegBlinkChannelStreamHandler;
  [eegBlinkChannel setStreamHandler:eegBlinkChannelStreamHandler];
  
  // Set up mwmBaudRate channel
  FlutterEventChannel* mwmBaudRateChannel = [FlutterEventChannel
                                             eventChannelWithName:NAMESPACE @"/mwmBaudRate"
                                             binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* mwmBaudRateChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.mwmBaudRateChannelStreamHandler = mwmBaudRateChannelStreamHandler;
  [mwmBaudRateChannel setStreamHandler:mwmBaudRateChannelStreamHandler];
  
  // Set up exceptionMessage channel
  FlutterEventChannel* exceptionMessageChannel = [FlutterEventChannel
                                                  eventChannelWithName:NAMESPACE @"/exceptionMessage"
                                                  binaryMessenger:[registrar messenger]];
  FlutterMindWaveMobile2StreamHandler* exceptionMessageChannelStreamHandler = [[FlutterMindWaveMobile2StreamHandler alloc] init];
  instance.exceptionMessageChannelStreamHandler = exceptionMessageChannelStreamHandler;
  [exceptionMessageChannel setStreamHandler:exceptionMessageChannelStreamHandler];
    
  // Set up MWMdevice
  MWMDevice* mwmDevice = [MWMDevice sharedInstance];
  MWMDelegateHandler* mwmDelegateHandler = [[MWMDelegateHandler alloc]
                                            initWithChannels: eegSampleChannelStreamHandler
                                            eSenseChannelStreamHandler: eSenseChannelStreamHandler
                                            eegPowerLowBetaChannelStreamHandler: eegPowerLowBetaChannelStreamHandler
                                            eegPowerDeltaChannelStreamHandler: eegPowerDeltaChannelStreamHandler
                                            eegBlinkChannelStreamHandler: eegBlinkChannelStreamHandler
                                            mwmBaudRateChannelStreamHandler: mwmBaudRateChannelStreamHandler
                                            exceptionMessageChannelStreamHandler: exceptionMessageChannelStreamHandler];
  
  instance.mwmDelegateHandler = mwmDelegateHandler;
  [mwmDevice setDelegate:mwmDelegateHandler];
  instance.mwmDevice = mwmDevice;
    
  [registrar addMethodCallDelegate:instance channel:connectionChannel];
}

// Handle flutter method calls
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"connect" isEqualToString:call.method]) {
    NSLog(@"MWM connecting to device");
    NSString *deviceID = [call arguments];
    [_mwmDevice connectDevice:deviceID];
    result(nil);
  } else if ([@"disconnect" isEqualToString:call.method]) {
    NSLog(@"MWM disconnecting to device");
    [_mwmDevice disconnectDevice];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
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

@interface MWMDelegateHandler ()
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eegSampleChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eSenseChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eegPowerLowBetaChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eegPowerDeltaChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _eegBlinkChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _mwmBaudRateChannelStreamHandler;
@property(nonatomic, retain) FlutterMindWaveMobile2StreamHandler* _exceptionMessageChannelStreamHandler;
@end

@implementation MWMDelegateHandler

-(id)initWithChannels:(FlutterMindWaveMobile2StreamHandler*) eegSampleChannelStreamHandler
                     eSenseChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eSenseChannelStreamHandler
                     eegPowerLowBetaChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eegPowerLowBetaChannelStreamHandler
                     eegPowerDeltaChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eegPowerDeltaChannelStreamHandler
                     eegBlinkChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) eegBlinkChannelStreamHandler
                     mwmBaudRateChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) mwmBaudRateChannelStreamHandler
                     exceptionMessageChannelStreamHandler: (FlutterMindWaveMobile2StreamHandler*) exceptionMessageChannelStreamHandler {
    self = [super init];
    if (self) {
      self._eegSampleChannelStreamHandler = eegSampleChannelStreamHandler;
      self._eSenseChannelStreamHandler = eSenseChannelStreamHandler;
      self._eegPowerLowBetaChannelStreamHandler = eegPowerLowBetaChannelStreamHandler;
      self._eegPowerDeltaChannelStreamHandler = eegPowerDeltaChannelStreamHandler;
      self._eegBlinkChannelStreamHandler = eegBlinkChannelStreamHandler;
      self._mwmBaudRateChannelStreamHandler = mwmBaudRateChannelStreamHandler;
      self._exceptionMessageChannelStreamHandler = exceptionMessageChannelStreamHandler;
    }
    return self;
}

- (void)deviceFound:(NSString *)devName MfgID:(NSString *)mfgID DeviceID:(NSString *)deviceID {
    // Bluetooth scanning done with another package
    NSLog(@"MWM device found");
}

- (void)didConnect {
    NSLog(@"MWM did connect");
}

- (void)didDisconnect {
    NSLog(@"MWM did disconnect");
}

// Raw sample data
-(void)eegSample:(int) sample {
    if(self._eegSampleChannelStreamHandler.sink != nil) {
        self._eegSampleChannelStreamHandler.sink(@{
                                                   @"sample": @(sample),
                                                   });
    }
};

// Emotional Sense call back
-(void)eSense:(int)poorSignal Attention:(int)attention Meditation:(int)meditation {
    if(self._eSenseChannelStreamHandler.sink != nil) {
        self._eSenseChannelStreamHandler.sink(@{
                                                @"poorSignal": @(poorSignal),
                                                @"attention": @(attention),
                                                @"meditation": @(meditation),
                                                });
    }
}

-(void)eegPowerLowBeta:(int)lowBeta HighBeta:(int)highBeta LowGamma:(int)lowGamma MidGamma:(int)midGamma {
    if(self._eegPowerLowBetaChannelStreamHandler.sink != nil) {
        self._eegPowerLowBetaChannelStreamHandler.sink(@{
                                                         @"lowBeta": @(lowBeta),
                                                         @"highBeta": @(highBeta),
                                                         @"lowGamma": @(lowGamma),
                                                         @"midGamma": @(midGamma),
                                                         });
    }
}

-(void)eegPowerDelta:(int)delta Theta:(int)theta LowAlpha:(int)lowAlpha HighAlpha:(int)highAlpha {
    if(self._eegPowerDeltaChannelStreamHandler.sink != nil) {
        self._eegPowerDeltaChannelStreamHandler.sink(@{
                                                       @"delta": @(delta),
                                                       @"theta": @(theta),
                                                       @"lowAlpha": @(lowAlpha),
                                                       @"highAlpha": @(highAlpha),
                                                       });
    }
}

-(void)eegBlink:(int)blinkValue {
    if(self._eegBlinkChannelStreamHandler.sink != nil) {
        self._eegBlinkChannelStreamHandler.sink(@{@"blinkValue": @(blinkValue)});
    }
}

// Hardware configuration call back
-(void)mwmBaudRate:(int)baudRate NotchFilter:(int)notchFilter {
    if(self._mwmBaudRateChannelStreamHandler.sink != nil) {
        self._mwmBaudRateChannelStreamHandler.sink(@{
                                              @"baudRate": @(baudRate),
                                              @"notchFilter": @(notchFilter)
                                              });
    }
}

//Ble exception event
-(void)exceptionMessage:(TGBleExceptionEvent)eventType {
  if (self._exceptionMessageChannelStreamHandler.sink != nil) {
    self._exceptionMessageChannelStreamHandler.sink(@{@"eventType": @(eventType)});
  }
}

@end
